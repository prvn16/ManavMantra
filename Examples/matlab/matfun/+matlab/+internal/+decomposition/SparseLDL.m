classdef SparseLDL < matlab.mixin.internal.Scalar
    % SPARSELDL   LDL decomposition of a sparse symmetric indefinite matrix
    %
    %   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
    %   Its behavior may change, or it may be removed in a future release.
    %
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Access = private)
        n_
        ma57_
        pivtol_
        useMinDegree_
        normA1_
    end
    
    methods
        function f = SparseLDL(A, pivtol, useMinDegree)
            
            % Construct symmetric A from lower triangular part
            % Need this to compute norm(A, 1) below
            A = tril(A) + tril(A, -1)';
            
            f.n_ = size(A, 1);
            
            f.ma57_ = matlab.internal.decomposition.builtin.MA57Wrapper(A, pivtol, useMinDegree);
            f.pivtol_ = pivtol;
            f.useMinDegree_ = useMinDegree;
            
            f.normA1_ = norm(A, 1);
        end
        
        function rc = rcond(f)
            % Use normest1 iterative estimate, because MA57's condition
            % number estimate depends on the right-hand side vector.
            if f.n_ == 0
                rc = Inf;
            elseif f.ma57_.Rank < f.n_
                rc = 0;
            else
                Ainv_norm = normest1(@(flag,x)condestHelper(f, flag, x));
                rc = 1/(Ainv_norm*f.normA1_);
            end
        end
        
        function x = solve(f, b, ~)
            x = solve(f.ma57_, b);
        end
        
        function fac = factors(f)
            % For debugging purposes only.
            
            fac = factors(f.ma57_);
            
            P = sparse(double(fac.p), 1:f.n_, ones(1, f.n_), f.n_, f.n_);
            S = diag(sparse(fac.scal));
            formula = 'S \ P * L * D * L'' * P'' / S';
            
            fac = struct('formula', formula, ...
                'L', fac.L, 'D', fac.D, 'P', P, 'S', S);
        end
    end
    
    methods(Access = private)
        function out = condestHelper(f, flag, b)
            if isequal(flag,'dim')
                out = f.n_;
            elseif isequal(flag,'real')
                out = true;
            else
                out = solve(f.ma57_, b);
            end
        end
    end
end
