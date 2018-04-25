function A = hanowa(n, d, classname)
%HANOWA Matrix whose eigenvalues lie on a vertical line.
%   A = GALLERY('HANOWA',N,D) takes an even integer N = 2*M and produces
%   an N-by-N block 2 x 2 matrix of the form:
%              [D*EYE(M)   -DIAG(1:M)
%               DIAG(1:M)   D*EYE(M)]
%
%   A has complex eigenvalues of the form: D +/- k*i,
%   for 1 <= k <= M. The default value of D is -1.

%   Reference:
%   E. Hairer, S.P. Norsett and G. Wanner, Solving Ordinary
%   Differential Equations I: Nonstiff Problems,
%   Springer-Verlag, Berlin, 1987. (pp. 86-87)
%
%   Copyright 1984-2005 The MathWorks, Inc.

if isempty(d), d = -ones(classname); end

m = n/2;
if round(m) ~= m
   error(message('MATLAB:hanowa:OddN'))
end

A = [ d*eye(m,classname) -diag(1:m)
      diag(1:m)           d*eye(m,classname)];
