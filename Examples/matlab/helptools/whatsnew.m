function whatsnew(arg)
%WHATSNEW Access Release Notes via the Help browser.
%   WHATSNEW displays the Release Notes in the Help browser, presenting 
%   information about new features, problems from previous releases that 
%   have been fixed in the current release, and known problems, all 
%   organized by product.
%
%   WHATSNEW will be removed in a future release. 
%
%   See also VER, HELP.

%   Copyright 1984-2012 The MathWorks, Inc.

warning(message('MATLAB:whatsnew:FunctionToBeRemoved'))

% Make sure that we can support the whatsnew command on this platform.
errormsg = javachk('mwt',mfilename);
if ~isempty(errormsg)
	error('MATLAB:whatsnew:UnsupportedPlatform', errormsg.message);
end

html_file = fullfile(docroot,'matlab','release-notes.html');
helpview(html_file);
