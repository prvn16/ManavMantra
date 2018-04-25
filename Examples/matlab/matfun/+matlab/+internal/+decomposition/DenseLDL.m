classdef DenseLDL < matlab.mixin.internal.Scalar
    % DENSELDL   LDL decomposition of a dense symmetric indefinite matrix
    %
    %   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
    %   Its behavior may change, or it may be removed in a future release.
    %
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Access = private)
        L_
        ddfac_
        ipiv_
        normA1_
        info_
    end
    
    methods
        function f = DenseLDL(A)
            [f.L_, f.ddfac_, f.ipiv_, f.normA1_, f.info_] = ...
                matlab.internal.decomposition.builtin.ldlFactor(A);
        end
        
        function rc = rcond(f)
            if f.info_ ~= 0
                rc = zeros(class(f.L_));
            else
                rc = matlab.internal.decomposition.builtin.ldlRcond(...
                    f.L_, f.ddfac_, f.normA1_);
            end
        end
        
        function x = solve(f,b,~)
            x = matlab.internal.decomposition.builtin.ldlSolve(...
                f.L_, f.ddfac_, f.ipiv_, b);
        end
        
        function fac = factors(f)
            % For debugging purposes only.
            
            perm = matlab.internal.decomposition.builtin.piv2perm(f.ipiv_);
            n = length(perm);
            P = sparse(perm, 1:n, 1, n, n);
            
            L = f.L_;
            
            D = zeros(n);
            D(1:n+1:end) = diag(L);
            D(2:n+1:end) = L(n+1:n+1:end);
            D(n+1:n+1:end) = conj(L(n+1:n+1:end));
            
            L = tril(L);
            L(1:n+1:end) = 1;
            
            formula = 'P * L * D * L'' * P''';
            
            fac = struct('formula', formula, ...
                'L', L, 'D', D, 'P', P);
            
        end
    end
end
