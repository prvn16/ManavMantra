function [X, junk] = readfits(filename)
%READFITS Read image data from a FITS file.
%   A = READFITS(FILENAME) reads the unscaled data from the primary HDU
%   of a FITS file.
%
%   See also FITSREAD.

%   Copyright 1984-2013 The MathWorks, Inc.


warning(message('MATLAB:imagesci:readfits:use_fitsread'));

X = fitsread(filename, 'raw');
junk = [];
