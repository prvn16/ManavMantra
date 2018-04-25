function [lia, locb] = ismember(a, b, varargin)
%ISMEMBER True for set member.
%   LIA = ismember(A,B)
%   LIA = ismember(A,B,'rows')
%   [LIA,LOCB] = ismember(A,B)
%   [LIA,LOCB] = ismember(A,B,'rows')
%   [LIA,LOCB] = ismember(A,B,'legacy')
%   [LIA,LOCB] = ismember(A,B,'rows','legacy')
%
%   Limitations:
%   Only one of A or B can be a tall array, a tall table or a tall
%   timetable.
%
%   See also ISMEMBER, TALL.

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2, 4);

% Either A or B can be tall, but not both or neither!
if (istall(a) && istall(b)) || (~istall(a) && ~istall(b))
    error(message('MATLAB:bigdata:array:IsmemberOnlyOneTall'));
end
    

aIsTable = any(strcmp(tall.getClass(a), {'table', 'timetable'}));
nOut     = max(1,nargout);
out      = cell(1, nOut);
try
    if aIsTable
        [out{1:nOut}] = iTableIsmember(a, b, varargin{:});
    else
        [out{1:nOut}] = iArrayIsmember(a, b, varargin{:});
    end
catch E
    throw(E);
end
lia = out{1};
if nargout > 1
    locb = out{2};
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ISMEMBER for tall table. Note we accept string objects as flags, tabular does
% not (yet).
function [lia, locb] = iTableIsmember(a, b, varargin)

if ~istable(b) && ~istimetable(b)
    error(message('MATLAB:table:setmembership:TypeMismatch'));
end
aVarNames = subsref(a, substruct('.', 'Properties', '.', 'VariableNames'));
bVarNames = b.Properties.VariableNames;
if ~isequal(sort(aVarNames), sort(bVarNames))
    error(message('MATLAB:table:setmembership:DisjointVars'));
end
flags = iResolveFlagsToLowercaseStringOrError(varargin, ...
    'MATLAB:table:setmembership:UnknownInput2');

% Ignore 'rows', it's always implied, but accepted anyway.  Do not accept
% 'R2012a' or 'legacy', or 'stable' and 'sorted', or anything else.
if ~isempty(intersect(["legacy", "r2012a"], flags))
    error(message('MATLAB:table:setmembership:BehaviorFlags'));
end
flags(flags == "rows") = [];
if ~isempty(flags)
    error(message('MATLAB:table:setmembership:UnknownFlag2',flags(1)));
end

% Make sure we only ask for outputs we need - the second output might need
% an extra pass!
if nargout==1
    lia = iSharedIsmember(a, b, {'rows'});
else
    [lia, locb] = iSharedIsmember(a, b, {'rows'});
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ISMEMBER implementation for non-table arrays.
function [lia, locb] = iArrayIsmember(a, b, varargin)
% Validate flags
validFlags = ["rows", "legacy", "r2012a"];
flags = iResolveFlagsToLowercaseStringOrError(varargin, 'MATLAB:ISMEMBER:UnknownInput');
if ~all(ismember(flags, validFlags))
    [~, invalidIdx] = setdiff(flags, validFlags);
    assert(~isempty(invalidIdx));
    error(message('MATLAB:ISMEMBER:UnknownFlag',varargin{invalidIdx(1)}));
end
if nargin == 4 && flags(1) == flags(2)
    error(message('MATLAB:ISMEMBER:RepeatedFlag', flags(1)));
end
if ismember("legacy", flags) && flags(end) ~= "legacy"
    error(message('MATLAB:ISMEMBER:LegacyTrailing'))
end

% Make sure we only ask for outputs we need - the second output might need
% an extra pass!
if nargout==1
    lia = iSharedIsmember(a, b, cellstr(flags));
else
    [lia, locb] = iSharedIsmember(a, b, cellstr(flags));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stringArray = iResolveFlagsToLowercaseStringOrError(argsCell, errId)
if ~all(cellfun(@isNonTallScalarString, argsCell))
    error(message(errId));
end
stringArray = lower(string(argsCell));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lia, locb] = iSharedIsmember(a, b, flags)
% Shared dispatch for ISMEMBER where either A or B is a tall array/table.
if istall(a)
    [lia, locb] = iIsmemberRemoteLocal(a, b, flags);
else
    assert(istall(b), "Either A or B must be tall");
    % When A is local, calculating locb requires and extra pass. Avoid it
    % if the user didn't ask for it.
    if nargout == 1
        lia = iIsmemberLocalRemote(a, b, flags);
    else
        [lia, locb] = iIsmemberLocalRemote(a, b, flags);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lia, locb] = iIsmemberRemoteLocal(a, b, flags)
