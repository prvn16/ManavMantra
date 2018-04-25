function Z = imapplymatrix(multiplier, I, varargin)
%IMAPPLYMATRIX  Linear combination of color channels.
%    Y = IMAPPLYMATRIX(M, X) compute the linear combination of the rows
%    of M with the color channels of X.  If X is m-by-n-by-p, M must be
%    q-by-p, where q is in the range [1,p].  The output datatype is the
%    same as the type of X.
%
%    Y = IMAPPLYMATRIX(M, X, C) compute the linear combination of the rows
%    of M with the color channels of X, adding the corresponding constant
%    value from C to each combination.  C can either be a vector with the
%    same number of elements as the number of rows in M, or it is a scalar
%    applied to every channel.  The output datatype is the same as the type
%    of X.
%
%    Y = IMAPPLYMATRIX(..., OUTPUT_TYPE) returns the result of the linear
%    combination in an array of type OUTPUT_TYPE.
%
%    Example
%    -------
%
%    % Quick and dirty conversion of RGB values to grayscale.
%    RGB = imread('peppers.png');
%    M = [0.30, 0.59, 0.11];
%    gray = imapplymatrix(M, RGB);
%    figure
%    subplot(1,2,1), imshow(RGB), title('Original RGB')
%    subplot(1,2,2), imshow(gray), title('Grayscale conversion')
%
%    See also imlincomb, immultiply

%   Copyright 2010-2017 The MathWorks, Inc.

varargin = matlab.images.internal.stringToChar(varargin);
Z = images.internal.imapplymatrixAlgo(double(multiplier), I, varargin{:});
