%ORDEIG    Eigenvalues of quasitriangular matrices.
%   E = ORDEIG(T) takes a quasitriangular Schur matrix T (typically
%   produced by SCHUR) and returns the vector E of eigenvalues in 
%   their order of appearance down the diagonal of T.
% 
%   E = ORDEIG(AA,BB) takes a quasitriangular matrix pair AA, BB
%   (typically produced by QZ) and returns the generalized eigenvalues 
%   in their order of appearance down the diagonal of AA-t*BB.
% 
%   ORDEIG is an order-preserving version of EIG for use with ORDSCHUR 
%   and ORDQZ. It is also faster than EIG for quasitriangular matrices.
% 
%   Example:
%     a = rand(10);
%     [u,t] = schur(a);
%     e = ordeig(t)
%     % Move eigenvalues with magnitude < 0.5 to the  
%     % upper-left corner of T
%     [u,t] = ordschur(u,t,abs(e)<0.5);
%     abs(ordeig(t))
%        
%   See also ORDSCHUR, ORDQZ, SCHUR, QZ, EIG.

%   Copyright 1984-2005 The MathWorks, Inc.
%   Built-in function.
