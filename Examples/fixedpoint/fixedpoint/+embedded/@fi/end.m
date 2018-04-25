function i = end(this,k,n)
%END    Last index of array
%   Refer to the MATLAB END reference page for more information.
%
%   See also END
    
%   Thomas A. Bryan, 24 February 2003
%   Copyright 1999-2012 The MathWorks, Inc.
    
s = size(this);

if k>length(s)
  % END is used in an index that exceeds the number of dimensions.
  % For example: A=magic(3); A(1,2,1,end,1,1)
  i = 1;
elseif k==n
  % END is used in the last index.  
  % For example:  A=magic(3);  A(2:end)
  i = prod(s(k:end));
else
  % The usual definition of end.
  i = s(k);
end
  
