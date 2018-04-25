function varargout = nargoutWarning(nargout,cfilename,fcn,expectedNargout)
% If called with 3-4 args, warn about forgetting to save return value if nargout < expectedNargout.
% expectedNargout optional; default 1
%
% If called with 1 arg, set the warning mode on or off and return old warning
% mode.

% Copyright 2016-2017 The MathWorks, Inc.

    % Turned on only during development
    persistent warningMode;
    if isempty(warningMode)
        % Warn if a file named "warnOnNargout" appears in this file's directory.  We
        % don't ship this file.  This expression replaces the file name in our path
        % with "warnOnNargout".  
        fs = ['\' filesep];  % Windows filesep is \ so must escape
        warningMode = exist(regexprep(mfilename('fullpath'), [fs '[^' fs ']+$'], [fs 'warnOnNargout']), ...
                            'file') ~= 0;
    end
    if nargin == 1
        % nargout is the desired warning mode
        varargout{1} = warningMode;
        warningMode = nargout;
    elseif warningMode
        if nargin < 4
            expectedNargout = 1;
        end
        if nargout < expectedNargout
            warning(message('MATLAB:http:MissingArgout', cfilename, fcn, expectedNargout));
        end
    end
end

    