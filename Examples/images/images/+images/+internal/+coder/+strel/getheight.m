function height = getheight(idx, varargin)
%GETHEIGHT Internal helper function to get height of structuring element.

% Copyright 2013 The MathWorks, Inc.

  se = strel(varargin{:});
  if idx == 0
      height = se.getheight;
  else
      seq = getsequence(se);
      height = seq(idx).getheight;
  end
end