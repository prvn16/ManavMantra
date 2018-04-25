function intImage = MyIntegralImage(grayImage) %#codegen

%   Copyright 2017 The MathWorks, Inc.
%
% The integral image representation for the 32-bit floating point grayscale
% image is computed in two steps. First, the integral sum is computed
% along the rows and next, the integral sum is computed along the columns

coder.gpu.kernelfun();

dims = size(grayImage);
 intImage = coder.nullcopy(zeros(dims(1),dims(2),'single'));

 % Calculate integral sum along rows
 coder.gpu.kernel();
 for i=1:dims(1)
     sum = single(0);
     for j=1:dims(2)
         sum = sum + grayImage(i,j);
         intImage(i,j) = sum;
     end
 end
 
 % Calculate integral sum along cols
 coder.gpu.kernel();
 for i=1:dims(2)
     sum = single(0);
     for j=1:dims(1)        
         sum = sum + intImage(j,i);
         intImage(j,i) = sum;
     end
 end
 
end

