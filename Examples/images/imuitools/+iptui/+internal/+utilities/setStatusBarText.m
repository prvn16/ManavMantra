function setStatusBarText(groupName,statusText)
%setStatusBarText - Set status bar text to statusText for app with group
%name groupName.

% Copyright 2014, The MathWorks Inc.

md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
f = md.getFrameContainingGroup(groupName);
javaMethodEDT('setStatusText', f, statusText);

end