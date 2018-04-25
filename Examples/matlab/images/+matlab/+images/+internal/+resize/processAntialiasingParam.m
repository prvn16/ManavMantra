% Copyright 2016-2017 The MathWorks, Inc.

function params = processAntialiasingParam(arg, params_in)

valid = (isnumeric(arg) || islogical(arg)) && isscalar(arg);
if ~valid
    error(message('MATLAB:images:imresize:badAntialiasing'));
end

params = params_in;
params.antialiasing = arg;
end
