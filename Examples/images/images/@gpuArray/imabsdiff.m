function Z = imabsdiff(varargin)
%IMABSDIFF Absolute difference of two images.
%   Z = IMABSDIFF(X,Y) subtracts each element in gpuArray Y from the
%   corresponding element in gpuArray X and returns the absolute difference
%   in the corresponding element of the output array Z.  X and Y are real,
%   nonsparse, numeric or logical arrays with the same class and size.  Z
%   has the same class and size as X and Y.  If X and Y are integer
%   arrays, elements in the output that exceed the range of the integer
%   type are truncated.  At least one of the inputs must be a gpuArray.
%
%   If X and Y are single or double arrays, you can use the expression 
%   ABS(X-Y) instead of this function.  If X and Y are logical arrays, you 
%   can use the expression XOR(A,B) instead of this function.
%
%   Example
%   -------
%   Display the absolute difference between a filtered image and the
%   original.
%
%       I = gpuArray(imread('cameraman.tif'));
%       J = imfilter(I,fspecial('gaussian'));
%       K = imabsdiff(I,J);
%       figure, imshow(K,[])
%
%   See also IMADD, IMCOMPLEMENT, IMDIVIDE, GPUARRAY/IMLINCOMB, IMSUBTRACT,
%            GPUARRAY.

%   Copyright 2012-2015 The MathWorks, Inc.

narginchk(2,2);

X = varargin{1};
Y = varargin{2};

% Both inputs must be real.
if ~(isreal(X) && isreal(Y))
    error(message('images:imabsdiff:gpuArrayReal'));
end

% Both inputs must be non-sparse
if issparse(X) || issparse(Y)
    error(message('images:validate:gpuExpectedNonSparse'));
end

% Convert both inputs to gpuArray's.
if ~isa(X,'gpuArray')
    X = gpuArray(X);
end

if ~isa(Y,'gpuArray')
    Y = gpuArray(Y);
end

% Both inputs need to be of the same size and class.
checkForSameSizeAndClass(X, Y);

datatype = classUnderlying(X);
if isempty(X)
    if strcmp(datatype,'logical')
        Z = gpuArray.false(size(X));
    else
        Z = gpuArray.zeros(size(X), datatype);
    end
else
    switch datatype
        case 'int8'
            Z = arrayfun(@imabsdiffint8,X,Y);
            
        case 'uint8'
            Z = arrayfun(@imabsdiffuint8,X,Y);
            
        case 'int16'
            Z = arrayfun(@imabsdiffint16,X,Y);
            
        case 'uint16'
            Z = arrayfun(@imabsdiffuint16,X,Y);
            
        case 'int32'
            Z = arrayfun(@imabsdiffint32,X,Y);
            
        case 'uint32'
            Z = arrayfun(@imabsdiffuint32,X,Y);
            
        case 'single'
            Z = arrayfun(@imabsdifffloatingpoint,X,Y);
            
        case 'double'
            Z = arrayfun(@imabsdifffloatingpoint,X,Y);
            
        case 'logical'
            Z = xor(X,Y);
            
        otherwise
            error(message('images:imabsdiff:unsupportedDataType'));
    end
end
end

function z = imabsdiffint8(x,y)
%IMABSDIFFINT8 compute absolute difference between pixels of type
%   int8.

z = int8( abs( int16(x) - int16(y) ) );
end

function z = imabsdiffuint8(x,y)
%IMABSDIFFUINT8 compute absolute difference between pixels of type
%   uint8.

z = uint8( abs( int16(x) - int16(y) ) );
end

function z = imabsdiffint16(x,y)
%IMABSDIFFINT16 compute absolute difference between pixels of type
%   int16.

z = int16( abs( int32(x) - int32(y) ) );
end

function z = imabsdiffuint16(x,y)
%IMABSDIFFUINT16 compute absolute difference between pixels of type
%   uint16.

z = uint16( abs( int32(x) - int32(y) ) );
end

function z = imabsdiffint32(x,y)
%IMABSDIFFINT32 compute absolute difference between pixels of type
%   int32.

z = int32( abs( double(x) - double(y) ) );
end

function z = imabsdiffuint32(x,y)
%IMABSDIFFUINT32 compute absolute difference between pixels of type
%   uint32.

z = uint32( abs( double(x) - double(y) ) );
end

function z = imabsdifffloatingpoint(x,y)
%IMABSDIFFFLOAT compute absolute difference between pixels of type
%   single/double.

z = abs( x - y );
end