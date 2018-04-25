function n = getsequencelength(varargin)
%GETSEQUENCELENGTH Internal helper function to get the length of the 
% sequence.

% Copyright 2013 The MathWorks, Inc.

  se = strel(varargin{:});
  seq = se.getsequence();
  n = length(seq);

end