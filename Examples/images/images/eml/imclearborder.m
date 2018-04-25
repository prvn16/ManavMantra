function outputImage = imclearborder(varargin) %#codegen
% Copyright 2013 The MathWorks, Inc.

coder.internal.prefer_const(varargin);
narginchk(1,2);

im = varargin{1};
validateattributes(im, {'numeric' 'logical'}, {'nonsparse' 'real'}, ...
           mfilename, 'IM', 1); %#ok<*EMCA>

if nargin < 2
    conn = conndef(numel(size(im)),'maximal');
else
    conn = varargin{2};
    iptcheckconn(conn,mfilename,'CONN',2);
end

% Skip NaN check here; it will be done by imreconstruct if input
% is double.

binaryConn = images.internal.getBinaryConnectivityMatrix(conn);

marker = im;

% Now figure out which elements of the marker image are connected to the
% outside, according to the connectivity definition.
binaryIm = true(size(marker));
padSize = ones(1,ndims(binaryIm));
paddedIm = padarray(binaryIm, padSize, 0, 'both');

erodedIm = imerode(paddedIm,binaryConn);

if (ismatrix(erodedIm))
    borderlessIm = erodedIm(2:size(erodedIm,1)-1, 2:size(erodedIm,2)-1);
else %imerode supports only upto 3-d images
    borderlessIm = erodedIm(2:size(erodedIm,1)-1, 2:size(erodedIm,2)-1, 2:size(erodedIm,3)-1);
end

% Set all elements of the marker image that are not connected to the
% outside to the lowest possible value.
if ~isempty(marker)
    if islogical(marker) 
        marker(borderlessIm) = false;
    else
        marker(borderlessIm) = -Inf;
    end
end

im2 = imreconstruct(marker, im, binaryConn);
if islogical(im2)
    outputImage = im & ~im2;
else
    outputImage = im - im2;
end



