function [offsets, heights] = getneighbors(idx, varargin)
%GETNEIGHBORS Internal helper function to get structuring element neighbor 
% locations and heights

% Copyright 2013 The MathWorks, Inc.

  se = strel(varargin{:});
  if idx == 0
      [offsets, heights] = se.getneighbors;
  else
      seq = getsequence(se);
      [offsets, heights] = seq(idx).getneighbors;
  end
end