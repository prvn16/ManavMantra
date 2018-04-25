function themap = vga
%VGA    The Windows color map for 16 colors
%   VGA returns a 16-by-3 matrix containing the colormap
%   used by Windows for 4-bit color. 
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(vga)
%
%   See also HSV, GRAY, HOT, COOL, BONE, COPPER, FLAG, 
%   COLORMAP, RGBPLOT.

%   P. Fry, 6-25-98.
%   Copyright 1984-2004 The MathWorks, Inc.

themap = [1    1    1   
          0.75 0.75 0.75
	  1    0    0   
	  1    1    0   
	  0    1    0   
	  0    1    1   
	  0    0    1   
	  1    0    1   
	  0    0    0   
	  0.5  0.5  0.5 
	  0.5  0    0   
	  0.5  0.5  0   
	  0    0.5  0   
	  0    0.5  0.5 
	  0    0    0.5 
	  0.5  0    0.5]; 