function out = isschur(T, flag)
%ISSCHUR Determine whether T has Schur form conformed with LAPACK
%   ISSCHUR(T) returns true if matrix T is upper quasi-triangular for real
%   matrix, or upper triangular for complex matrix.
%
%   ISSCHUR(T, 'complex') returns true if T is upper triangular.
%
%   ISSCHUR(T, 'real') is same as ISSCHUR(T).

%   Nicholas J. Higham and Samuel D. Relton
%   Copyright 2014-2015 The MathWorks, Inc.

out = true;
if isscalar(T)
    return;
end

n = size(T,1);
if ~ismatrix(T) || n ~= size(T,2)
    out = false;
    return;
end

checkComplexForm = false;
if nargin > 1
   checkComplexForm = strcmp(flag,'complex');
end

if isreal(T) && ~checkComplexForm
    % Check that all elements below 1st subdiagonal are 0.
    if ~isbanded(T, 1, n)
        out = false;
        return;
    end
    for k = 1:n-1
        if T(k+1,k) ~= 0 
            % Check that 1st subdiagonal is of valid form.
            % It cannot have two nonzero adjacent entries.
            if k ~= n-1 && T(k+2,k+1) ~= 0
                out = false;
                return
            end
            % Check that 2x2 block has the required form.
            if T(k,k) ~= T(k+1,k+1) || sign(T(k+1,k)) * sign(T(k,k+1)) ~= -1  
                out = false;
                return
            end
        end
    end
else
    out = istriu(T);  % upper triangular for complex Schur form.
end
    