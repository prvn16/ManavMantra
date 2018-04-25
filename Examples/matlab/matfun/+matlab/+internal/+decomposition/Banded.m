classdef Banded < matlab.mixin.internal.Scalar
    % BANDED   LU decomposition of a banded matrix
    %
    %   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
    %   Its behavior may change, or it may be removed in a future release.
    %
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Access = private)
        LU_
        kl_
        ku_
        piv_
        normA1_
        info_
    end
    
    methods
        function f = Banded(A, kl, ku)            
            f.kl_ = kl;
            f.ku_ = ku;
            f.normA1_ = norm(A, 1);
            
            bdA = [zeros(kl, size(A, 1)); spdiags(A, ku:-1:-kl).'];
            [f.LU_, f.piv_, f.info_] = matlab.internal.decomposition.builtin.bandedFactor(bdA, kl, ku);
        end
        
        function rc = rcond(f)
            if f.info_ > 0
                rc = 0;
            else
                rc = matlab.internal.decomposition.builtin.bandedRcond(...
                    f.LU_, f.normA1_, f.kl_, f.ku_, f.piv_);
            end
        end
        
        function x = solve(f,b,transposed)
            
            sparseOut = issparse(b);
            if sparseOut
                b = full(b);
            end
            
            x = matlab.internal.decomposition.builtin.bandedSolve(...
                f.LU_, f.kl_, f.ku_, f.piv_, b, transposed);
            
            if sparseOut
                x = sparse(x);
            end
        end
        
        function fac = factors(f)
            % For debugging purposes only.
            
            X = f.LU_;
            n = size(X, 2);
            U = spdiags(X(1:(f.kl_+f.ku_+1), :).', (f.kl_+f.ku_):-1:0, n, n);
            LL = spdiags([X(end:-1:(f.kl_+f.ku_+2), :).' ones(n, 1)], -f.kl_:0, n, n);
            
            L = speye(n);
            for ii=1:n-1
                Li = speye(n);
                % Copy lower-triangular colum from LL
                Li(ii+1:end,ii) = LL(ii+1:end,ii); %#ok<SPRIX>
                Pi = speye(n);
                Pi([ii f.piv_(ii)], :) = Pi([f.piv_(ii) ii], :); %#ok<SPRIX>
                L = Pi*L*Pi*Li;
            end
            
            perm = matlab.internal.decomposition.builtin.piv2perm(f.piv_);
            P = sparse(1:n, perm, 1, n, n);
            
            formula = 'P'' * L * U';
            
            fac = struct('formula', formula, ...
                'L', L, 'U', U, 'P', P);
        end
    end
end
