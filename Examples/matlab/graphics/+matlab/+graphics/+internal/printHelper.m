classdef printHelper < handle
    % printHelper - Helper class used by printing.
    %
    % This undocumented helper class is for internal use.
    
    %   Copyright 2008-2016 The MathWorks, Inc.
        
    methods (Static) 
        % request java perform garbage collection every MAX_PRINT_COUNT
        % times
        function [requestedCount, MAX_PRINT_COUNT] = requestGCIfNeeded()
           MAX_PRINT_COUNT = 25;
           persistent printCountSinceLastGC;
           if isempty(printCountSinceLastGC)
               printCountSinceLastGC = 0;
           end
           printCountSinceLastGC = printCountSinceLastGC + 1;
           if ~mod(printCountSinceLastGC, MAX_PRINT_COUNT)
               java.lang.System.gc();
               printCountSinceLastGC = 0;
           end
           requestedCount = printCountSinceLastGC;
        end
    end
end
