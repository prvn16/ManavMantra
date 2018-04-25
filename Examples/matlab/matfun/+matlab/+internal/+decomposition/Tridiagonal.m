classdef Tridiagonal < matlab.mixin.internal.Scalar
    % TRIDIAGONAL   LU decomposition of a tridiagonal matrix
    %
    %   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
    %   Its behavior may change, or it may be removed in a future release.
    %
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Access = private)
        LU_
        success_
    end
    
    methods
        function f = Tridiagonal(A)
            % Input matrix must be square, sparse, and real, with nnz(A)
            % equal 3*n-2. The upper and lower bandwidth must both be 1.
            [f.LU_, f.success_] = matlab.internal.decomposition.builtin.tridiagFactor(A);
        end
        
        function sc = success(f)
            sc = f.success_;
        end
        
        function rc = rcond(f)
            absDiagU = abs(f.LU_(2, :));
            if isempty(absDiagU)
                rc = 1;
            else
                rc = min(absDiagU) / max(absDiagU);
            end
        end
        
        function x = solve(f,b,transposed)
            sparseOut = issparse(b);
            if sparseOut
                b = full(b);
            end
            
            x = matlab.internal.decomposition.builtin.tridiagSolve(f.LU_, b, transposed);
            
            if sparseOut
                x = sparse(x);
            end
        end
        
        function fac = factors(f)
            % For debugging purposes only.
            
            X = f.LU_;
            
            n = size(X, 2);
            U = spdiags(X(1:2, :).', [1 0], n, n);
            L = spdiags([X(3, :).' ones(n, 1)], [-1 0], n, n);
            
            formula = 'L * U';
            
            fac = struct('formula', formula, 'L', L, 'U', U);
        end
    end
end
