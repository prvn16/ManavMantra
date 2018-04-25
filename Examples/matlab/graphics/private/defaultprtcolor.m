function color = defaultprtcolor(varargin)
%DEFAULTPRTCOLOR Retrieve  color mode for the default printer (1=color; 0=mono)

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin 
    h = varargin{1};
else
    h = [];
end

% Retrieve default printer device
[~, in_dev] = printopt;  
dev = in_dev(3:end);

% For windows drivers, default color mode is based on default printer
if ispc && strncmp(dev,'win',3)
	color = system_dependent('getprintercolor');
% For all other drivers, determine color mode from printopt value
else
	[ ~, devices, ~, ~, colorDevs, ~ ] ...
            = printtables(printjob(h));
	color = 'C' == colorDevs{strcmp(dev,devices)};
	
end
