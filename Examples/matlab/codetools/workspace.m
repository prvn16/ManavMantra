function workspace
%WORKSPACE Open Workspace browser to manage workspace
%   WORKSPACE Opens the Workspace browser with a view of the variables
%   in the current Workspace.  Displayed variables may be viewed,
%   manipulated, saved, and cleared.
%
%   See also WHOS, OPENVAR, SAVE.

%   Copyright 1984-2008 The MathWorks, Inc.
% Check for required level of Java support
err = javachk('mwt', 'The Workspace browser');
if (~isempty(err))
    error('MATLAB:workspace:UnsupportedPlatform', err.message);
end

%Launch the Workspace
try
    com.mathworks.mlservices.MLWorkspaceServices.invoke;
catch
    error(message('MATLAB:workspace:workspaceFailed'));
end
