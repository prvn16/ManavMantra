classdef SparseLU < matlab.mixin.internal.Scalar
    % SPARSELU   LU decomposition of a sparse matrix
    %
    %   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
    %   Its behavior may change, or it may be removed in a future release.
    %
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Access = private)
        n_
        umfpack_
        pivtol_
        sympivtol_
        useMinDegree_
    end
    
    methods
        function f = SparseLU(A, pivtol, sympivtol, useMinDegree)
            f.n_ = size(A, 1);
            f.umfpack_ = matlab.internal.decomposition.builtin.UMFPACKWrapper(A, pivtol, sympivtol, useMinDegree);
            f.pivtol_ = pivtol;
            f.sympivtol_ = sympivtol;
            f.useMinDegree_ = useMinDegree;
        end
        
        function rc = rcond(f)
            rc = rcond(f.umfpack_);
        end
        
        function x = solve(f,b,transposed)
            x = solve(f.umfpack_, b, transposed);
        end
        
        function fac = factors(f)
            % For debugging purposes only.
            
            fac = factors(f.umfpack_);
            
            P = sparse(1:f.n_, double(fac.p), ones(1, f.n_), f.n_, f.n_);
            Q = sparse(double(fac.q), 1:f.n_, ones(1, f.n_), f.n_, f.n_);
            S = diag(sparse(fac.s));
            formula = 'S * Pleft'' * L * U * Pright''';
            
            fac = struct('formula', formula, ...
                'L', fac.L, 'U', fac.U, 'Pleft', P, 'Pright', Q, 'S', S);
        end
    end
end
