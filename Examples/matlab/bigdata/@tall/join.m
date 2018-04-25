function s = join(str, varargin)
%JOIN Combine elements of a string array or merge two tables or two timetables together.
%   For tall string array:
%   S = JOIN(STR)
%   S = JOIN(STR, DELIMITER)
%   S = JOIN(STR, DIM)
%   S = JOIN(STR, DELIMITER, DIM)
%
%   For tall table and timetable:
%   C = JOIN(A, B) 
%   C = JOIN(A, B, 'PARAM1',val1, 'PARAM2',val2, ...)
%
%   Limitations for tall table and timetable:
%   (1) Only JOIN between tall table and table, or 
%       tall timetable and timetable is supported.
%   (2) [C,IB] = JOIN(...) is not supported.
%
%   See also TALL/STRING, TABLE/JOIN, TIMETABLE/JOIN

%   Copyright 2016-2017 The MathWorks, Inc.

% First input should be tall, rest should not be
if ~istall(str)
    error(message('MATLAB:bigdata:array:ArgMustBeTall', 1, upper(mfilename)));
end
tall.checkNotTall(upper(mfilename), 1, varargin{:});
% First input should be 'string', 'table', or 'timetable'
str = tall.validateType(str, mfilename, {'string', 'table', 'timetable'}, 1);
ca = tall.getClass(str);

if strcmp(ca, 'table') || strcmp(ca, 'timetable')
    narginchk(2,inf);
    A = str;
    Aname = inputname(1);
    B = varargin{1};
    Bname = inputname(2);
    varargin = varargin(2:end);
    if strcmp(ca, 'table')
        if istimetable(B)
            error(message('MATLAB:table:join:TableTimetableInput'));
        elseif ~istable(B)
            error(message('MATLAB:table:join:InvalidInput'));
        end
    else
        %tall timetable
        if (~istimetable(B) && ~istable(B))
            error(message('MATLAB:table:join:InvalidInput'));
        end
    end
    % Merge tall (time)table with (time)table
    s = iJoinTable(A, Aname, B, Bname, varargin{:});
else
    % String JOIN
    narginchk(1,3);
    s = iJoinString(str, varargin{:});
end
end

function s = iJoinString(str, varargin)
% Work out if we know the dimension and delimiter
delim = ' ';
dim = [];
dimSpecified = false;
if nargin>2
    % JOIN(STR, DELIMITER, DIM)
    delim = varargin{1};
    dim = varargin{2};
    dimSpecified = true;
elseif nargin==2
    % JOIN(STR, DELIMITER) or JOIN(STR, DIM)
    if isnumeric(varargin{1})
        dim = varargin{1};
        dimSpecified = true;
    else
        delim = varargin{1};
    end
end


if ~dimSpecified
    % We need to select the last non-singleton dimension. If the dimension
    % cannot be deduced, error.
    dim = iGetLastNonsingletonDim(str);
    if isempty(dim)
        % Could not deduce dimension to us. For now we just error. In
        % future we could run both reduction and slice operations and
        % choose the right result lazily.
        error(message('MATLAB:bigdata:array:JoinNoDim'));
    end
end

% Check that delimiter is size 1 in tall dimension
if size(delim, 1) > 1
    error(message('MATLAB:bigdata:array:JoinDelimHeight'));
end

% Dimension now known. Either work on slices or reduce.
fcn = @(x) join(x,delim,dim);
if isequal(dim, 1) % TallDimension

    % Here we must run the reduction both ignoring empties and not ignoring empties,
    % selecting the result based on whether the overall array is size zero in
    % the tall dimension. We attempt to do the check up-front, but failing that
    % we do the check lazily. Both versions must set the adaptor type
    % correctly to avoid problems in clientfun.

    resultWhenEmptyInTallDim    = reducefun(fcn, str);
    resultWhenEmptyInTallDim.Adaptor = resetTallSize(str.Adaptor);

    resultWhenNotEmptyInTallDim = reducefun(@(x) iJoin(x, delim, dim), str);
    resultWhenNotEmptyInTallDim.Adaptor = resetTallSize(str.Adaptor);

    if getSizeInDim(str.Adaptor, 1) == 0
        s = resultWhenEmptyInTallDim;
    elseif getSizeInDim(str.Adaptor, 1) > 0
        s = resultWhenNotEmptyInTallDim;
    else
        isEmptyInTallDim = size(str, 1) == 0;
        s = clientfun(@iPickResult, isEmptyInTallDim, ...
                      resultWhenEmptyInTallDim, resultWhenNotEmptyInTallDim);
    end
    s.Adaptor = computeReducedSize(str.Adaptor, str.Adaptor, dim, false);
else
    s = slicefun(fcn, str);
    % Result is same type as STR, but same size as S
    s.Adaptor = copySizeInformation(str.Adaptor, s.Adaptor);
end
end

function out = iPickResult(tf, trueResult, falseResult)
%Used with 'clientfun' to choose between input arguments.
if tf
    out = trueResult;
else
    out = falseResult;
end
end

function out = iJoin(str, delim, dim)
% A variant of string join that defends against empty partitions. It's only
% valid to use this providing the overall array is non-empty - otherwise, it
% returns the wrong overall result.
if size(str, dim) == 0
    % Return empty rather than <missing>
    out = str;
else
    out = join(str, delim, dim);
end
end

function dim = iGetLastNonsingletonDim(x)
% Try to find the last non-singleton dimension of x. If the dimensions are
% unknown then the result is empty.
dim = [];
if isnan(x.Adaptor.NDims) || any(isnan(x.Adaptor.SmallSizes))
    return;
end

% We know both the number of dimensions and the size in each
% dimension. We pre-pend a zero so that the result is 1 if all other
% dimensions are unity.
dim = find([0, x.Adaptor.SmallSizes] ~= 1, 1, 'last');
end

function tt = iJoinTable(tA, Aname, B, Bname, varargin)
% JOIN for tall table and timetable

% Use joinBySample to create an appropriate adaptor for the output. We do
% this first as it provides the actual variable names. We don't want to
% repeat this same work per chunk.
adaptorA = tA.Adaptor;
adaptorB = matlab.bigdata.internal.adaptors.getAdaptor(B);
requiresVarMerging = true;
[adaptorOut, varNames] = joinBySample(...
    @(A, B) joinNamedTables(@join, A, B, Aname, Bname, varargin{:}), ...
    requiresVarMerging, adaptorA, adaptorB);

% Now schedule the actual work.
tt = slicefun(@(x)iLocalJoin(x,B,varNames,varargin{:}),tA);
tt.Adaptor = adaptorOut;
end

function tt = iLocalJoin(A,B,outputNames,varargin)
tt = join(A,B,varargin{:});
tt.Properties.VariableNames = outputNames;
end
