function TF = isflat(idx, varargin)
%ISFLAT Internal helper function which returns true for flat structuring 
% element. 

% Copyright 2013 The MathWorks, Inc.

  se = strel(varargin{:});
  if idx == 0
      TF = se.isflat;
  else
      seq = getsequence(se);
      TF = seq(idx).isflat;
  end
end