function B  = fibermetric(A, varargin)
%FIBERMETRIC Enhance elongated or tubular structures in images.
%   B = FIBERMETRIC(A) enhances tubular structures in intensity image A
%   using Hessian based multiscale filtering. B contains the maximum
%   response of the filter at a thickness that approximately matches the
%   size of the tubular structure to detect.
%
%   B = FIBERMETRIC(A, THICKNESS) enhances the tubular structures of
%   thickness THICKNESS in A. THICKNESS is a scalar or a vector in pixels
%   which characterizes the thickness of tubular structures. It should be
%   of the order of the width of the tubular structures in the image
%   domain. When not provided, THICKNESS is [4, 6, 8, 10, 12, 14].
%
%   B = FIBERMETRIC(___, Name, Value) enhances the tubular structures in
%   the image using name-value pairs to control different aspects of the
%   filtering algorithm.
%
%   Parameters include:
%   'StructureSensitivity' - Specifies the sensitivity/threshold for
%                            differentiating the tubular structure from the
%                            background and is dependent on the gray scale
%                            range of the image. Default value: half the
%                            maximum of Hessian norm.
%
%   'ObjectPolarity' - Specifies the polarity of the tubular structures
%   with respect to the background. Available options are:
%
%           'bright'     : The structure is brighter than the background.(Default)
%           'dark'       : The structure is darker than the background.
%
%   Class Support
%   -------------
%   Input image A must be a 2D grayscale image and can be of class uint8,
%   int8, uint16, int16, uint32, int32, single, or double. It must be
%   nonsparse. The output variable B is of class single.
%
%   Example
%   -------
%       % Find threads approximately 7 pixels thick
%       A = imread('threads.png');
%       B = fibermetric(A, 7, 'ObjectPolarity', 'dark', 'StructureSensitivity', 7);
%       figure; imshow(B); title('Possible tubular structures 7 pixels thick')
%       C = B > 0.15;
%       figure; imshow(C); title('Thresholded result')
%
%   Reference
%   ---------
%   Frangi, Alejandro F., et al. "Multiscale vessel enhancement filtering."
%   Medical Image Computing and Computer-Assisted Intervention -- MICCAI 1998.
%   Springer Berlin Heidelberg, 1998. 130-137
%
%   See also edge, imgradient.

%   Copyright 2016-2017 The MathWorks, Inc.

args = matlab.images.internal.stringToChar(varargin);
parsedInputs = parseInputs(A, args{:});

thickness   = parsedInputs.Thickness;
c           = parsedInputs.StructureSensitivity;
objPolarity = lower(parsedInputs.ObjectPolarity);

% Convert the values to double/single.
classOriginalData = class(A); 
switch (classOriginalData)
case 'uint32'
    A = double(A);
case 'double'
otherwise
    A = single(A);
end

% Constant threshold.
beta  = 0.5;

B = zeros(size(A), 'like', A);

c = cast(c, 'like', A);
for i = 1:numel(thickness)
    % Correcting for sigma using pixel thickness since the filter size
    % is 2*ceil(3*sigma)
    sigma = thickness(i)/6;

    [Gxx, Gyy, Gxy]     = images.internal.hessian2D(A, sigma);
    [eigVal1, eigVal2]  = images.internal.find2DEigenValues(Gxx, Gyy, Gxy);

    absEigVal1 = abs(eigVal1);
    absEigVal2 = abs(eigVal2);

    Rb = absEigVal1 ./ absEigVal2;
    Ssquare = eigVal1.^2 + eigVal2.^2;

    if isempty(c)
        maxHessianNorm = max([max(absEigVal1(:)), max(absEigVal2)]);
        c = 0.5*maxHessianNorm;      
    end

    V = exp(-(Rb.^2)/(2*beta^2)) .* (1 - (exp(-Ssquare/(2*c^2))));

    switch (objPolarity)
    case 'bright'
        V(eigVal2(:) > 0) = 0;
    case 'dark'               
        V(eigVal2(:) < 0) = 0;
    end

    % Remove NaN values.
    V(~isfinite(V)) = 0;
    B = max(B, V);
end

% Output should always be single.
B = single(B);
    
end


function parsedInputs = parseInputs(A, varargin)

narginchk(1,6);

validateImage(A)

parser = inputParser();
parser.PartialMatching = true;
parser.addOptional('Thickness', 4:2:14, @validateThickness);
parser.addParameter('StructureSensitivity', [], @validateStructureSensitivity);
parser.addParameter('ObjectPolarity','bright', @validateObjectPolarity);
parser.parse(varargin{:});
parsedInputs = parser.Results;

parsedInputs.ObjectPolarity = validatestring(parsedInputs.ObjectPolarity, {'bright','dark'});

end


function validateImage(A)

allowedImageTypes = {'uint8', 'uint16', 'uint32', 'double', 'single', 'int8', 'int16', 'int32'};
validateattributes(A, allowedImageTypes, {'nonempty',...
    'nonsparse', 'real', 'finite', '2d'}, mfilename, 'A', 1);
anyDimensionOne = any(size(A) == 1);
if (isvector(A) || anyDimensionOne)
    error(message('images:fibermetric:imageNot2or3D'));
end

end


function tf = validateThickness(thickness)

validateattributes(thickness, {'numeric'}, ...
    {'integer', 'nonsparse', 'nonempty', 'positive', 'finite', 'vector'}, ...
    mfilename, 'THICKNESS', 2);

tf = true;

end


function tf = validateStructureSensitivity(x)

validateattributes(x, {'numeric'}, ...
    {'scalar', 'real', 'positive', 'finite', 'nonsparse', 'nonempty'}, ...
    mfilename, 'StructureSensitivity');

tf = true;

end


function tf = validateObjectPolarity(x)

validateattributes(x, {'char'}, {}, mfilename, 'ObjectPolarity');
validatestring(x, {'bright','dark'}, mfilename, 'ObjectPolarity');

tf = true;

end
