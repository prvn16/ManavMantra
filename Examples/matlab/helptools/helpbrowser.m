function helpbrowser(varargin)
%HELPBROWSER Help Browser
%   HELPBROWSER Brings up the Help Browser.
%
%   HELPBROWSER will be removed in a future release. Use DOC instead. 

%   Copyright 1984-2012 The MathWorks, Inc.

warning(message('MATLAB:helpbrowser:FunctionToBeRemoved'))

% Check for required level of Java support
err = javachk('mwt', 'The Help browser');
if (~isempty(err))
	error(message('MATLAB:helpbrowser:UnsupportedPlatform'));
end

try
    % Launch the Help Browser
    com.mathworks.mlservices.MLHelpServices.invoke;
catch
    % Failed. Bail
    error(message('MATLAB:helpbrowser:HelpBrowserFailed'));
end

end
