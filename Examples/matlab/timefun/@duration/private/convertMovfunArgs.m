function argout = convertMovfunArgs(varargin)
% Convert moving statistics arguments for datetimes

%   Copyright 2016 The MathWorks, Inc.

    narginchk(2, inf);
    argout = varargin;

    % Check the window size
    spArgs = cellfun(@argnameIsSamplePoints, argout);
    lastArg = find(spArgs, 1, 'last');
    if ~isempty(lastArg) && ((lastArg < nargin) && isduration(argout{lastArg+1}))
        if ~isduration(argout{2})
            error(message(strcat('MATLAB:movfun:winsizeNotDuration'), 'duration'));
        end
        argout{2} = argout{2}.millis;
    end
    
    % Convert datetime arrays if they are arrays of sample points
    tf = find(cellfun(@isduration, argout));
    for i = 1:length(tf)
        argIdx = tf(i);
        if ((argIdx > 3) && spArgs(argIdx-1))
            argout{argIdx} = argout{argIdx}.millis;
        end
    end
    
end

%--------------------------------------------------------------------------
function tf = argnameIsSamplePoints(arg)
% Checks if an input argument is the 'SamplePoints' string

    if (ischar(arg) || isstring(arg)) && ~isempty(arg)
        tf = startsWith(string('SamplePoints'), arg, 'IgnoreCase', true);
    else
        tf = false;
    end

end