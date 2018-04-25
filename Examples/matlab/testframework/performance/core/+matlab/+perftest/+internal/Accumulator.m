classdef Accumulator < handle
    % This class is undocumented and subject to change in a future release
    
    % Holding on to a full array of values costs memory, and frequently
    % recalculating statistical measures costs time. This makes use of an
    % online algorithm originally from Knuth, whose numerical stability has
    % been thoroughly analyzed.
    
    % Copyright 2015-2016 The MathWorks, Inc.
    
    properties (Hidden, SetAccess=private)
        N    % sample size iterator
        XBar % running mean
        M2   % sum of squares of differences from the current mean
    end
    
    methods
        
        function A = Accumulator()
            A.reset();
        end
        
        function accumulate(A,v)
            % Accumulate value - store in running totals  
            n = A.N + 1;
            xb = A.XBar;
            
            delta = v - xb;
            xb = xb + delta ./ n;
            A.M2 = A.M2 + delta .* (v - xb);
            
            A.N = n;
            A.XBar = xb;
        end
        
        function xbar = mean(A)
            % Get current mean
            if A.N == 0
                xbar = NaN;
            else
                xbar = A.XBar;
            end
        end
        
        function s = std(A)
            % Get current standard deviation
            if A.N < 2
                % NaN for N=0, 0 for N=1
                s = 0 ./ A.N;
            else
                s = sqrt(A.M2 ./ (A.N-1));
            end
        end
        
        function e = stderr(A)
            % Get the Standard Error, representing the following
            % expression for a double vector X:
            %
            %   e = std(X) ./ sqrt(length(X))
            
            if A.N == 1
                e = 0;
            else
                % optimize - avoid calling STD explictly
                e = sqrt( A.M2 ./ (A.N .* (A.N-1) ) );
            end
            
        end
        
        function e = relStdErr(A)
            % Get the Relative Standard Error, representing the following
            % expression for a double vector X:
            %
            %   e = std(X) ./ mean(X) ./ sqrt(length(X))
            
            if A.N == 1
                e = 0;
            else
                % optimize - avoid calling STD and MEAN separately
                e = sqrt( A.M2 ./ (A.N .* (A.N-1) ) ) ./ A.XBar;
            end
            
        end
        
        function reset(A)
            A.N    = 0;
            A.XBar = 0;
            A.M2   = 0;
        end
        
    end
    
end