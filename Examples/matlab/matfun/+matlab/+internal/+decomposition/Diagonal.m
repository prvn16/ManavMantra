classdef Diagonal < matlab.mixin.internal.Scalar
    % DIAGONAL   Decomposition of a diagonal matrix
    %
    %   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
    %   Its behavior may change, or it may be removed in a future release.
    %
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Access = private)
        d_
    end
    
    methods
        function f = Diagonal(A)
            f.d_ = full(diag(A));
        end
        
        function rc = rcond(f)
            if isempty(f.d_)
                rc = inf(class(f.d_));
            elseif all(f.d_ == 0)
                rc = zeros(class(f.d_));
            else
                rc = min(abs(f.d_)) / max(abs(f.d_));
            end
        end
        
        function x = solve(f,b,transposed)
            
            dd = f.d_;
            
            if transposed
                dd = conj(dd);
            end
            
            x = dd(:) .\ b;
            
        end
        
        function fac = factors(f)
            % For debugging purposes only.
            
            d = f.d_;
            
            formula = 'diag(d)';
            
            fac = struct('formula', formula, ...
                'd', d);
        end
    end
end
