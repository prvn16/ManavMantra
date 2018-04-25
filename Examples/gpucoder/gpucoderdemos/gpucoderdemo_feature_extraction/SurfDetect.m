function intPoints = SurfDetect(inputImage) %#codegen

%                   Copyright 2017 The MathWorks, Inc.
%
%                   FEATURE EXTRACTION USING SURF
% 
% DESCRIPTION:
% This code performs feature extraction, which is the first part of the SURF 
% (Speeded-Up Robust Features) algorithm for object recognition. 
%
% INPUT:  The input image provided should be an 8-bit RGB or 8-bit grayscale image. 
% OUTPUT: The output of this code is an array of extracted interest points. These 
%         interest points are also depicted over the input image in a figure window.
%
% REFERENCES:
% 1. SURF: Speeded-Up Robust Features by Herbert Bay, Tinne Tuytelaars and Luc Van Gool
% 2. Notes on the OpenSURF Library by Christopher Evans

coder.gpu.kernelfun();

% Convert the input image to 32-bit floating point grayscale image
grayImage = Convert32bitFPGray(inputImage);


% Calculate the integral image of the grayscale image obtained above
intImage = MyIntegralImage(grayImage);


% Perform convolution with box filters of various sizes and capture responses
responseMap = FastHessian(intImage);


% Process upto 2000 interest points and set the maximum bound of 'intPoints' to 2000
coder.varsize( 'intPoints', [1,2000], [false, true]);


% Perform non-maximal suppression to filter out useful and strongest interest points
if ~coder.target('MATLAB')
    intPoints = NonMaxSuppression_gpu(intImage, responseMap);
else
    intPoints = NonMaxSuppression(intImage, responseMap);
end


% Calculate orientation for each of the extracted interest points
intPoints = OrientationCalc(intImage, intPoints);

end
