function b = matricize(a)
%MATRICIZE Reshape an array to 2D.

%   Copyright 2014 The MathWorks, Inc.

if ismatrix(a)
    b = a;
else
    % Assume that any N-D array has a reshape method.
    b = reshape(a,size(a,1),[]); % makes a shared-data copy
end
