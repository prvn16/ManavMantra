function helpdesk
%HELPDESK Comprehensive hypertext documentation and troubleshooting. 
%   HELPDESK displays the start page for the online documentation
%   in the MATLAB Help browser.
%
%   HELPDESK will be removed in a future release. Use DOC instead. 

%   Copyright 1984-2011 The MathWorks, Inc. 

warning(message('MATLAB:helpdesk:FunctionToBeRemoved'))

% Call doc with no arguments to load the main web page.
doc;
