function [deployable, why] = isdeployable(files, varargin)

% Valid, if boring, values for all outputs.
deployable = false;
why = {};

if nargin == 0
    error(message('MATLAB:depfun:req:NoFilesToAnalyze'))
end

% files should be a cell array of strings. As a special case, allow a
% single file name string (wrap it in a cell array).
if ~iscell(files)
    if ischar(files) 
        files = { files };
    elseif(isa(files,'java.lang.String[]'))
        files = cell(files);
    end
    
end

% Default values for optional inputs.
entryPoint = false;
target = 'None';

% Process optional arguments. Distinguish them by data type.
k = 1;
setEntryPoint = false;
setTarget = false;
while (k <= nargin-1)
    if islogical(varargin{k})
        if setEntryPoint
            error(message('MATLAB:depfun:req:DoubleEntryPoint', ...
                'isdeployed', entryPoint, varargin{k}))
        end
        entryPoint = varargin{k};
        setEntryPoint = true;
    elseif ischar(varargin{k})
        if setTarget
            error(message('MATLAB:depfun:req:TwiceToldTarget', ...
                'isdeployed', target, varargin{k}))
        end
        target = varargin{k};
        setTarget = true;
    end
    k = k + 1;
end

% Parse the target string to a member of the Target enumeration.
tgt = matlab.depfun.internal.Target.parse(target);
if (tgt == matlab.depfun.internal.Target.Unknown)
    error(message('MATLAB:depfun:req:BadTarget', target))
end

% Create a Completion to do the real work. Turn off the warning about all
% files being excluded from the root set -- but restore its state 
% before returning.
rsw = warning('off', 'MATLAB:depfun:req:AllInputsExcluded');
c = matlab.depfun.internal.Completion(tgt);
warning(rsw.state, rsw.identifier);

[deployable, why] = isdeployable(c, files, entryPoint);
