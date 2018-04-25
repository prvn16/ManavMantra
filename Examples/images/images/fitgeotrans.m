function tform = fitgeotrans(movingPoints,fixedPoints,transformationType,optionalArg)
%  fitgeotrans Fit geometric transformation to control point pairs.
%     fitgeotrans takes pairs of control points and uses them to infer a
%     geometric transformation.
%  
%     TFORM = fitgeotrans(MOVINGPOINTS,FIXEDPOINTS,TRANSFORMATIONTYPE) fits
%     a geometric transformation to the control point pairs MOVINGPOINTS
%     and FIXEDPOINTS. MOVINGPOINTS is an M-by-2 double matrix containing
%     the X and Y coordinates of control points in the image you want to
%     transform. FIXEDPOINTS is an M-by-2 double matrix containing the X
%     and Y coordinates of control points in the base image.
%     TRANSFORMATIONTYPE can be 'nonreflectivesimilarity', 'similarity',
%     'affine', or 'projective'.
%
%     TFORM = fitgeotrans(MOVINGPOINTS,FIXEDPOINTS,'polynomial',DEGREE)
%     fits an images.geotrans.PolynomialTransformation2D object to control
%     point pairs MOVINGPOINTS and FIXEDPOINTS. The degree of the
%     polynomial transformation is specified by DEGREE. DEGREE may be 2, 3,
%     or 4.
%
%     TFORM = fitgeotrans(MOVINGPOINTS,FIXEDPOINTS,'pwl') fits an
%     images.geotrans.PiecewiseLinearTransformation2D object to control
%     point pairs MOVINGPOINTS and FIXEDPOINTS. This transformation maps
%     control points by breaking up the plane into local
%     piecewise-linear regions in which a different affine transformation
%     maps control points in each local region.
%
%     TFORM = fitgeotrans(MOVINGPOINTS,FIXEDPOINTS,'lwm',N)
%     fits an images.geotrans.LocalWeightedMeanTransformation2D object to
%     control point pairs MOVINGPOINTS and FIXEDPOINTS. The local weighted
%     mean transformation creates a mapping, by inferring a polynomial at
%     each control point using neighboring control points. The mapping at
%     any location depends on a weighted average of these polynomials. The
%     N closest points are used to infer a second degree polynomial
%     transformation for each control point pair. N can be as small as 6,
%     but making N small risks generating ill-conditioned polynomials.
%
%   Example
%   -------
%   I = checkerboard;
%   J = imrotate(I,30);
%   fixedPoints  = [11 11; 41 71];
%   movingPoints = [14 44; 70 81];
%   cpselect(J,I,movingPoints,fixedPoints);
%
%   tform = fitgeotrans(movingPoints,fixedPoints,'nonreflectivesimilarity');
%
%   % Use the tform estimate to resample rotated image J to register it with I.
%   % The regions of color (green and magenta) in the falsecolor overlay image 
%   % indicate error in the registration due to lack of precise correspondence
%   % in the control points.
%   Jregistered = imwarp(J,tform,'OutputView',imref2d(size(I)));
%   falsecolorOverlay = imfuse(I,Jregistered);
%   figure, imshow(falsecolorOverlay,'InitialMagnification','fit');
%
%   % Recover angle and scale by checking how a unit vector 
%   % parallel to the x-axis is rotated and stretched. 
%   u = [0 1]; 
%   v = [0 0]; 
%   [x, y] = transformPointsForward(tform, u, v); 
%   dx = x(2) - x(1); 
%   dy = y(2) - y(1); 
%   angle = (180/pi) * atan2(dy, dx) 
%   scale = 1 / sqrt(dx^2 + dy^2)
%
%  See also AFFINE2D, CPSELECT, IMWARP, PROJECTIVE2D,
%  images.geotrans.PiecewiseLinearTransformation2D,
%  images.geotrans.PolynomialTransformation2D,
%  images.geotrans.LocalWeightedMeanTransformation2D

%   Copyright 2013-2015 The MathWorks, Inc. 

% Validate movingPoints and fixedPoints
images.geotrans.internal.validateControlPoints(movingPoints,fixedPoints);

validTransStrings = {'projective','affine','similarity','nonreflectivesimilarity',...
                     'lwm','pwl','polynomial'};
                 
transformationType = validatestring(transformationType,validTransStrings,...
                                    mfilename);
       
% If the transformationType is polynomial or local weighted mean we required 4 input arguments.
% For all other transformationTypes, we require 3 input arguments.
if strcmpi(transformationType,'polynomial') || strcmpi(transformationType,'lwm')
    if nargin ~= 4
        error(message('images:geotrans:numRequiredArgsForTransformationInFitGeotrans',...
            mfilename,4,transformationType));
    end
else
    if nargin ~=3
        error(message('images:geotrans:numRequiredArgsForTransformationInFitGeotrans',...
            mfilename,3,transformationType));
    end
end
         
