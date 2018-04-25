function [yout,x] = imhist(varargin)
%IMHIST Compute histogram of image data.
%   COUNTS = IMHIST(I) computes a histogram for the gpuArray intensity
%   image I whose number of bins are specified by the image type.  If I is
%   a gpuArray grayscale image, IMHIST uses 256 bins as a default value.
%   The histogram counts are returned in gpuArray COUNTS.
%
%   COUNTS = IMHIST(I,N) computes a histogram with N bins for the gpuArray
%   intensity image I.
%
%   [COUNTS,X] = imhist(...) returns the histogram counts in COUNTS and the
%   bin locations in X so that stem(X,COUNTS) shows the histogram. Both
%   COUNTS and X are gpuArrays.
%
%   Class Support
%   -------------  
%   An input gpuArray intensity image can be uint8, int8, uint16, int16,
%   uint32, int32, single, or double.
%
%   Notes
%   -----
%   1.  The GPU implementation of IMHIST does not display the histogram. In 
%       order to display a histogram with histogram counts in COUNTS and  
%       bin locations in X, use stem(X,COUNTS).
%
%   2.  For intensity images, the N bins of the histogram are each
%       half-open intervals of width A/(N-1).
%  
%       For uint8, uint16, and uint32 intensity images, the p-th bin is the
%       half-open interval:
%
%           A*(p-1.5)/(N-1)  <= x  <  A*(p-0.5)/(N-1)
%
%       For int8, int16, and int32 intensity images, the p-th bin is the
%       half-open interval:
%  
%           A*(p-1.5)/(N-1) - B  <= x  <  A*(p-0.5)/(N-1) - B  
%
%       The intensity value is represented by "x". The scale factor A 
%       depends on the image class.  A is 1 if the intensity image is 
%       double or single; A is 255 if the intensity image is uint8 or int8;
%       A is 65535 if the intensity image is uint16 or int16; A is 
%       4294967295 if the intensity image is uint32 or int32. B is 128 if 
%       the image is int8; B is 32768 if the intensity image is int16; B is
%       2147483648 if the intensity image is int32.
%  
%   Example
%   -------
%        I = gpuArray(imread('pout.tif'));
%        imhist(I)
%
%   See also GPUARRAY/HISTEQ, GPUARRAY/HIST, IMHISTMATCH, GPUARRAY.

%   Copyright 2013-2016 The MathWorks, Inc.

nargoutchk(0,2);
switch nargout
    case {0,1}
        yout = images.internal.gpu.imhist(varargin{:});
    case 2
        [yout,x] = images.internal.gpu.imhist(varargin{:});
end
