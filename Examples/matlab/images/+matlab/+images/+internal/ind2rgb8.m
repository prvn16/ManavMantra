function RGB = ind2rgb8(X, CMAP)
%IND2RGB8 Convert an indexed image to a uint8 RGB image.
%
%   RGB = IND2RGB8(X,CMAP) creates a truecolor (RGB) image of class uint8.  X
%   must be uint8, uint16, uint32, or double, and CMAP must be a valid MATLAB
%   colormap.
%
%   Example 
%   -------
%  
%      % Convert the clown image to RGB.
%      load clown
%      RGB = ind2rgb8(X, cmap);
%      image(RGB);
%
%   See also IND2RGB.

%   Copyright 1996-2017 The MathWorks, Inc.

RGB = matlab.images.internal.ind2rgb8c(real(X), real(CMAP));
