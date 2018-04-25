function nhood = getnhood(idx, varargin)
%GETNHOOD Internal helper function to get structuring element neighborhood.

% Copyright 2013 The MathWorks, Inc.

  se = strel(varargin{:});
  if idx==0
      % apply getnhood() on the strel object
      nhood = se.getnhood;
  else
      % apply getnhood() on a decomposed strel object indexed by
      % the input, idx
      seq = getsequence(se);
      nhood = seq(idx).getnhood;
  end
end