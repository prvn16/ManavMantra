function tc = categorical(tdata,varargin)
%CATEGORICAL Create a tall categorical array.
%   C = CATEGORICAL(DATA)
%   C = CATEGORICAL(DATA,VALUESET)
%   C = CATEGORICAL(DATA,VALUESET,CATEGORYNAMES)
%   C = CATEGORICAL(DATA, ..., 'Ordinal',ORD)
%   C = CATEGORICAL(DATA, ..., 'Protected',PROTECT)
%
%   Limitations:
%   The order of the categories when executing C = CATEGORICAL(DATA) is
%   undefined. Use VALUESET and CATEGORYNAMES to enforce the order.
%
%   See also CATEGORICAL.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(1,7);

% If VALUESET was provided then the list of categories is the same
% everywhere. If not, we must assume we have to force it to be the same.
if nargin>1 && isValueSet(varargin{1})
    % All workers will automatically get the same categories
    tc = mycategorical(tdata, varargin{:});
    
else
    % The order of the categories created by a tall array is undefined.
    tc = elementfun(@categorical, tdata);
    tc = setKnownType(tc, 'categorical');
    ec = chunkfun(@(x)x([]), tc);
    ec = setKnownType(ec, 'categorical');
    tcategories = clientfun(@categories, ec);
    % Ensure same categories.
    tc = elementfun(@setcats, tc, matlab.bigdata.internal.broadcast(tcategories));
    tc = setKnownType(tc, 'categorical');
    if nargin > 1
        tc = mycategorical(tc, varargin{:});
    end
    
end

% Work out the correct output adaptor. We need to build a categorical
% adaptor with protected and ordinal set correctly but with the size output
% by elementfun.
outAdaptor = iGetOutputAdaptor(tdata,varargin{:});
tc.Adaptor = outAdaptor.copySizeInformation(tc.Adaptor);

end

function tf = isValueSet(x)
% We assume the input is a valueset unless it is a match for one of the
% param-value pairs 'Ordinal' or 'Protected'.
if istall(x)
    tf = true;
    return;
end
tf = ~isNonTallScalarString(x) || ~(strcmpi('Ordinal', x) || strcmpi('Protected', x));
end

function tc = mycategorical(tdata,varargin)
vars = cellfun(@matlab.bigdata.internal.broadcast, varargin, 'UniformOutput', false);
tc = elementfun(@categorical, tdata, vars{:});
end

function adap = iGetOutputAdaptor(varargin)
% Determine the correct output adaptor given the list arguments.

% For now we only really care about whether ordinal and protected are set.
% If the data is already categorical, default to the same, otherwise
% default false. They can then be over-ridden by subsequent param-value
% pairs.
extraArgs = {};
if strcmp(tall.getClass(varargin{1}), 'categorical')
    % Only set if not default
    if isprotected(varargin{1})
        extraArgs = [extraArgs, 'Protected', true];
    end
    if isordinal(varargin{1})
        extraArgs = [extraArgs, 'Ordinal', true];
    end
end

% Build a local categorical array using only the flag arguments. First find
% the start of the param-value pairs.
idx = find(cellfun(@isNonTallScalarString, varargin), 1, 'first');
if isempty(idx)
    % No flags
    localData = categorical([], extraArgs{:});
else
    localData = categorical([], extraArgs{:}, varargin{idx:end});
end

% Create the adaptor from the local data
adap = matlab.bigdata.internal.adaptors.CategoricalAdaptor(localData);

end
