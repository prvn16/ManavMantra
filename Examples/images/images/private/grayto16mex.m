function varargout = grayto16mex(varargin)
%GRAYTO16MEX Scale and convert grayscale image to uint16.
%   B = GRAYTO16MEX(A) converts the double array A to uint16 by
%   scaling A by 65535 and then rounding.  NaN's in A are converted
%   to 0.  Values in A greater than 1.0 are converted to 65535;
%   values less than 0.0 are converted to 0.
%
%   B = GRAYTO16MEX(A) converts the uint8 array A by scaling the
%   elements of A by 257 and then casting to uint8.
%
%   Copyright 1993-2013 The MathWorks, Inc. 

%#mex

error('images:grayto16:missingMEXFile', 'Missing MEX-file: %s', mfilename);

