function S = spconvert(D)
%SPCONVERT Import from sparse matrix external format.
%
%   SPCONVERT(D), where D is a full matrix of size Nx3 or Nx4, constructs
%   the sparse matrix S defined by the columns of D.
%
%   For D of size Nx3, the columns [i, j, re] of D are used to construct S
%   such that S(i(k), j(k)) = re(k).
%
%   For D of size Nx4, the columns [i, j, re, im] of D are used to
%   construct S such that S(i(k), j(k)) = re(k) + 1i*im(k).
%
%   If D is a sparse matrix, then SPCONVERT returns D.
%
%   See also SPARSE, FULL.

%   Copyright 1984-2014 The MathWorks, Inc.

if ~issparse(D)
    [~,na] = size(D);
    if na == 3
       S = sparse(D(:,1),D(:,2),D(:,3));
    elseif na == 4
       S = sparse(D(:,1),D(:,2),D(:,3)+1i*D(:,4));
    else
       error(message('MATLAB:spconvert:WrongArraySize'))
    end
else
    S = D;
end
