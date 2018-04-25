function options = parseOptionalDemonsInputs(varargin)

%   Copyright 2014-2015 The MathWorks, Inc.

% Define struct holding default values for optional arguments and
% Name/Value pairs.
options = struct('NumIterations',100,...
    'AccumulatedFieldSmoothing',1.0,...
    'PyramidLevels',3,...
    'DisplayWaitbar', true);

beginningOfNameVal = find(cellfun(@isstr,varargin),1);
if isempty(beginningOfNameVal)
    % Assign index one past end of varargin to make parsing fall out
    beginningOfNameVal = length(varargin)+1;
end

numOptionalArgumentsSpecified = beginningOfNameVal-1;

% Parse optional arguments and assign defaults where needed.
if (numOptionalArgumentsSpecified == 0)
    % Do nothing, options struct is already in default state.
elseif (numOptionalArgumentsSpecified == 1)
    options.NumIterations = validateNumIterations(varargin{1});
else
    error(message('images:imregdemons:tooManyOptionalArgs'));
end

numPVArgs = length(varargin) - numOptionalArgumentsSpecified;
if ~isequal(mod(numPVArgs,2),0)
    error(message('images:imregdemons:invalidNameValue'));
end

ParamName = {'PyramidLevels','AccumulatedFieldSmoothing', 'DisplayWaitbar'};
ValidateFcn = {@validatePyramidLevels, @validateSigma, @validateDisplayWaitbar};
for p = beginningOfNameVal:2:length(varargin)
    
    name  = varargin{p};
    value = varargin{p+1};
    
    % Look for the parameter amongst the possible values.
    logical_idx = strncmpi(name, ParamName, numel(name));
    
    if ~any(logical_idx)
        error(message('images:imregdemons:unknownParameterName',name));
    elseif numel(find(logical_idx)) > 1
        error(message('images:imregdemons:ambiguousParameterName',name));
    end
    
    % Validate the value.
    validateFcn = ValidateFcn{logical_idx};
    options.(ParamName{logical_idx}) = validateFcn(value);
        
end

options.NumIterations = postValidateAndProcessN(options.NumIterations,options.PyramidLevels);

end

function nVec = postValidateAndProcessN(N,levels)

if isscalar(N)
    nVec = repmat(N,[1 levels]);
else
    if length(N) ~= levels
        error(message('images:imregdemons:numIterationsVector','''PyramidLevels'''));
    end
    nVec = N;
end
end

function pyramidLevels  = validatePyramidLevels(levels)

supportedDataClasses = {'uint8','uint16','uint32','int8','int16','int32','single','double'};

validateattributes(levels,supportedDataClasses,{'real','positive','nonsparse','finite','scalar','integer'},...
    mfilename,'PyramidLevels');

pyramidLevels = levels;

end


function sigma = validateSigma(sig)

supportedDataClasses = {'uint8','uint16','uint32','int8','int16','int32','single','double'};

validateattributes(sig,supportedDataClasses,{'real','positive','nonsparse','finite','scalar'},...
    mfilename,'AccumulatedFieldSmoothing');

sigma = sig;

end

function numIterations = validateNumIterations(N)

supportedDataClasses = {'uint8','uint16','uint32','int8','int16','int32','single','double'};

validateattributes(N,supportedDataClasses,{'real','positive','nonsparse','finite','vector','integer'},...
    mfilename,'N');

numIterations = N;

end

function displayWaitbar = validateDisplayWaitbar(displayWaitbar)
    validateattributes(displayWaitbar,...
        {'logical','numeric'}, {'scalar', 'real'}, mfilename);
end
