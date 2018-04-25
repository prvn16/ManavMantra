classdef SparseQR < matlab.mixin.internal.Scalar
    % SPARSEQR   QR decomposition of a sparse matrix
    %
    %   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
    %   Its behavior may change, or it may be removed in a future release.
    %
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Access = private)
        m_
        n_
        
        % Householder factors for matrix Q
        H
        tau
        rowperm
        
        % Matrix R, and upper corner which is used in mldivide:
        completeR_
        R_
        
        % P
        colperm
        
        % Save inputs
        tol_
        useMinDegree_
    end
    
    properties (GetAccess = public, SetAccess = private)
        rank_ = [];
        ranktol_ = [];
    end
    
    methods
        function f = SparseQR(A, tol, useMinDegree)
            
            [f.m_,f.n_] = size(A);
            
            if isempty(tol)
                % Use SPQR default tolerance:
                % tol = min(realmax, ...
                %    20*sum(size(A)) * eps * max(sqrt(sum(abs(A).^2, 1))))
                f.tol_ = -2;
            else
                f.tol_ = tol;
            end
            f.useMinDegree_ = useMinDegree;
            
            % Construct object.
            [f.H, f.tau, f.rowperm, f.completeR_, f.colperm, f.rank_, f.ranktol_] = ...
                matlab.internal.math.implicitSparseQR(A, useMinDegree, f.tol_);
            
            f.R_ = f.completeR_(1:f.rank_, 1:f.rank_);
        end
        
        function x = solve(f,b,~)
            
            % QTb = Q'*b;
            QTb = applyQ(f, b, true);
            
            % y = R(1:rank, 1:rank) \ QTb(1:f.rank_);
            y = matlab.internal.decomposition.builtin.sparseTriangSolve(...
                f.R_, QTb(1:f.rank_, :), 'upper', false);
            
            % x(perm(1:rank), :) = y;
            if issparse(b)
                x = sparse(f.n_, size(b, 2));
            else
                x = zeros(f.n_, size(b, 2));
            end
            x(f.colperm(1:f.rank_), :) = y;
        end
        
        function fac = factors(f)
            % For debugging purposes only.
            
            Q = applyQ(f, speye(f.m_, min(f.m_, f.n_)), false);
            R = f.completeR_;
            P = sparse(1:f.n_, f.colperm, 1, f.n_, f.n_);
            
            formula = "Q * R * P";
            
            fac = struct('formula', formula, ...
                'Q', Q, 'R', R, 'P', P);
        end
    end
    
    methods (Access = private)
        function y = applyQ(f, x, transp)
            % Compute y = Q*x or y = Q'*x, where Q is a square
            % orthogonal matrix defined by Householder vectors.
            
            if isreal(f.H) && isreal(f.tau) && ~isreal(x)
                % Real Q applied to complex x not supported in built-in
                y = matlab.internal.math.applyHouseholder(f.H, f.tau, f.rowperm, real(x), transp) + ...
                    1i*matlab.internal.math.applyHouseholder(f.H, f.tau, f.rowperm, imag(x), transp);
            else
                y = matlab.internal.math.applyHouseholder(f.H, f.tau, f.rowperm, x, transp);
            end
        end
    end
end
