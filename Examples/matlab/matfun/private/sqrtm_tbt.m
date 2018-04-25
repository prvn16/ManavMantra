function R = sqrtm_tbt(T)
%SQRTM_TBT Square root of 2x2 matrix from block diagonal of Schur form.
%
%   Input T must be a 2x2 matrix from the block diagonal of a previously
%   computed Schur form.

% References:
%   N. J. Higham, Computing real square roots of a real
%       matrix, Linear Algebra and Appl., 88/89 (1987), pp. 405-430.
%   A. Bjorck and S. Hammarling, A Schur method for the square root of a
%       matrix, Linear Algebra and Appl., 52/53 (1983), pp. 127-140.
%   E. Deadman, N. J. Higham and R. Ralha, Blocked Schur algorithms for
%       computing the matrix square root, Lecture Notes in Comput. Sci.
%       7782, Springer-Verlag, (2013), pp. 171-182.
%   
%   Nicholas J. Higham and Samuel D. Relton
%   Copyright 2014-2015 The MathWorks, Inc.

if T(2,1) ~= 0
    % Compute square root of 2x2 quasitriangular block.
    % The algorithm assumes the special structure of real Schur form
    t11 = T(1,1); % t22 must equal to t11
    t12 = T(1,2);
    t21 = T(2,1);
    mu = sqrt(-t21*t12);
    if t11 > 0
        alpha = sqrt( (t11 + hypot(t11, mu))/2 );
    else
        alpha = mu / sqrt( 2*(-t11 + hypot(t11, mu)) );
    end
    R(2,2) = alpha;
    R(1,1) = alpha;
    R(2,1) = t21/(2*alpha);
    R(1,2) = t12/(2*alpha);
else
    % Compute square root of 2x2 upper triangular block.
    t11 = T(1,1);
    r11 = sqrt(t11);
    t22 = T(2,2);
    r22 = sqrt(t22); 
    R(2,2) = r22;
    R(1,1) = r11;
    R(1,2) = T(1,2)/(r11 + r22);
end
