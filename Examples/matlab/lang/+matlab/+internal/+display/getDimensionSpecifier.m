function dimSpec = getDimensionSpecifier
% dimSpec returns the dimension specifier based on the mode in which MATLAB
% is operating.
% If MATLAB is using the desktop, it returns the Unicode times character
% (0xd7). If MATLAB is operating in nodesktop, nojvm or deployed modes, it
% returns the ascii 'x' character (0x78).

% Copyright 2016 The MathWorks, Inc 

if matlab.internal.display.isDesktopInUse
    dimSpec = char(215);
else
    dimSpec = char(120);
end
end