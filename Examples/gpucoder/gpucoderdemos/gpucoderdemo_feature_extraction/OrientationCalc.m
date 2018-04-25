function intPoints = OrientationCalc(intImage, intPoints) %#codegen

%   Copyright 2017 The MathWorks, Inc.
%
% This function computes orientation needed for rotation invariance for
% each of the extracted interest point. The orientation is computed by
% convolution with Haar wavelets of size 4s for pixels that are within a
% radius of 6s where 's' is the scale at which the interest point was detected

coder.gpu.kernelfun();

numPoints = length(intPoints);

for i = 1:numPoints
    ipt = intPoints(i);
    intPoints(i).orientation = getOrientation(intImage, ipt);
end

end

function orient = getOrientation(intImage, obj)

% Calculate orientation for a given interest point
fRound = @(value) double(floor(value+single(0.5)));
orient = single(0);

gauss25 = ...
    [ 0.02546481,	0.02350698,	0.01849125,	0.01239505,	0.00708017,	0.00344629,	0.00142946;
    0.02350698,	0.02169968,	0.01706957,	0.01144208,	0.00653582,	0.00318132,	0.00131956;
    0.01849125,	0.01706957,	0.01342740,	0.00900066,	0.00514126,	0.00250252,	0.00103800;
    0.01239505,	0.01144208,	0.00900066,	0.00603332,	0.00344629,	0.00167749,	0.00069579;
    0.00708017,	0.00653582,	0.00514126,	0.00344629,	0.00196855,	0.00095820,	0.00039744;
    0.00344629,	0.00318132,	0.00250252,	0.00167749,	0.00095820,	0.00046640,	0.00019346;
    0.00142946,	0.00131956,	0.00103800,	0.00069579,	0.00039744,	0.00019346,	0.00008024];

or_s = fRound(obj.scale);
or_r = fRound(obj.y);
or_c = fRound(obj.x);

id = [6,5,4,3,2,1,0,1,2,3,4,5,6];
idx = 1;

resX = zeros(1,109);
resY = zeros(1,109);
Ang  = zeros(1,109);

% calculate haar wavelet responses for points within radius of 6*scale
for ii = -6:6
    for jj = -6:6
        if(ii*ii + jj*jj < 36)
            gauss = single(gauss25(id(ii+7)+1,id(jj+7)+1));
            resX(idx) = gauss * haarX(intImage, or_r + jj * or_s, or_c +ii * or_s, 4 * or_s);
            resY(idx) = gauss * haarY(intImage, or_r + jj * or_s, or_c +ii * or_s, 4 * or_s);
            Ang(idx) = getAngle(resX(idx), resY(idx));
            idx = idx + 1;
        end
    end
end

% Calculate the dominant direction by rotating a pi/3 sector window around interest point
len = length(Ang);
ang1 = single(0);
max = single(0);

while ang1 < 2 * pi
    if (ang1 + pi/single(3.0) > 2 * pi)
        ang2 = ang1 - single(5.0) * pi/single(3.0);
    else
        ang2 = ang1 + pi/single(3.0);
    end
    
    sumX = single(0);
    sumY = single(0);
    
    for k = 1:len
        %  get angle of the interest point
        ang = Ang(k);
        
        % determine whether the point is within the window
        if (ang1 < ang2 && ang1 < ang && ang < ang2)
            sumX = sumX + resX(k);
            sumY = sumY + resY(k);
        else
            if (ang2 < ang1 && ...
                    ((ang > 0 && ang < ang2) || (ang > ang1 && ang < 2*pi) ))
                sumX = sumX + resX(k);
                sumY = sumY + resY(k);
            end
        end
        
    end
    
    
    % if the vector produced from this window is longer than all previous vectors then this forms the new dominant direction
    if (sumX*sumX + sumY*sumY > max)
        % store largest orientation
        max = sumX*sumX + sumY*sumY;
        orient = getAngle(sumX,sumY);
    end
    
    ang1 = ang1 + single(0.15);
end

end


function res = haarX(intImage, row,column,s)
res = BoxIntegral(intImage, row-s/2, column, s, s/2) ...
    -1 * BoxIntegral(intImage, row-s/2, column-s/2, s, s/2);
end

function res = haarY(intImage, row,column,s)
res = BoxIntegral(intImage, row, column-s/2, s/2, s) ...
    -1 * BoxIntegral(intImage, row-s/2, column-s/2, s/2, s);
end

function result = getAngle(X,Y)
if(X > 0 && Y >= 0)
    result =  atan(Y/X);
    result = single(result);
    return;
end

if(X < 0 && Y >= 0)
    result =  pi - atan(-Y/X);
    result = single(result);
    return;
end

if(X < 0 && Y < 0)
    result =  pi + atan(Y/X);
    result = single(result);
    return;
end

if(X > 0 && Y < 0)
    result =  2*pi - atan(-Y/X);
    result = single(result);
    return;
end

result = single(0);

end
