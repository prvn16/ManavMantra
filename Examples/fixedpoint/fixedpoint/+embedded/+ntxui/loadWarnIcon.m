function A = loadWarnIcon
% Change icon in Simulink's 'warning.png' to make it double-precision
% and have NaN's in peripheral 0's for transparency.

%   Copyright 2010 The MathWorks, Inc.

% The "warning" icon is in the same directory as this file.
% This file is a copy of the icon in:
%   [matlabroot
%    'toolbox\simulink\simulink\@Simulink\@DataTypePrmWidget' ...
%    '\private\warning.png']
p = fileparts(mfilename('fullpath'));
iconFullFile = fullfile(p,'warning.png');
A = double(imread(iconFullFile));

% Identify area where "exclamation mark" 0's are located
% These 0's interfere with identifying border 0's
% The border 0's need to be mapped to NaN's
% Overwrite "exclamation mark" 0's, which are all in the
% interior of the icon, in a copy of A.
% B will now have 0's only where border 0's are located
cols = 8:9;
rows = 6:13;
B = A;
B(rows,cols,:) = -1;

% Update the icon
A = A./256;    % scale for doubles, [0,1] range
A(B==0) = NaN; % overwrite border 0's for transparency
