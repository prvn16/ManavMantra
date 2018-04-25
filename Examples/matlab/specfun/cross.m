function c = cross(a,b,dim)
%CROSS  Vector cross product.
%   C = CROSS(A,B) returns the cross product of the vectors
%   A and B.  That is, C = A x B.  A and B must be 3 element
%   vectors.
%
%   C = CROSS(A,B) returns the cross product of A and B along the
%   first dimension of length 3.
%
%   C = CROSS(A,B,DIM), where A and B are N-D arrays, returns the cross
%   product of vectors in the dimension DIM of A and B. A and B must
%   have the same size, and both SIZE(A,DIM) and SIZE(B,DIM) must be 3.
%
%   Class support for inputs A,B:
%      float: double, single
%
%   See also DOT.

%   Copyright 1984-2016 The MathWorks, Inc.

% Special case: A and B are vectors
if isvector(a) && isvector(b)
    if (nargin == 2 && (length(a) ~= 3 || length(b) ~= 3)) || ...
       (nargin == 3 && (size(a,dim)~=3 || size(b,dim)~=3))
        error(message('MATLAB:cross:InvalidDimAorBForCrossProd'))
    end
    
    % Calculate cross product
    c = [a(2).*b(3)-a(3).*b(2);
        a(3).*b(1)-a(1).*b(3);
        a(1).*b(2)-a(2).*b(1)];
    if ~iscolumn(a) || ~iscolumn(b)
        c = c.';
    end
    
else % general case
    
    % Check dimensions
    if ~isequal(size(a),size(b))
        error(message('MATLAB:cross:InputSizeMismatch'));
    end
    
    if nargin == 2
        dim = find(size(a)==3,1);
        if isempty(dim)
            error(message('MATLAB:cross:InvalidDimAorB'));
        end
    elseif size(a,dim)~=3
        error(message('MATLAB:cross:InvalidDimAorBForCrossProd'))
    end
    
    % Permute so that DIM becomes the row dimension
    perm = [dim:max(length(size(a)),dim) 1:dim-1];
    a = permute(a,perm);
    b = permute(b,perm);
    
    % Calculate cross product
    c(3,:) = a(1,:).*b(2,:)-a(2,:).*b(1,:);
    c(1,:) = a(2,:).*b(3,:)-a(3,:).*b(2,:);
    c(2,:) = a(3,:).*b(1,:)-a(1,:).*b(3,:);
    c = reshape(c,size(a));
    
    % Post-process.
    c = ipermute(c,perm);
end