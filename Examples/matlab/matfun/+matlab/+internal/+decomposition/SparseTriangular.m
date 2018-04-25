classdef SparseTriangular < matlab.mixin.internal.Scalar
    % SPARSETRIANGULAR   Decomposition of a sparse triangular matrix
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
        function f = SparseTriangular(A, side, p, q)
            
            % Input check.
            if all(diag(A) ~= 0)
                if strcmp(side, 'upper')
                    if ~istriu(A)
                        A = triu(A);
                    end
                else
                    if ~istril(A)
                        A = tril(A);
                    end
                end
            else
                % This returns an invalid sparse matrix, with explicit zeros on the diagonal,
                % for use in sparseTriangSolve. Use with caution.
                A = matlab.internal.decomposition.builtin.makeSparseTriang(A, char(side));
            end
            
            f.T_ = A;
            f.side_ = char(side);
            
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
                dT = abs(diag(f.T_));
                if all(dT == 0)
                    rc = 0;
                else
                    rc = full(min(dT) / max(dT));
                end
            end
        end
        
        function x = solve(f,b,transposed)
            
            x = b;
            
            if transposed
                if ~isempty(f.pr_)
                    x = x(f.pr_, :);
                end
                
                x = matlab.internal.decomposition.builtin.sparseTriangSolve(f.T_, x, f.side_, true);
                
                if ~isempty(f.pl_)
                    x(f.pl_, :) = x;
                end
            else
                if ~isempty(f.pl_)
                    x = x(f.pl_, :);
                end
                
                x = matlab.internal.decomposition.builtin.sparseTriangSolve(f.T_, x, f.side_, false);
                
                if ~isempty(f.pr_)
                    x(f.pr_, :) = x;
                end
            end
        end
        
        function fac = factors(f)
            % For debugging purposes only.
            
            T = f.T_;
            side = f.side_;
            n = size(T, 1);
            if ~isempty(f.pl_)
                PL = sparse(f.pl_, 1:n, 1, n, n);
            else
                PL = speye(n);
            end
            if ~isempty(f.pr_)
                PR = sparse(f.pr_, 1:n, 1, n, n);
            else
                PR = speye(n);
            end
            
            formula = 'Pleft * T * Pright''';
            
            fac = struct('formula', formula, ...
                'T', T, 'Pleft', PL, 'Pright', PR, 'side', side);
        end
    end
end
