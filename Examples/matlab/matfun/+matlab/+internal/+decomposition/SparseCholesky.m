classdef SparseCholesky < matlab.mixin.internal.Scalar
    % SPARSECHOLESKY   Cholesky decomposition of a sparse SPD matrix
    %
    %   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
    %   Its behavior may change, or it may be removed in a future release.
    %
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Access = private)
        n_
        cholmod_
        useMinDegree_;
        success_
    end
    
    methods
        function f = SparseCholesky(A, useMinDegree)
            f.n_ = size(A, 1);
            f.cholmod_ = matlab.internal.decomposition.builtin.CHOLMODWrapper(A, useMinDegree);
            f.useMinDegree_ = useMinDegree;
            f.success_ = success(f.cholmod_);
        end
        
        function pd = success(f)
            pd = f.success_;
        end
        
        function rc = rcond(f)
            rc = rcond(f.cholmod_);
        end
        
        function x = solve(f,b,~)
            x = solve(f.cholmod_, b);
        end
        
        function fac = factors(f)
            % For debugging purposes only.
            fac = factors(f.cholmod_);
            
            P = sparse(double(fac.p), 1:f.n_, ones(1, f.n_), f.n_, f.n_);
            formula = 'P * L * L'' * P''';
            
            fac = struct('formula', formula, ...
                'L', fac.L, 'P', P);
        end
    end
end
