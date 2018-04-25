classdef SparseCOD < matlab.mixin.internal.Scalar
    % SPARSECOD   COD decomposition of a sparse matrix
    %
    %   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
    %   Its behavior may change, or it may be removed in a future release.
    %
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Access = private)
        m_
        n_
        
        % First matrix Q (along the larger dimension of A)
        H1
        tau1
        rowperm1
        colperm1
        
        % Second matrix Q (only needed for low-rank case)
        H2
        tau2
        rowperm2
        colperm2
        
        % Internal matrix R (size f.rank_-by-f.rank_)
        R
        Rtransposed = false
             
        % Save inputs
        tol_
        useMinDegree_
    end
    
    properties (GetAccess = public, SetAccess = private)
        rank_ = [];
        ranktol_ = [];
    end
    
    methods
        function f = SparseCOD(A, tol, useMinDegree)
            [f.m_,f.n_] = size(A);
            
            if f.m_ < f.n_
                A = A';
                f.Rtransposed = true;
            end
            
            if isempty(tol)
                % Use SPQR default tolerance:
                % tol = min(20*sum(size(A))*eps*max(sqrt(sum(abs(A).^2, 1))), realmax)
                f.tol_ = -2;
            else
                f.tol_ = tol;
            end
            f.useMinDegree_ = useMinDegree;
            
            % Construct object.
            [f.H1, f.tau1, f.rowperm1, f.R, f.colperm1, f.rank_, f.ranktol_] = ...
                matlab.internal.math.implicitSparseQR(A, useMinDegree, f.tol_);
            
            if f.rank_ < min(f.m_, f.n_)
                M = f.R;
                M(f.rank_+1:end, :) = [];
                
                [f.H2, f.tau2, f.rowperm2, f.R, f.colperm2] = ...
                    matlab.internal.math.implicitSparseQR(M', useMinDegree, 0);
                
                f.rowperm2(f.colperm1) = f.rowperm2;
                f.colperm1 = [];
                f.Rtransposed = ~f.Rtransposed;
            end
        end
        
        function x = solve(f,b,transposed)
            
            if xor(transposed, f.m_ >= f.n_)
                applyQ_reduce = @applyQ1;
                p_reduce = f.colperm2;
                applyQ_extend = @applyQ2;
                p_extend = f.colperm1;
            else
                applyQ_reduce = @applyQ2;
                p_reduce = f.colperm1;
                applyQ_extend = @applyQ1;
                p_extend = f.colperm2;
            end
            
            x = applyQ_reduce(f, b, true);
            if isempty(p_reduce)
                x = x(1:f.rank_, :);
            else
                x = x(p_reduce, :);
            end
            
            x2 = matlab.internal.decomposition.builtin.sparseTriangSolve(f.R, x, 'upper', transposed ~= f.Rtransposed);
            
            if ~transposed
                x = zeros(f.n_, size(b, 2), 'like', b);
            else
                x = zeros(f.m_, size(b, 2), 'like', b);
            end
            if isempty(p_extend)
                x(1:f.rank_, :) = x2;
            else
                x(p_extend, :) = x2;
            end
            
            x = applyQ_extend(f, x, false);
        end
        
        function fac = factors(f)
            % For debugging purposes only.
            
            if f.m_ >= f.n_
                applyQleft = @applyQ1;
                applyQright = @applyQ2;
                pleft = f.colperm2;
                pright = f.colperm1;
            else
                applyQleft = @applyQ2;
                applyQright = @applyQ1;
                pleft = f.colperm1;
                pright = f.colperm2;
            end
            
            formula = "Qleft * T * Qright'";
            
            Qleft = applyQleft(f, speye(f.m_, f.rank_), false);
            Qright = applyQright(f, speye(f.n_, f.rank_), false);
            
            T = f.R;
            if f.Rtransposed
                T = T';
            end
            
            if ~isempty(pleft)
                Qleft = Qleft(:, pleft);
            end
            if ~isempty(pright)
                Qright = Qright(:, pright);
            end
            
            fac = struct('formula', formula, ...
                'Qleft', Qleft, 'Qright', Qright, 'T', T);
        end
    end
    
    methods(Access = private)
        
        function y = applyQ1(f, x, transp)
            % Compute y = Q*x or y = Q'*x, where Q is a square
            % orthogonal matrix defined by Householder vectors.
            
            y = applyQ(f.H1, f.tau1, f.rowperm1, x, transp);
        end
        
        function y = applyQ2(f, x, transp)
            % Compute y = Q*x or y = Q'*x, where Q is a square
            % orthogonal matrix defined by Householder vectors.
            
            if f.rank_ == min(f.m_, f.n_)
                y = x;
            else
                y = applyQ(f.H2, f.tau2, f.rowperm2, x, transp);
            end
        end
    end
end


function y = applyQ(H, tau, rowperm, x, transp)
% Compute y = Q*x or y = Q'*x, where Q is a square
% orthogonal matrix defined by Householder vectors.

import matlab.internal.math.applyHouseholder;

if isreal(H) && isreal(tau) && ~isreal(x)
    % Real Q applied to complex x not supported in built-in
    y = applyHouseholder(H, tau, rowperm, real(x), transp) + ...
        1i*applyHouseholder(H, tau, rowperm, imag(x), transp);
else
    y = applyHouseholder(H, tau, rowperm, x, transp);
end
end
