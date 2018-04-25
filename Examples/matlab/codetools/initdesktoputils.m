function initdesktoputils
%INITDESKTOPUTILS Initialize the MATLAB path and other services for the 
%   desktop and desktop tools. This function is only intended to
%   be called from matlabrc.m and will not have any effect if called after
%   MATLAB is initialized.

%   Copyright 1984-2011 The MathWorks, Inc. 

if usejava('swing')
    com.mathworks.jmi.MatlabPath.setInitialPath(path);
    com.mathworks.mlservices.MatlabDebugServices.initialize;
    com.mathworks.mde.editor.debug.DebuggerInstaller.init();
end
