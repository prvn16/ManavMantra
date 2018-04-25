function result = BoxIntegral(intImage, row, col, rows, cols) %#codegen

%   Copyright 2017 The MathWorks, Inc.

% Image dimensions
imgDim = size(intImage);
i_height = imgDim(1);
i_width = imgDim(2);
stepSize = i_height;

% Handle border cases for integral sum calculation
if row <= i_height
    r1 = row - 1;
else
    r1 = i_height - 1;
end

if col <= i_width
    c1 = col - 1;
else
    c1 = i_width - 1;
end

if row + rows <= i_height
    r2 = row + rows - 1;
else
    r2 = i_height - 1;
end

if col + cols <= i_width
    c2 = col + cols - 1;
else
    c2 = i_width - 1;
end

% Compute A, B, C, D (corner coordinates of the rectangular region)
A = single(0); B = single(0); C = single(0); D = single(0);

if (r1 >= 0 && c1 >= 0)
    A = intImage(c1 * stepSize + r1 + 1);
end

if (r1 >= 0 && c2 >= 0)
    B = intImage(c2 * stepSize + r1 + 1);
end

if (r2 >= 0 && c1 >= 0)
    C = intImage(c1 * stepSize + r2 + 1);
end

if (r2 >= 0 && c2 >= 0)
    D = intImage(c2 * stepSize + r2 + 1);
end

% Compute sum of pixels within the rectangular region
temp = A - B - C + D;

if 0 >= temp
    result = single(0);
else
    result = single(temp);
end

end   %End of BoxIntegral