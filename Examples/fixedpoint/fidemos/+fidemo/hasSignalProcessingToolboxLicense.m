function flag = hasSignalProcessingToolboxLicense()
%hasSignalProcessingToolboxLicense   Signal Processing Toolbox license availability
%   hasSignalProcessingToolboxLicense returns true (1) if a Signal Processing Toolbox license is available.
%   If no Signal Processing Toolbox license is available, it returns false (0).

%    Copyright 2010 The MathWorks, Inc.

flag = license('test', 'Signal_Toolbox');

