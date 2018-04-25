function grayImage32bit = Convert32bitFPGray(inputImage) %#codegen

%   Copyright 2017 The MathWorks, Inc.
%
% The 8-bit RGB image provided as an input to this function is converted to
% a 8-bit grayscale image. This 8-bit grayscale image is then converted to
% 32-bit floating point representation

coder.gpu.kernelfun();

if ndims(inputImage) == 3
    grayImage = rgb2gray(inputImage);
else
    grayImage = inputImage;
end

grayImage32bit = single(grayImage)/255;

end
