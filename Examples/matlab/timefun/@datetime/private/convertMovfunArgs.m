function argout = convertMovfunArgs(varargin)
% Convert moving statistics arguments for datetimes

%   Copyright 2016 The MathWorks, Inc.

    narginchk(2, inf);
    argout = varargin;

    % Check the window size
    spArgs = cellfun(@argnameIsSamplePoints, argout);
    spNumArgs = find(spArgs);
    if ~isempty(spNumArgs) && ((spNumArgs(end) < nargin) && isdatetime(argout{spNumArgs(end)+1}))
        if ~isduration(argout{2})
            error(message(strcat('MATLAB:movfun:winsizeNotDuration'), 'datetime'));
        end
        argout{2} = milliseconds(argout{2});
        % Check for NaTs here
        if any(~isfinite(argout{spNumArgs(end)+1}))
            error(message(strcat('MATLAB:movfun:SamplePointsNonFinite'), 'SamplePoints', 'NaT'));
        end
    end

    % Check if any other sample points input was complex -- this should
    % produce an error
    for i = 1:length(spNumArgs)
        if ((spNumArgs(i) < nargin) && isfloat(varargin{spNumArgs(i)+1}) && ~isreal(varargin{spNumArgs(i)+1}))
            error(message(strcat('MATLAB:movfun:SamplePointsComplex')));
        end
    end
    
    % Convert datetime arrays if they are arrays of sample points
    tf = find(cellfun(@isdatetime, argout));
    for i = 1:length(tf)
        argIdx = tf(i);
        if ((argIdx > 3) && spArgs(argIdx-1))
            argout{argIdx} = argout{argIdx}.data;
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