%QR     Orthogonal-triangular decomposition.
%   [Q,R] = QR(A), where A is m-by-n, produces an m-by-n upper triangular
%   matrix R and an m-by-m unitary matrix Q so that A = Q*R.
%
%   [Q,R] = QR(A,0) produces the "economy size" decomposition.
%   If m>n, only the first n columns of Q and the first n rows of R are
%   computed. If m<=n, this is the same as [Q,R] = QR(A).
%
%   If A is full:
%
%   [Q,R,E] = QR(A) produces unitary Q, upper triangular R and a
%   permutation matrix E so that A*E = Q*R. The column permutation E is
%   chosen so that ABS(DIAG(R)) is decreasing.
%
%   [Q,R,e] = QR(A,'vector') returns the permutation information as a
%   vector instead of a matrix.  That is, e is a row vector such that 
%   A(:,e) = Q*R. Similarly, [Q,R,E] = QR(A,'matrix') returns a permutation 
%   matrix E. This is the default behavior.
%
%   [Q,R,E] = QR(A,0) produces an "economy size" decomposition in which E
%   is a permutation vector, so that A(:,E) = Q*R.
%
%   X = QR(A) and X = QR(A,0) return the output of LAPACK's *GEQRF routine.
%   TRIU(X) is the upper triangular factor R.
%
%   If A is sparse:
%
%   R = QR(A) computes a "Q-less QR decomposition" and returns the upper
%   triangular factor R. Note that R = CHOL(A'*A). Since Q is often nearly
%   full, this is preferred to [Q,R] = QR(A).
%
%   R = QR(A,0) produces "economy size" R. If m>n, R has only n rows. If
%   m<=n, this is the same as R = QR(A).
%
%   [Q,R,E] = QR(A) produces unitary Q, upper triangular R and a
%   permutation matrix E so that A*E = Q*R. The column permutation E is
%   chosen to reduce fill-in in R.
%
%   [Q,R,e] = QR(A,'vector') returns the permutation information as a
%   vector instead of a matrix.  That is, e is a row vector such that 
%   A(:,e) = Q*R. Similarly, [Q,R,E] = QR(A,'matrix') returns a permutation 
%   matrix E. This is the default behavior.
%
%   [Q,R,E] = QR(A,0) produces an "economy size" decomposition in which E
%   is a permutation vector, so that A(:,E) = Q*R.
%
%   [C,R] = QR(A,B), where B has as many rows as A, returns C = Q'*B.
%   The least-squares solution to A*X = B is X = R\C.
%
%   [C,R,E] = QR(A,B), also returns a fill-reducing ordering.
%   The least-squares solution to A*X = B is X = E*(R\C).
%
%   [C,R,e] = QR(A,B,'vector') returns the permutation information as a
%   vector instead of a matrix.  That is, the least-squares solution to 
%   A*X = B is X(e,:) = R\C. Similarly, [C,R,E] = QR(A,B,'matrix') returns 
%   a permutation matrix E. This is the default behavior.
%
%   [C,R] = QR(A,B,0) produces "economy size" results. If m>n, C and R have
%   only n rows. If m<=n, this is the same as [C,R] = QR(A,B).
%
%   [C,R,E] = QR(A,B,0) additionally produces a fill-reducing permutation
%   vector E.  In this case, the least-squares solution to A*X = B is
%   X(E,:) = R\C.
%
%   Example: The least squares approximate solution to A*x = b can be found
%   with the Q-less QR decomposition and one step of iterative refinement:
%
%         if issparse(A), R = qr(A); else R = triu(qr(A)); end
%         x = R\(R'\(A'*b));
%         r = b - A*x;
%         e = R\(R'\(A'*r));
%         x = x + e;
%
%   See also LU, NULL, ORTH, QRDELETE, QRINSERT, QRUPDATE.

%   Copyright 1984-2009 The MathWorks, Inc.
%   Built-in function.

