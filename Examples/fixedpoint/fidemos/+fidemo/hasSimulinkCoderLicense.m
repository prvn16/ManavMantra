function flag = hasSimulinkCoderLicense()
%hasSimulinkCoderLicense   Simulink Coder license availability
%   hasSimulinkCoderLicense returns true (1) if a Simulink Coder license is available.
%   If no Simulink Coder license is available, it returns false (0).

%    Copyright 2010 The MathWorks, Inc.

flag = license('test', 'Real-Time_Workshop');

