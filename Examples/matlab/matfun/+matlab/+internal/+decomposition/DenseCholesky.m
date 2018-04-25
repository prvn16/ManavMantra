classdef DenseCholesky < matlab.mixin.internal.Scalar
    % DENSECHOLESKY   Cholesky decomposition of an SPD matrix
    %
    %   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
    %   Its behavior may change, or it may be removed in a future release.
    %
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Access = private)
        C_
        success_
        normA1_
    end
    
    methods
        function f = DenseCholesky(A)
            % Attempt Cholesky factorization of A.
            [f.C_, f.success_, f.normA1_] = matlab.internal.decomposition.builtin.cholFactor(A);
        end
        
        function pd = success(f)
            pd = f.success_ == 0;
        end
        
        function rc = rcond(f)
            rc = matlab.internal.decomposition.builtin.cholRcond(f.C_, f.normA1_);
        end
        
        function x = solve(f,b,~)
            x = matlab.internal.decomposition.builtin.cholSolve(f.C_,b);
        end
        
        function fac = factors(f)
            % For debugging purposes only.
            
            L = triu(f.C_)';
            
            formula = 'L * L''';
            
            fac = struct('formula', formula, 'L', L);
        end
    end
    
end
