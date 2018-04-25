function y = getElement(x,varargin)
%GETELEMENT Internal use only: get an individual indexed element of x
%   y = getElement(x, index1, index2, ... , indexN) returns an individual
%   indexed element of x at the position specified by the set of indices
%   (index1, index2, .. , indexN).
%   Each index specifies the position of the indexed element along a dimension.
%   The total number of indices must be less than the number of dimensions of x. 
%   Each index must be less than the size of x along that dimension.
%   This function helps to bypass the indexing issue with Fi objects 
%   (see record ID 549571).
%
%   Example:
%   The following function uses getElement and its counterpart setElement to
%   implement a method of Fi (say reversefi()) that reverses the contents of
%   input Fi array x:
%
%   function y = reversefi(x)
%   n = numberofelements(x);
%   y = x; % initialize y
%   for ind1 = 1:n
%      temp = getElement(x,ind1);
%      setElement(y, temp, n-ind1+1);
%   end
%
%   See also EMBEDDED.FI/SETELEMENT

%   Copyright 2009-2015 The MathWorks, Inc.

narginchk(2,inf);
overall_idx = elementGetSetChecksAndSingleIndex(x, varargin{:});
y = x.get_element(overall_idx);
