function varargout = fevalcRespectingHotlinks(fun)
% This function is undocumented and subject to change in a future release

% This is a combination of FEVAL and EVALC, by evaluating a function handle
% and capturing its text output as well as any output arguments. It also
% respects hotlinks, due to the fact that the context of EVALC always has
% hotlinks on, regardless of the external state.

% Copyright 2017 The MathWorks, Inc.

import matlab.unittest.internal.richFormattingSupported;

hot = logical(richFormattingSupported);
[varargout{1:nargout}] = evalc('hotwrap');

    function varargout = hotwrap %#ok<DEFNU> EVALC
        feature('hotlinks',hot); % no cleanup required - evalc will restore it
        [varargout{1:nargout}] = fun();
    end
end