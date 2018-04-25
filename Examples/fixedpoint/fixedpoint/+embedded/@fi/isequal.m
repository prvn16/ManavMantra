function t = isequal(varargin)
%ISEQUAL True if real-world values of two fi objects are equal
%
%   ISEQUAL(A,B,..) returns 1 if all the fi object inputs have the same 
%   real-world value. Otherwise, the function returns 0.
%
%   See also EMBEDDED.FI/EQ, EMBEDDED.FI/ISPROPEQUAL 

%   Thomas A. Bryan, 16 January 2004
%   Copyright 1999-2015 The MathWorks, Inc.


narginchk(2,inf);

% Get the first fi object on the input argument list to ensure that 
[A,firstobj_position] = firstobj(varargin{:});
t = true;
for k=1:length(varargin)
  if k ~= firstobj_position  % Don't compare A to itself
    t = binaryop_isequal(A,varargin{k});
  end
  if t==false, break, end
end
