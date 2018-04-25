%ETREE  Elimination tree
%   Finds the elimination tree of A, A'*A, or A*A', and optionaly postorders
%   the tree.  parent(j) is the parent of node j in the tree, or 0 if j is a
%   root.  The symmetric case uses only the upper or lower triangular part of
%   A (ETREE(A) uses the upper part, and ETREE(A,'lo') uses the lower part).
%
%   parent = ETREE(A)         finds the elimination tree of A, using TRIU(A)
%   parent = ETREE(A,'sym')   same as ETREE(A)
%   parent = ETREE(A,'col')   finds the elimination tree of A'*A
%   parent = ETREE(A,'row')   finds the elimination tree of A*A'
%   parent = ETREE(A,'lo')    finds the elimination tree of A, using TRIL(A)
%
%   [parent,post] = ETREE(...) also returns a postordering of the tree.
%
%   If you have a fill-reducing permutation p, you can combine it with an
%   elimination tree postordering using the following code.  Postordering has
%   no effect on fill-in (except for lu), but it does improve the performance
%   of the subsequent factorization.
%
%   For the symmetric case, suitable for CHOL(A(p,p)):
%
%       [parent,post] = ETREE(A(p,p));
%       p = p(post);
%
%   For the column case, suitable for QR(A(:,p)) or LU(A(:,p)):
%
%       [parent,post] = ETREE(A(:,p),'col');
%       p = p(post);
%
%   For the row case, suitable for QR(A(p,:)') or CHOL(A(p,:)*A(p,:)'):
%
%       [parent,post] = ETREE(A(p,:),'row');
%       p = p(post);
%
%   See also TREELAYOUT, TREEPLOT, ETREEPLOT.

%   Copyright 1984-2015 The MathWorks, Inc. 
%   Built-in function.

