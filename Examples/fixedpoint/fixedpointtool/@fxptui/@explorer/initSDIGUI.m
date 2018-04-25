function initSDIGUI(h)
%INITSDIGUI Initialize the SDI GUI for plotting.

%   Copyright 2011 The MathWorks, Inc.

sdiGUI = Simulink.sdi.Instance.getMainGUI();
% Bring the GUI into focus.
sdiGUI.Hide();
sdiGUI.Show();



% [EOF]
