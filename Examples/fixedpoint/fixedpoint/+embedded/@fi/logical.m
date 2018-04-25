function t = logical(A)
%LOGICAL Convert numeric values to logical
%   Refer to the MATLAB LOGICAL reference page for more information.
% 
%   See also LOGICAL

%   Copyright 2004-2012 The MathWorks, Inc.
%     

if ~isreal(A)
  error(message('MATLAB:nologicalcomplex'));
end
t = (A~=0);
