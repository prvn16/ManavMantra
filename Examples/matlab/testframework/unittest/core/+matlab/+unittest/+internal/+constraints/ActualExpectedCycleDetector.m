classdef ActualExpectedCycleDetector
    %This class is undocumented.
    
    % Copyright 2015-2016 The MathWorks, Inc.
    properties(Access = private)
        ActHandlesCompared = cell(0,1);
        ExpHandlesCompared = cell(0,1);
    end
    
    methods
        function bool = haveAlreadyVisited(cycleDetector, actVal, expVal)

            %We only do detection when both inputs are handle objects
            if ~builtin('isa',actVal,'handle') || ~builtin('isa',expVal,'handle')
                bool = false;
                return;
            end
            
            strictEq = @matlab.unittest.internal.constraints.StrictHandleComparer.eq;
            
            %For performance reasons, it is assumed that actVal and expVal
            %are both scalar.
            matchInds = cellfun(@(h) strictEq(h,actVal), ...
                cycleDetector.ActHandlesCompared);
            matchInds(matchInds) = cellfun(@(h)strictEq(h,expVal), ...
                cycleDetector.ExpHandlesCompared(matchInds));
            bool = any(matchInds);
        end
        
        function cycleDetector = visit(cycleDetector, actVal, expVal)
            
            %We only do detection when both inputs are handle objects
            if ~builtin('isa',actVal,'handle') || ~builtin('isa',expVal,'handle') 
                return;
            end
            
            %For performance reasons, it is assumed that actVal and expVal
            %are both scalar.
            cycleDetector.ActHandlesCompared = ...
                [cycleDetector.ActHandlesCompared {actVal}];
            cycleDetector.ExpHandlesCompared = ...
                [cycleDetector.ExpHandlesCompared {expVal}];
        end
    end
end