classdef DenseQR < matlab.mixin.internal.Scalar
    % DENSEQR   QR decomposition of a dense matrix
    %
    %   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
    %   Its behavior may change, or it may be removed in a future release.
    %
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Access = private)
        m_
        n_
        QR_
        tau_
        perm_
    end
    
    properties (GetAccess = public, SetAccess = private)
        rank_ = [];
        ranktol_ = [];
    end
    
    methods
        function f = DenseQR(A, tol)
            [f.m_,f.n_] = size(A);
            
            if isempty(tol)
                % Setting tol < 0 causes qrFactor to compute default tolerance from A.
                % Default tolerance is defined as:
                % If A is real:
                % tol = min(max(size(A))*eps(class(A)), sqrt(eps(class(A)))) * abs(R(1, 1))
                %
                % If A is complex:
                % tol = min(10*max(size(A))*eps(class(A)), sqrt(eps(class(A)))) * abs(R(1, 1))
                
                tol = -2;
            end
            
            % Construct object.
            [f.QR_,f.tau_,f.perm_,f.rank_,f.ranktol_] = ...
                matlab.internal.decomposition.builtin.qrFactor(A, tol);
        end
        
        function x = solve(f,b,~)
            x = matlab.internal.decomposition.builtin.qrSolve(...
                f.QR_, f.tau_, f.perm_, b, f.rank_);
        end
        
        function fac = factors(f)
            % For debugging purposes only.

            Q = matlab.internal.decomposition.builtin.applyHouseholder(f.QR_, f.tau_, eye(f.m_, min(f.m_, f.n_)), false, f.rank_);
            R = f.QR_;
            R = R(1:min(f.m_, f.n_), :);
            R(f.rank_+1:end, :) = 0;
            R = triu(R);
            
            if f.m_ == 0
                P = speye(f.n_); % f.perm_ not initialized in empty case
            else
                P = sparse(1:f.n_, double(f.perm_), 1, f.n_, f.n_);
            end
            
            formula = "Q * R * P";
            
            fac = struct('formula', formula, ...
                'Q', Q, 'R', R, 'P', P);
        end
    end
end