% Shared ismember implementation when A is a tall array/table and B is in
% memory. In this case the result is the same height as A and B is
% broadcast to all partitions.
isRowsMode = ismember('rows', flags);

if isRowsMode
    % In 'rows' mode, this is a slicefun
    [lia, locb] = slicefun(@(x) ismember(x, b, flags{:}), a);
else
    % Otherwise it's an elementfun
    [lia, locb] = elementfun(@(x) ismember(x, b, flags{:}), a);
end

lia = setKnownType(lia, 'logical');
locb = setKnownType(locb, 'double');

if isRowsMode
    % In 'rows' mode, small sizes are simply: 1.
    lia.Adaptor  = setSmallSizes(lia.Adaptor, 1);
    locb.Adaptor = setSmallSizes(locb.Adaptor, 1);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lia, locb] = iIsmemberLocalRemote(a, b, flags)
% Shared ismember implementation when A is a local array/table and B is
% tall. In this case the result is the same height as the local array A and
% the result for each partition of B must be reduced between partitions.
isRowsMode = ismember('rows', flags);
needLocB = nargout>1;

% Computing the first element location requires knowledge of absolute
% indices.
if needLocB
    bIdx = getAbsoluteSliceIndices(b);
    [lia, locb] = aggregatefun( ...
        @(y,yIdx,ySz) iProcessChunkOfB(a, y, flags, yIdx, ySz), ...
        @iCombineChunksOfB, ...
        b, bIdx, matlab.bigdata.internal.broadcast(size(b)) );
else
    lia = aggregatefun( ...
        @(y) iProcessChunkOfB(a, y, flags), ...
        @iCombineChunksOfB, ...
        b );
end


% Both results were captured in a cell. Unwrap them now.
lia = clientfun( @(x) x{1}, lia );
if needLocB
    locb = clientfun( @(x) x{1}, locb );
end

% We know that the outputs are logical and double, and are the same size as
% A unless in rows mode
lia = setKnownType(lia, 'logical');
if needLocB
    locb = setKnownType(locb, 'double');
end

adapA = matlab.bigdata.internal.adaptors.getAdaptor(a);
if isRowsMode
    % In 'rows' mode, small sizes are simply: 1.
    lia.Adaptor = copyTallSize(lia.Adaptor, adapA);
    lia.Adaptor = setSmallSizes(lia.Adaptor, 1);
    if needLocB
        locb.Adaptor = copyTallSize(locb.Adaptor, adapA);
        locb.Adaptor = setSmallSizes(locb.Adaptor, 1);
    end
else
    % Outputs are same size as A
    lia.Adaptor = copySizeInformation(lia.Adaptor, adapA);
    if needLocB
        locb.Adaptor = copySizeInformation(locb.Adaptor, adapA);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lia, locb] = iProcessChunkOfB(A, localB, flags, bIdx, bGlobalSize)
% Process one chunk of B, working out the absolute index for items found.
needLocB = nargin>3;

if needLocB
    [localTF, localIdx] = ismember(A, localB, flags{:});
else
    localTF = ismember(A, localB, flags{:});
end

% In order to reduce localTF element-wise we need to treat as a single
% element, so put in a cell;
lia = {localTF};

if needLocB
    % Indices into the local array need converting to absolute indices. If
    % the input B was not a vector, we need to account for the overall
    % height of the array B.
    if any(localIdx(:)>size(localB,1))
        [localRow,localCol] = ind2sub(size(localB),localIdx);
        validIdx = (localIdx > 0);
        localRow(validIdx) = bIdx(localRow(validIdx));
        localIdx(validIdx) = sub2ind(bGlobalSize, localRow(validIdx), localCol(validIdx)); 
    else
        % All in first column
        localIdx(localIdx>0) = bIdx(localIdx(localIdx>0));
    end
    locb = {localIdx};
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outLia, outLocb] = iCombineChunksOfB(inLia, inLocb)
% Combine lia using OR
outLia = inLia(1);
for ii=2:numel(inLia)
    outLia{1} = outLia{1} | inLia{ii};
end

% Only calculate LocB if requested
if nargin>1
    % Combine locb by taking min of non-zero
    outLocb = inLocb(1);
    for ii=2:numel(inLocb)
        outLocb{1} = iMinNonZero(outLocb{1}, inLocb{ii});
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = iMinNonZero(a, b)
% Find the minimum of non-zero elements between two arrays. Elements that
% are zero in both remain zero.

out = a;
zeroA = (a==0);
zeroB = (b==0);

% Entries that are zero in A can be taken from B
out(zeroA) = b(zeroA);

% Entries that are zero in B can be taken from A
out(zeroB) = a(zeroB);

% Entries that are non-zero in both need to use MIN
inBoth = ~zeroA & ~zeroB;
out(inBoth) = min(a(inBoth), b(inBoth));
end
