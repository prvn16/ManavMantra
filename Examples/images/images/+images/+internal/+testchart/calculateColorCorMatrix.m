function mat = calculateColorCorMatrix(measured_RGB,reference_RGB)
% calculateColorCorMatrix Calculate the color correction matrix using
%   simple least squares

measured_RGB = double(measured_RGB);
reference_RGB = double(reference_RGB);
appendedRGB = [measured_RGB ones(size(measured_RGB,1),1)];
mat = (appendedRGB' * appendedRGB) \ appendedRGB' * reference_RGB;



