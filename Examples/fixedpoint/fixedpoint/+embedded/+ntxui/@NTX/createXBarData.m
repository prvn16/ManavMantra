function [xp,zp,xl,zl,cp] = createXBarData(x,binwidth, offset,rgb)
% Create data for a dynamic bargraph plot.
%
% Offset bars/lines to align their right edge with the corresponding tick
%
% Bar patch data:
%   xp: xdata, 4xN
%   zp: zdata, 4xN
%   cp: cdata, 1xNx3
%
% Sign line data:
%  3 points per line, [start end NaN], in one long column vector
%   xl: xdata, 3Nx1
%   zl: zdata, 3Nx1

%   Copyright 2010 The MathWorks, Inc.

% coords for patch
N = numel(x);

% Init coords and color for patch
xp = zeros(4,N);
zp = zeros(4,N) - 2; % put behind cursors

% Init coords for signline
xl = zeros(3,N);
zl = zeros(3,N) - 1.9; % behind cursors, but over bar patch

% Define a small gap between bar and sign line edges
% If white line extends to edge of bar, it looks bad
gap = 0.03*binwidth;
for i = 1:N
    xi1 = x(i) - 1; % bin edges represent the upper bound
    xi2 = xi1+binwidth;
    
    % Coords for bar patch
    xp(:,i) = [xi1;xi1;xi2;xi2];
    
    % Coords for line
    xl(:,i) = [xi1+gap;xi2-gap;NaN];
end

% Force line data to be a column
xl = xl(:);
zl = zl(:);

% Only compute color data is requested
% Init to one truecolor (RGB) color for ALL bars
if nargout>4
    % Create cdata color array for bar patch
    % RGB arg must be a 1x3 vector
    cp = zeros(1,N,3); % R,G,B in 3rd dim
    for i=1:N
        cp(1,i,:) = rgb;
    end
end
