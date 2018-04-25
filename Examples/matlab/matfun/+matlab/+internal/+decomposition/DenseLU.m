classdef DenseLU < matlab.mixin.internal.Scalar
    % DENSELU   LU decomposition of a dense, square matrix
    %
    %   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
    %   Its behavior may change, or it may be removed in a future release.
    %
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Access = private)
        LU_
        piv_
        normA1_
    end
    
    methods
        function f = DenseLU(A)
            [f.LU_,f.piv_,f.normA1_] = matlab.internal.decomposition.builtin.luFactor(A);
        end
        
        function rc = rcond(f)
            rc = matlab.internal.decomposition.builtin.luRcond(f.LU_,f.normA1_);
        end
        
        function x = solve(f,b,transposed)
            x = matlab.internal.decomposition.builtin.luSolve(f.LU_,f.piv_,b,transposed);
        end
        
        function fac = factors(f)
            % For debugging purposes only.
            
            X = f.LU_;
            L = tril(X,-1) + speye(size(X));
            U = triu(X);
            
            n = size(f.LU_, 2);
            perm = matlab.internal.decomposition.builtin.piv2perm(f.piv_);
            P = sparse(1:n, perm, 1, n, n);
            
            formula = 'P'' * L * U';
            
            fac = struct('formula', formula, ...
                'L', L, 'U', U, 'P', P);
        end
    end
end