switch transformationType
    
    case 'projective'
        
        tform = findProjectiveTransform(movingPoints,fixedPoints);
        
    case 'affine'
        
        tform = findAffineTransform(movingPoints,fixedPoints);
        
    case 'nonreflectivesimilarity'
        
        tform = findNonreflectiveSimilarity(movingPoints,fixedPoints);
        
    case 'similarity'
        
        tform = findSimilarityTransform(movingPoints,fixedPoints);
        
    case 'lwm'
        
        tform = images.geotrans.LocalWeightedMeanTransformation2D(movingPoints,fixedPoints,optionalArg);
        
    case 'pwl'
        
        tform = images.geotrans.PiecewiseLinearTransformation2D(movingPoints,fixedPoints);
        
    case 'polynomial'
        
        tform = images.geotrans.PolynomialTransformation2D(movingPoints,fixedPoints,optionalArg);
        
    otherwise 
        
        assert(false,'Unexpected TransformationType encountered.');
        
end
        

function tform = findProjectiveTransform(uv,xy)
%
% For a projective transformation:
%
% u = (Ax + By + C)/(Gx + Hy + I)
% v = (Dx + Ey + F)/(Gx + Hy + I)
%
% Assume I = 1, multiply both equations, by denominator:
%
% u = [x y 1 0 0 0 -ux -uy] * [A B C D E F G H]'
% v = [0 0 0 x y 1 -vx -vy] * [A B C D E F G H]'
%
% With 4 or more correspondence points we can combine the u equations and
% the v equations for one linear system to solve for [A B C D E F G H]:
%
% [ u1  ] = [ x1  y1  1  0   0   0  -u1*x1  -u1*y1 ] * [A]
% [ u2  ] = [ x2  y2  1  0   0   0  -u2*x2  -u2*y2 ]   [B]
% [ u3  ] = [ x3  y3  1  0   0   0  -u3*x3  -u3*y3 ]   [C]
% [ u1  ] = [ x4  y4  1  0   0   0  -u4*x4  -u4*y4 ]   [D]
% [ ... ]   [ ...                                  ]   [E]
% [ un  ] = [ xn  yn  1  0   0   0  -un*xn  -un*yn ]   [F]
% [ v1  ] = [ 0   0   0  x1  y1  1  -v1*x1  -v1*y1 ]   [G]
% [ v2  ] = [ 0   0   0  x2  y2  1  -v2*x2  -v2*y2 ]   [H]
% [ v3  ] = [ 0   0   0  x3  y3  1  -v3*x3  -v3*y3 ]
% [ v4  ] = [ 0   0   0  x4  y4  1  -v4*x4  -v4*y4 ]
% [ ... ]   [ ...                                  ]  
% [ vn  ] = [ 0   0   0  xn  yn  1  -vn*xn  -vn*yn ]
%
% Or rewriting the above matrix equation:
% U = X * Tvec, where Tvec = [A B C D E F G H]'
% so Tvec = X\U.
%

[uv,normMatrix1] = images.geotrans.internal.normalizeControlPoints(uv);
[xy,normMatrix2] = images.geotrans.internal.normalizeControlPoints(xy);

minRequiredNonCollinearPairs = 4;
M = size(xy,1);
x = xy(:,1);
y = xy(:,2);
vec_1 = ones(M,1);
vec_0 = zeros(M,1);
u = uv(:,1);
v = uv(:,2);

U = [u; v];

X = [x      y      vec_1  vec_0  vec_0  vec_0  -u.*x  -u.*y;
     vec_0  vec_0  vec_0  x      y      vec_1  -v.*x  -v.*y  ];

% We know that X * Tvec = U
if rank(X) >= 2*minRequiredNonCollinearPairs 
    Tvec = X \ U;    
else
    error(message('images:geotrans:requiredNonCollinearPoints', minRequiredNonCollinearPairs, 'projective'))
end

% We assumed I = 1;
Tvec(9) = 1;

Tinv = reshape(Tvec,3,3);

Tinv = normMatrix2 \ (Tinv * normMatrix1);

T = inv(Tinv);
T = T ./ T(3,3);

tform = projective2d(T);


function tform = findAffineTransform(uv,xy)
%
% For an affine transformation:
%
%
%                     [ A D 0 ]
% [u v 1] = [x y 1] * [ B E 0 ]
%                     [ C F 1 ]
%
% There are 6 unknowns: A,B,C,D,E,F
%
% Another way to write this is:
%
%                   [ A D ]
% [u v] = [x y 1] * [ B E ]
%                   [ C F ]
%
% Rewriting the above matrix equation:
% U = X * T, where T = reshape([A B C D E F],3,2)
%
% With 3 or more correspondence points we can solve for T,
% T = X\U which gives us the first 2 columns of T, and
% we know the third column must be [0 0 1]'.

[uv,normMatrix1] = images.geotrans.internal.normalizeControlPoints(uv);
[xy,normMatrix2] = images.geotrans.internal.normalizeControlPoints(xy);

