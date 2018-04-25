function opts = parseMovOpts(movFcn, k, varargin)
%parseMovOpts - parse input options for moving window family functions
% This is a MATLAB based implementation for the same logic in 
% matlab/toolbox/matlab/datafun/src/...

%   Copyright 2016-2017 The MathWorks, Inc.

% Parse the required window argument k
window = iCheckWindowArg(k);

opts = struct(...
    'window', window,...
    'dim', [], ... empty is used to indicate unspecified -> mov in first non singleton dimension
    'nanflag', iGetDefaultNanFlag(movFcn), ...
    'endpoints', 'shrink');

if iHasWeightArg(movFcn)
    % For movstd & movvar, default weight is empty.  This ensures that the
    % default from the builtin method is used.
    opts.weight = [];
end

if isempty(varargin)
    % No optional inputs to parse/check for errors
    return;
end

optionalInputs = varargin;
argId = 1;

if iHasWeightArg(movFcn) && ~isNonTallScalarString(optionalInputs{argId})
    opts.weight = iCheckWeightArg(optionalInputs{1});
    argId = argId + 1;
end

if argId <= length(optionalInputs) && ~isNonTallScalarString(optionalInputs{argId})
    opts.dim = iCheckDimArg(optionalInputs{argId});
    argId = argId + 1;
end

firstTextArgId = argId;

while argId <= length(optionalInputs)
    if ~isNonTallScalarString(optionalInputs{argId})
        if argId == firstTextArgId
            error(message('MATLAB:movfun:wrongString'));
        else
            error(message('MATLAB:movfun:wrongNVPair'));
        end
    elseif argId == firstTextArgId && ~any(startsWith({'endpoints', 'samplepoints'}, optionalInputs{argId}, 'IgnoreCase', true))
        opts.nanflag = iCheckNanFlag(optionalInputs{argId});
        argId = argId + 1;
    elseif startsWith('EndPoints', optionalInputs{argId}, 'IgnoreCase', true)
        if (argId + 1) > length(optionalInputs)
            error(message('MATLAB:movfun:noEndpointValue'));
        end
        opts.endpoints = iParseEndpointsValue(optionalInputs{argId+1});
        
        if isequal(func2str(@movmad),'movmad') && ~isreal(opts.endpoints)
            error(messsage('MATLAB:movfun:complexFillValue'));
        end
        
        argId = argId + 2; 
    elseif startsWith('SamplePoints', optionalInputs{argId}, 'IgnoreCase', true)
        % TODO (g1477991) Add support for sample points option for tall arrays
        error(message('MATLAB:bigdata:array:SamplePointsNotSupported'));
    else
        % Giving omitnan or includenan after N-V pairs generates a different error
        if any(startsWith({'includenan', 'omitnan'}, optionalInputs{argId}, 'IgnoreCase', true))
            error(message('MATLAB:movfun:nanFlagAfterPairs'));
        else
            error(message('MATLAB:movfun:wrongNVPair'));
        end
    end
end
end

function window = iCheckWindowArg(window)
try
    allowedTypes = {'numeric', 'logical'};
    
    if isscalar(window)
        validateattributes(window, allowedTypes, {'positive', 'finite'});
        window = iVectorizeScalarWindow(window);
    else
        validateattributes(window, allowedTypes, {'nonnegative', 'finite','vector', 'numel', 2});
        
        % window must already be in [NB NF] vector form - floor is used to
        % ensure that non-integer values are converted into valid padding
        % slices for stencilfun
        window = floor(window);
    end
catch
    error(message('MATLAB:movfun:wrongWindowLength'));
end
end

function weight = iCheckWeightArg(weight)
% For movstd and movvar: optional weight argument can be 0, 1, or empty
if isempty(weight)
    return;
end

try
    validateattributes(weight, {'numeric', 'logical'}, {'scalar', 'integer'});
    assert(weight == 0 || weight == 1);
catch
    error(message('MATLAB:movfun:wrongNormalization'));
end
end

function dim = iCheckDimArg(dim)
try
    validateattributes(dim, {'numeric'}, {'integer', 'positive', 'scalar'});
catch
    error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
end
end

function nanflag = iCheckNanFlag(nanflag)
try 
    nanflag = validatestring(nanflag, {'includenan', 'omitnan'});
catch
    error(message('MATLAB:movfun:wrongString'));
end
end

function endpt = iParseEndpointsValue(endpt)
try
    if isNonTallScalarString(endpt)
        endpt = validatestring(endpt, {'shrink', 'fill', 'discard'});
    else
       validateattributes(endpt, {'numeric', 'logical'}, {'scalar'});
       
       % complex integer fill values are disallowed for all movfuns
       assert( ~( ~isreal(endpt) && isinteger(endpt) ) ); 
    end
catch
    error(message('MATLAB:movfun:wrongEndpoint'));
end
end

function window = iVectorizeScalarWindow(window)
if isfloat(window)
    % floating point window at index ii is defined as containing the
    % indices in the set [ ii-window/2, ii+window/2 ) where the backward
    % boundary is inclusive and the forward boundary is exclusive.
    % For window = 4 the output should be [2 1] which is a 4-point stencil
    % containing 2 backwards slices, the current slice, and 1 forward slice
    % For window = 4.1 the output will be [2 2] according to this definition.
    half_window = window/2;
    window = [floor(half_window) ceil(half_window)-1];
else
    % must be an integer window
    if mod(window, 2) == 0
        % even windows are centered about the current and previous elements
        nb = window/2;
        window = [nb  nb-1];
    else
        % odd windows are centered about the current element
        n = (window-1)/2;
        window = [n n];
    end
end
end

function hasNF = iHasWeightArg(movFcn)
hasNF = ismember(func2str(movFcn), {'movstd', 'movvar'});
end

function defaultNanFlag = iGetDefaultNanFlag(movFcn)
% Select the correct default value for the nanflag option for the given
% movFcn.  Most functions use 'includenan', except for movmax and movmin
% which use 'omitnan'
% See default_omitnan_value defined in datafun/movfun_util.hpp 

if ismember(func2str(movFcn), {'movmax', 'movmin'})
    defaultNanFlag = 'omitnan';
else
    defaultNanFlag = 'includenan';
end
end


