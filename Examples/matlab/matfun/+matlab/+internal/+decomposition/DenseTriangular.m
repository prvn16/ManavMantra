classdef DenseTriangular < matlab.mixin.internal.Scalar
    % DENSETRIANGULAR   Decomposition of a triangular matrix
    %
    %   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
    %   Its behavior may change, or it may be removed in a future release.
    %
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Access = private)
        T_
        side_
        pl_ = [];
        pr_ = [];
    end
    
    methods
        function f = DenseTriangular(A, side, p, q)
            f.T_ = A;
            
            if strcmpi(side, 'upper')
                f.side_ = 'upper';
            else
                f.side_ = 'lower';
            end
            if nargin > 2 && ~isempty(p)
                f.pl_ = p;
            end
            
            if nargin > 3 && ~isempty(q)
                f.pr_ = q;
            end
        end
        
        function rc = rcond(f)
            if isempty(f.T_)
                rc = inf(class(f.T_));
            else
                n = size(f.T_, 1);
                dT = abs(f.T_(1:(n+1):end));
                if all(dT == 0)
                    rc = 0;
                else
                    rc = full(min(dT) / max(dT));
                end
            end
        end
        
        function x = solve(f,b,transposed)
            import matlab.internal.decomposition.builtin.triangSolve
            
            if isempty(f.pr_)
                % No permutations needed.
                x = triangSolve(f.T_, b, f.side_, transposed);
            else
                if transposed
                    x(f.pl_, :) = triangSolve(f.T_, b(f.pr_, :), f.side_, transposed);
                else
                    x(f.pr_, :) = triangSolve(f.T_, b(f.pl_, :), f.side_, transposed);
                end
            end
        end
        
        function fac = factors(f)
            % For debugging purposes only.
            
            T = f.T_;
            side = f.side_;
            
            if strcmp(side, 'upper')
                T = triu(T);
            else
                T = tril(T);
            end

            n = size(f.T_, 1);
            if ~isempty(f.pl_)
                PL = sparse(f.pl_, 1:n, 1, n, n);
                PR = sparse(f.pr_, 1:n, 1, n, n);
            else
                PL = speye(n);
                PR = speye(n);
            end
            
            formula = 'Pleft * T * Pright''';
            
            fac = struct('formula', formula, ...
                'T', T, 'Pleft', PL, 'Pright', PR, 'side', side);
        end
    end
end
