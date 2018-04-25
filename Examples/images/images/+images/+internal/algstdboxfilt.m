function J = algstdboxfilt(I,hsize)
% Main algorithm used by stdfilt function for box nhood. See stdfilt for
% more details

% No input validation is done in this function.

% Copyright 2015 The MathWorks, Inc.

n = prod(hsize);
n1 = n - 1;

dim = numel(hsize);
if dim==3
    integFunction = @integralImage3;
    boxFunction = @integralBoxFilter3;
elseif dim==2
    integFunction = @integralImage;
    boxFunction = @integralBoxFilter;
end

if n ~= 1
    
    I = padarray(I, (hsize-1)/2, 'symmetric','both');
    
    intI  = integFunction(I);
    intI2 = integFunction(I.^2);
    
    conv1 = boxFunction(intI2, hsize, 'NormalizationFactor', 1/n1);
    conv2 = ( boxFunction(intI ,hsize, 'NormalizationFactor', 1/sqrt(n*n1)) ).^2;
    
    J = sqrt(max((conv1 - conv2),0));
else
    J = zeros(size(I));
end
