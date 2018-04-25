function predicted = cppredict(pick,movingPoints,fixedPoints,predictFixed,constrainMovingPoint,constrainFixedPoint)
%CPPREDICT Predict match for a new control point.

%   Copyright 2005-2013 The MathWorks, Inc.

% constrainMovingPoint and constrainFixedPoint are boundary constraint
% functions used to clip predicted points within the extent of the image
% fixed/moving image boundaries.

nvalidpairs = size(movingPoints,1);

if nvalidpairs < 2
  % this is an assertion in case caller sends over too few pairs
  error(message('images:cppredict:tooFewPairs'));    

else
  % predict
  switch nvalidpairs
    case 2
      method = 'NonreflectiveSimilarity';
    case 3
      method = 'affine';
    otherwise
      method = 'projective';
  end

    t = fitgeotrans(movingPoints,fixedPoints,method);

    xy = pick;
    if predictFixed
      % predict base
      predicted = transformPointsForward(t,xy);
      predicted = constrainFixedPoint(predicted);
    else
      % predict input
      predicted = transformPointsInverse(t,xy);
      predicted = constrainMovingPoint(predicted);
    end
    
end
