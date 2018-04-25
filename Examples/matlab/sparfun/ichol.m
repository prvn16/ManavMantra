%ICHOL  Sparse Incomplete Cholesky factorization 
%   
%   L = ICHOL(A) computes the incomplete Cholesky factorization of A with
%   zero-fill.
%   
%   L = ICHOL(A,OPTS) performs the incomplete Cholesky factorization 
%   of A. OPTS is a structure with up to five fields:
%      type     --- Type of factorization.
%      droptol  --- Drop tolerance when type is 'ict'.
%      michol   --- Indicates whether to perform Modified incomplete Cholesky.
%      diagcomp --- Perform Compensated incomplete Cholesky with the specified
%                   coefficient.
%      shape    --- Determines which triangle is referenced and returned.
%
%   The value of field 'type' is a string indicating which flavor of incomplete
%   Cholesky to perform.  Valid values of this field are 'nofill' and 'ict'.
%   The 'nofill' variant performs incomplete Cholesky with zero-fill (IC(0)).
%   The 'ict' variant performs incomplete Cholesky with threshold dropping
%   (ICT).  The default value is 'nofill'.
%             
%   The value of field 'droptol' is a non-negative scalar used as a drop
%   tolerance when performing ICT.  Elements which are smaller in magnitude
%   than a local drop tolerance are dropped from the resulting factor except
%   for the diagonal element which is never dropped.  The local drop tolerance
%   at step j of the factorization is norm(A(j:end,j),1)*droptol.  'droptol' is
%   ignored if 'type' is 'nofill'.  The default value is 0.
%
%   The value of field 'michol' may be 'on' or 'off' and it indicates whether
%   or not modified incomplete Cholesky (MIC) is performed.  When performing
%   MIC, the diagonal is compensated for dropped elements to enforce the
%   relationship A*e = L*L'*e where e = ones(size(A,2),1)).  The default value
%   is 'off'.
% 
%   The value of field 'diagcomp' is a real non-negative scalar used as a
%   global diagonal shift alpha in forming the incomplete Cholesky factor.
%   That is, instead of performing incomplete Cholesky on A, the factorization
%   of A + alpha*diag(diag(A)) is formed.  The default value is 0.
%
%   The value of field 'shape' determines which triangle to reference and which
%   triangle to return.  Valid values for this field are 'upper' and 'lower'.
%   If 'upper' is specified, only the upper triangle of A is referenced and R
%   is constructed such that A is approximated by R'*R.  If 'lower' is
%   specified, only the lower triangle of A is referenced and L is constructed
%   such that A is approximated by L*L'.  The default value is 'lower'.
%   
%   The factor given by this routine may be useful as a preconditioner
%   for a system of linear equations being solved by iterative methods such 
%   as PCG or MINRES.
%
%   Example: 
%       A = delsq(numgrid('L',62));
%       L = ichol(A);
%       xor(tril(A), L)
%       norm(A - (L*L').*spones(A), 'fro')
%
%   This shows that the lower triangle of A and L have the same pattern and
%   that A and L*L' agree on the nonzero pattern of A.
%
%   Example:
%       A = delsq(numgrid('L',62));
%       L = ichol(A,struct('type','ict','droptol',1e-02,'michol','off'));
%       norm(A - L*L', 'fro')/norm(A,'fro')
%
%   This shows that the relative error between A and L*L' is on the same 
%   order as the given drop tolerance.
%
%   Example:
%       A = delsq(numgrid('L',62));
%       L = ichol(A,struct('type','ict','droptol',1e-02,'michol','on'));
%       e = ones(size(A,2),1);
%       norm(A*e - L*L'*e, 'fro')
%
%   This shows that L satisfies the condition A*e = L*L'*e, which is what 
%   Modified Incomplete Cholesky should produce.  
%   
%   ICHOL works only for sparse matrices.
%   
%   See also ILU, CHOL, PCG, MINRES.

%   Copyright 2010-2013 The MathWorks, Inc. 
%   Built-in function.
