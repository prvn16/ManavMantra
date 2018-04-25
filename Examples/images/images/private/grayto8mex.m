function varargout = grayto8mex(varargin)
%GRAYTO8MEX Scale and convert grayscale image to uint8.
%   B = GRAYTO8MEX(A) converts the double array A to uint8 by
%   scaling A by 255 and then rounding.  NaN's in A are converted
%   to 0.  Values in A greater than 1.0 are converted to 255;
%   values less than 0.0 are converted to 0.
%
%   B = GRAYTO8MEX(A) converts the uint16 array A by scaling the
%   elements of A by 1/257, rounding, and then casting to uint8.
%
%   Copyright 1993-2013 The MathWorks, Inc. 

%#mex

error('images:grayto8:missingMEXFile', 'Missing MEX-file: %s', mfilename);
