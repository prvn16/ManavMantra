function checkRangeVector(lim)

%   Copyright 2015 The MathWorks, Inc.

  if ~((isrow(lim) && numel(lim) == 2 && isreal(lim) && all(isfinite(lim)) && lim(1) <= lim(2)))
    throwAsCaller(MException(message('MATLAB:fplot:RangeVector')));
  end
end
