classdef DenseCOD < matlab.mixin.internal.Scalar
    % DENSECOD   COD decomposition of a dense matrix
    %
    %   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
    %   Its behavior may change, or it may be removed in a future release.
    %
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Access = private)
        m_
        n_

        QR_
        tau1_
        perm_
        tau2_
    end
    
    properties (GetAccess = public, SetAccess = private)
        rank_ = [];
        ranktol_ = [];
    end
    
    methods
        function f = DenseCOD(A, tol)
            [f.m_,f.n_] = size(A);
            
            if f.m_ < f.n_
                A = A';
            end
            
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
            [f.QR_,f.tau1_,f.perm_,f.rank_,f.ranktol_] = ...
                matlab.internal.decomposition.builtin.qrFactor(A, tol);
            
            if f.rank_ < min(f.m_, f.n_)
                [f.QR_, f.tau2_] = ...
                    matlab.internal.decomposition.builtin ...
                    .codFactor(f.QR_, f.rank_);
            end
            
        end
        
        function x = solve(f,b,transposed)
            
            import matlab.internal.decomposition.builtin.codSolve
            
            if f.m_ < f.n_
                % The internally computed decomposition always has m >= n
                transposed = ~transposed;
            end
            
            if ~transposed
                % Solve Qlong * R * Qshort' * x = b, using formula
                % x = (Qshort * (R \ (Qlong' *b) ) )
                x = codSolve(f.QR_, f.tau1_, f.tau2_, f.rank_, b, transposed);
                
                % Apply permutation
                x(f.perm_, :) = x;
            else
                % Apply permutation
                b = b(f.perm_, :);
                
                % Solve Qshort * R' * Qlong' * x = b, using formula
                % x = (Qlong * (R' \ (Qshort' *b) ) )
                x = codSolve(f.QR_, f.tau1_, f.tau2_, f.rank_, b, transposed);
            end

        end

        function fac = factors(f)
          % For debugging purposes only.
          
          formula = "Qleft * T * Qright'";
          
          Q1 = applyQ1(f, eye(max(f.m_, f.n_), f.rank_, class(f.QR_)), false);
          Q2 = applyQ2(f, eye(min(f.m_, f.n_), f.rank_, class(f.QR_)), false);
          
          T = f.QR_;
          
          T = T(1:f.rank_, 1:f.rank_);
          T = triu(T);
          if f.m_ < f.n_
              T = T';
          end
          
          Q2(f.perm_, :) = Q2;
          
          if f.m_ >= f.n_
              Qleft = Q1;
              Qright = Q2;
          else
              Qleft = Q2;
              Qright = Q1;
          end
                    
          fac = struct('formula', formula, ...
                       'Qleft', Qleft, 'Qright', Qright, 'T', T);

        end        
    end

    methods(Access = private)

        function y = applyQ1(f, x, transp)
        % Compute y = Q*x or y = Q'*x, where Q is a square
        % orthogonal matrix defined by Householder vectors.
            
            y = matlab.internal.decomposition.builtin.applyHouseholder(...
                f.QR_, f.tau1_, x, transp, f.rank_);
        end
        
        function y = applyQ2(f, x, transp)
        % Compute y = Q*x or y = Q'*x, where Q is a square
        % orthogonal matrix defined by Householder vectors.
            
            if f.rank_ == min(f.m_, f.n_)
                y = x;
            else                
                y = matlab.internal.decomposition.builtin.applyHouseholderRows(...
                    f.QR_, f.tau2_, x, ~transp, f.rank_);
            end
        end        
    end
end
