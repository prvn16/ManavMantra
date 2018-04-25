%ORDQZ  Reorder eigenvalues in QZ factorization.
%   [AAS,BBS,QS,ZS] = ORDQZ(AA,BB,Q,Z,SELECT) reorders the QZ factorization 
%   Q*A*Z = AA, Q*B*Z = BB of a matrix pair (A,B) so that a selected cluster 
%   of eigenvalues appears in the leading (upper left) diagonal blocks of the 
%   quasitriangular pair (AA,BB), and the corresponding invariant subspace is 
%   spanned by the leading columns of Z.  The logical vector SELECT specifies 
%   the selected cluster as E(SELECT) where E is the vector of eigenvalues 
%   as they appear along the diagonal of AA-t*BB.  Use E = ORDEIG(AA,BB) to 
%   extract E from AA and BB.
%
%   ORDQZ takes the matrices AA,BB,Q,Z produced by the QZ command and
%   returns the reordered pair (AAS,BBS) and the cumulative orthogonal 
%   transformations QS and ZS such that QS*A*ZS = AAS, QS*B*ZS = BBS.  
%   Set Q=[] or Z=[] to get the incremental QS,ZS transforming (AA,BB)  
%   into (AAS,BBS).
% 
%   [AAS,BBS,...] = ORDQZ(AA,BB,Q,Z,KEYWORD) sets the selected cluster to 
%   include all eigenvalues in one of the following regions:
%
%       KEYWORD              Selected Region
%        'lhp'            left-half plane  (real(E)<0)
%        'rhp'            right-half plane (real(E)>0)
%        'udi'            interior of unit disk (abs(E)<1)
%        'udo'            exterior of unit disk (abs(E)>1)
%
%   ORDQZ can also reorder multiple clusters at once.  Given a vector 
%   CLUSTERS of cluster indices, commensurate with E = EIG(AA,BB), and 
%   such that all eigenvalues with same CLUSTERS value form one cluster,
%   [...] = ORDQZ(AA,BB,Q,Z,CLUSTERS) will sort the specified clusters
%   in descending order along the diagonal of (AAS,BBS), the cluster with  
%   highest index appearing in the upper left corner.
%
%   If AA has complex conjugate pairs (non-zero elements on the
%   subdiagonal), then the pair should be moved to the same cluster.
%   Otherwise, ORDQZ acts to keep the pair together:
%     * If SELECT is not the same for two eigenvalues in a conjugate
%       pair, then both are treated as selected.
%     * If CLUSTERS is not the same for two eigenvalues in a conjugate
%       pair, then both are treated as part of the cluster with larger
%       index.
%
%   See also QZ, ORDEIG, ORDSCHUR.

%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.

