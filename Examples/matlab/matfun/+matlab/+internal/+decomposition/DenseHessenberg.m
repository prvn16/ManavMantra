classdef DenseHessenberg < matlab.mixin.internal.Scalar
    % DENSEHESSENBERG   LU decomposition of a dense Hessenberg matrix
    %
    %   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
    %   Its behavior may change, or it may be removed in a future release.
    %
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Access = private)
        U_
        l_
        p_
        rcond_
    end
    
    methods
        function f = DenseHessenberg(A)
            % Construct compact LU and pivot vector.
            [f.U_,f.l_,f.p_,rc] = matlab.internal.decomposition.builtin.hessenbergFactor(A);
            
            % Compute estimated condition number
            f.rcond_ = rc;
        end
        
        function rc = rcond(f)
            rc = f.rcond_;
        end
        
        function x = solve(f,b,transposed)
            x = matlab.internal.decomposition.builtin.hessenbergSolve(f.U_,f.l_,f.p_,b,transposed);
        end
        
        function fac = factors(f)
            % For debugging purposes only.
            
            % Construct L
            n = length(f.p_);
            lout = f.l_;
            ipiv = f.p_ + 1;
            
            L = speye(n);
            for ii=1:n-1
                Li = speye(n);
                Li(ii+1,ii) = lout(ii); %#ok<SPRIX>
                Pi = speye(n);
                Pi([ii ipiv(ii)], :) = Pi([ipiv(ii) ii], :); %#ok<SPRIX>
                L = Pi*L*Pi*Li;
            end
            
            % Construct U:
            Uout = triu(f.U_);
            
            perm = matlab.internal.decomposition.builtin.piv2perm(f.p_+1);
            P = sparse(1:n, perm, 1, n, n);
            
            formula = 'P'' * L * U';
            
            fac = struct('formula', formula, ...
                'L', L, 'U', Uout, 'P', P);
        end
    end
end
