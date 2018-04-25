%ILU  Sparse Incomplete LU factorization
%
%    The factors given by this factorization may be useful as
%    preconditioners for a system of linear equations being solved by
%    iterative methods such as BICG (BiConjugate Gradients) and  GMRES
%    (Generalized Minimum Residual Method).
%
%    ILU(A) computes the incomplete LU factorization of A with zero level of
%    fill in.
%
%    ILU(A,SETUP) performs the incomplete LU factorization of A.  SETUP is
%    a structure with up to five fields:
%        type    --- type of factorization
%        droptol --- the drop tolerance of incomplete LU
%        milu    --- modified incomplete LU
%        udiag   --- replace zeros on the diagonal of U
%        thresh  --- the pivot threshold
%
%    type may be 'nofill' which is the ILU factorization with zero level of
%    fill in, known as ILU(0), 'crout' which is the Crout Version of ILU,
%    known as ILUC, or 'ilutp' which is the ILU factorization with
%    threshold and pivoting.  If type is not specified the ILU factorization
%    with 0 level of fill in will be performed.  Pivoting is never 
%    performed with type 'nofill' and with type 'crout'.
%
%    droptol is a non-negative scalar used as the drop tolerance which
%    means that all entries which are smaller in magnitude than the local
%    drop tolerance, which is droptol * NORM of the column of A for the
%    column and droptol * NORM of the row of A for the row, are "dropped"
%    from L or U.  The only exception to this dropping rule is the diagonal
%    of the upper triangular factor U which is never dropped.  Note that
%    entries of the lower triangular factor L are tested before being
%    scaled by the pivot.  Setting droptol = 0 produces the complete LU
%    factorization, which is the default.
%
%    milu stands for modified incomplete LU factorization.  Its value can
%    be 'row' (row-sum), 'col' (column-sum), or 'off'.  When milu is equal
%    to 'row', the diagonal element of the upper triangular factor U is
%    compensated in such a way as to preserve row sums.  That is, the
%    product A*e is equal to L*U*e, where e is the vector of ones.  When
%    milu is equal to 'col', the diagonal of the upper triangular factor U
%    is compensated so that column sums are preserved.  That is, the
%    product e'*A is equal to the product e'*L*U.  The default is 'off'.
%
%    udiag is either 0 or 1.  If it is 1, any zero diagonal entries of the
%    upper triangular factor U are replaced by the local drop tolerance in
%    an attempt to avoid a singular factor.  The default is 0.
%
%    thresh is a pivot threshold in [0,1].  Pivoting occurs when the
%    diagonal entry in a column has magnitude less than thresh times the
%    magnitude of any sub-diagonal entry in that column.  thresh = 0 forces
%    diagonal pivoting.  thresh = 1 is the default.
%
%    For SETUP.type == 'nofill', only SETUP.milu is used; all other fields
%    are ignored.  For SETUP.type == 'crout', only SETUP.droptol and
%    SETUP.milu are used; all other fields are ignored.
%
%    W = ILU(A,SETUP) returns "L+U-speye(size(A))" where L is unit lower
%    triangular and U is upper triangular.  If SETUP.type == 'ilutp', the
%    permutation information is lost.
%
%    [L,U] = ILU(A,SETUP) returns unit lower triangular L and upper
%    triangular U when SETUP.type == 'nofill' or when SETUP.type ==
%    'crout'.  For SETUP.type == 'ilutp', one of the factors is permuted
%    based on the value of SETUP.milu.  When SETUP.milu == 'row', U is a
%    column permuted upper triangular factor.  Otherwise, L is a
%    row-permuted unit lower triangular factor.
%
%    [L,U,P] = ILU(A,SETUP) returns unit lower triangular L, upper
%    triangular U and a permutation matrix P.  When SETUP.type == 'nofill'
%    or when SETUP.type == 'crout', P is always an identity matrix as
%    neither of these methods performs pivoting.  When SETUP.type =
%    'ilutp', the role of P is determined by the value of SETUP.milu.  When
%    SETUP.milu ~= 'row', P is returned such that L and U are incomplete
%    factors of P*A.  When SETUP.milu == 'row', P is returned such that L
%    and U are incomplete factors of A*P.
%
%    Example:
%
%       A = gallery('neumann', 1600) + speye(1600);
%       setup.type = 'nofill';
%       nnz(A)
%       nnz(lu(A))
%       nnz(ilu(A,setup))
%
%    This shows that A has 7840 nonzeros, its complete LU factorization has
%    126478 nonzeros, and its incomplete LU factorization with 0 level of
%    fill-in has 7840 nonzeros, the same amount as A.
%
%    Example:
%
%       A = gallery('neumann', 1600) + speye(1600);
%       setup.type = 'crout';
%       setup.milu = 'row';
%       setup.droptol = 0.1;
%       [L,U] = ilu(A,setup);
%       e = ones(size(A,2),1);
%       norm(A*e-L*U*e)
%
%    This shows that A and L*U, where L and U are given by the modified
%    Crout ILU, have the same row-sum.
%
%    ILU works only for sparse matrices.
%
%    See also ICHOL, LU, GMRES, BICG.

%   Copyright 2006-2013 The MathWorks, Inc. 
%   Built-in function.
