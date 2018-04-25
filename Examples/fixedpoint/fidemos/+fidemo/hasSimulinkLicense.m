function flag = hasSimulinkLicense()
%hasSimulinkLicense   Simulink license availability
%   hasSimulinkLicense returns true (1) if a Simulink license is available. 
%   If no Simulink license is available, it returns false (0).

%    Copyright 2010 The MathWorks, Inc.

flag = license('test', 'Simulink');

