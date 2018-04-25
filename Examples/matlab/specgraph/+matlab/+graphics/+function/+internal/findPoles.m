function poleCandidates = findPoles(y, pixelCoordinatesX, pixelCoordinatesY)
  %

%   Copyright 2015 The MathWorks, Inc.

  % rescale, to avoid pole detection depending on figure geometry
  minX = min(pixelCoordinatesX);
  maxX = max(pixelCoordinatesX);
  minY = min(pixelCoordinatesY);
  maxY = max(pixelCoordinatesY);

  if maxX > minX
    pixelCoordinatesX = (pixelCoordinatesX - minX)/(maxX-minX);
  end
  if maxY > minY
    pixelCoordinatesY = (pixelCoordinatesY - minY)/(maxY-minY);
  end

  % We're looking for places with
  % (a) large magnitude function values,
  absY = abs(y);
  poleCandidates = absY > cutoff(absY);
  % (b) steep lines,
  slopes = diff(pixelCoordinatesY(:).')./diff(pixelCoordinatesX(:).');
  largeSlopes = abs(slopes) > 5;
  poleCandidates = poleCandidates & ([largeSlopes false] | [false largeSlopes]);
  % (c) curving away from a vertical line, i.e., f''*f ≥ 0, for at least two points on the left or right
  if numel(pixelCoordinatesX) > 2
    curve = diff(slopes);
    curveLeft = [curve curve(end) curve(end)].*y > 0;
    curveRight = [curve(1) curve(1) curve].*y > 0;
    poleCandidates = poleCandidates & ((curveLeft & [curveLeft(2:end) false]) | (curveRight & [false curveRight(1:end-1)]));
  end
  % (d) and the same for still higher derivatives
  if numel(pixelCoordinatesX) > 3
    curve3 = diff(curve);
    curveLeft = [curve3 curve3(end) curve3(end) curve3(end)].*y > 0;
    curveRight = [curve3(1) curve3(1) curve3(1) curve3].*y > 0;
    poleCandidates = poleCandidates & ((curveLeft & [curveLeft(2:end) false]) | (curveRight & [false curveRight(1:end-1)]));
  end

  if numel(pixelCoordinatesX) > 4
    curve4 = diff(curve3);
    curveLeft = [curve4 curve4(end) curve4(end) curve4(end) curve4(end)].*y > 0;
    curveRight = [curve4(1) curve4(1) curve4(1) curve4(1) curve4].*y > 0;
    poleCandidates = poleCandidates & ((curveLeft & [curveLeft(2:end) false]) | (curveRight & [false curveRight(1:end-1)]));
  end
  % (e) and the |y| values must be a local maximum
  poleCandidates = poleCandidates & findpeaks(absY);
  % (f) and do not consider points as pole candidates
  % if there are non-pole points with larger absolute values
  % and we do not have a sign change here
  maxAbsY = max(absY(~poleCandidates));
  signY = sign(y);
  poleCandidates = poleCandidates & ((absY > maxAbsY) | ...
    [(signY(1:end-1) ~= signY(2:end)) false] | [false (signY(1:end-1) ~= signY(2:end))]);
end

function v = cutoff(y)
  y = sort(y);
  if isempty(y)
    v=1;
  else
    v=y(ceil(0.95*numel(y)));
  end
end

function b = findpeaks(v)
  largerThanRight = v(1:end-1) >= v(2:end);
  largerThanLeft = v(2:end) >= v(1:end-1);
  b = [largerThanRight true] & [true largerThanLeft];
end
