function [ magnitude ] = sobelEdge( Image )
%#codegen

%   Copyright 2017 The MathWorks, Inc.


maskX = single([-1 0 1 ; -2 0 2; -1 0 1]);
maskY = single([-1 -2 -1 ; 0 0 0 ; 1 2 1]);

coder.gpu.kernelfun();



resX = conv2(Image, maskX, 'same');
resY = conv2(Image, maskY, 'same');

magnitude = sqrt(resX.^2 + resY.^2);
thresh = magnitude < 0.4;
magnitude(thresh) = 0;

end