minRequiredNonCollinearPairs = 3;
M = size(xy,1);
X = [xy ones(M,1)];

% just solve for the first two columns of T
U = uv;

% We know that X * T = U
if rank(X)>=minRequiredNonCollinearPairs

    Tinv = X \ U;
else
    error(message('images:geotrans:requiredNonCollinearPoints', minRequiredNonCollinearPairs, 'affine'))    
end

% add third column
Tinv(:,3) = [0 0 1]';

Tinv = normMatrix2 \ (Tinv * normMatrix1);

T = inv(Tinv);
T(:,3) = [0 0 1]';

tform = affine2d(T);


function tform = findNonreflectiveSimilarity(uv,xy)
%
% For a nonreflective similarity:
%
% let sc = s*cos(theta)
% let ss = s*sin(theta)
%
%                   [ sc -ss
% [u v] = [x y 1] *   ss  sc
%                     tx  ty]
%
% There are 4 unknowns: sc,ss,tx,ty.
%
% Another way to write this is:
%
% u = [x y 1 0] * [sc
%                  ss
%                  tx
%                  ty]
%
% v = [y -x 0 1] * [sc
%                   ss
%                   tx
%                   ty]
%
% With 2 or more correspondence points we can combine the u equations and
% the v equations for one linear system to solve for sc,ss,tx,ty.
%
% [ u1  ] = [ x1  y1  1  0 ] * [sc]
% [ u2  ]   [ x2  y2  1  0 ]   [ss]
% [ ... ]   [ ...          ]   [tx]
% [ un  ]   [ xn  yn  1  0 ]   [ty]
% [ v1  ]   [ y1 -x1  0  1 ]   
% [ v2  ]   [ y2 -x2  0  1 ]    
% [ ... ]   [ ...          ]
% [ vn  ]   [ yn -xn  0  1 ]
%
% Or rewriting the above matrix equation:
% U = X * r, where r = [sc ss tx ty]'
% so r = X\U.
%

[uv,normMatrix1] = images.geotrans.internal.normalizeControlPoints(uv);
[xy,normMatrix2] = images.geotrans.internal.normalizeControlPoints(xy);

minRequiredNonCollinearPairs = 2;
M = size(xy,1);

x = xy(:,1);
y = xy(:,2);
X = [x   y  ones(M,1)   zeros(M,1);
     y  -x  zeros(M,1)  ones(M,1)  ];

u = uv(:,1);
v = uv(:,2);
U = [u; v];

% We know that X * r = U
if rank(X) >= 2*minRequiredNonCollinearPairs 
    r = X \ U;    
else
    error(message('images:geotrans:requiredNonCollinearPoints', minRequiredNonCollinearPairs, 'nonreflectivesimilarity'))        
end

sc = r(1);
ss = r(2);
tx = r(3);
ty = r(4);

Tinv = [sc -ss 0;
        ss  sc 0;
        tx  ty 1];
    
Tinv = normMatrix2 \ (Tinv * normMatrix1);

T = inv(Tinv);
T(:,3) = [0 0 1]';

tform = affine2d(T);

function tform = findSimilarityTransform(uv,xy)
%
% The similarities are a superset of the nonreflective similarities as they may
% also include reflection.
%
% let sc = s*cos(theta)
% let ss = s*sin(theta)
%
%                   [ sc -ss
% [u v] = [x y 1] *   ss  sc
%                     tx  ty]
%
%          OR
%
%                   [ sc  ss
% [u v] = [x y 1] *   ss -sc
%                     tx  ty]
%
% Algorithm:
% 1) Solve for trans1, a nonreflective similarity.
% 2) Reflect the xy data across the Y-axis, 
%    and solve for trans2r, also a nonreflective similarity.
% 3) Transform trans2r to trans2, undoing the reflection done in step 2.
% 4) Use TFORMFWD to transform uv using both trans1 and trans2, 
%    and compare the results, returning the transformation corresponding 
%    to the smaller L2 norm.

minRequiredNonCollinearPairs = 3;

M = size(uv,1);
if M < minRequiredNonCollinearPairs
    error(message('images:geotrans:requiredNonCollinearPoints', minRequiredNonCollinearPairs, 'similarity'))
end

% Solve for trans1
trans1 = findNonreflectiveSimilarity(uv,xy);

% Solve for trans2

% manually reflect the xy data across the Y-axis
xyR = xy;
xyR(:,1) = -1*xyR(:,1);

trans2r  = findNonreflectiveSimilarity(uv,xyR);

% manually reflect the tform to undo the reflection done on xyR
TreflectY = [-1  0  0;
              0  1  0;
              0  0  1];
              
trans2 = affine2d(trans2r.T * TreflectY);

% Figure out if trans1 or trans2 is better
xy1 = transformPointsForward(trans1,uv);
norm1 = norm(xy1-xy);

xy2 = transformPointsForward(trans2,uv);
norm2 = norm(xy2-xy);

if norm1 <= norm2
    tform = trans1;
else
    tform = trans2;
end









