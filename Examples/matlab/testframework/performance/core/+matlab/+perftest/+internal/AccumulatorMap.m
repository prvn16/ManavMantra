classdef AccumulatorMap < handle
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Hidden, SetAccess=private)
        Map
    end
    
    methods
        function AMap = AccumulatorMap()
            AMap.reset;
        end
        
        function reset(C)
            C.Map = containers.Map;
        end
        
        function accumulate(C, V)
            import matlab.perftest.internal.Accumulator;

            for key = V.keys
                label = key{:};
                value = V(label);
                if ~C.Map.isKey(label)
                    % create new accumulator for new label
                    C.Map(label) = Accumulator();
                end
                A = C.Map(label);
                A.accumulate(value);
                C.Map(label) = A;
            end
        end
        
        function withinTarget = checkMoE(C, TScore, targetMoE)
            % analyze Margins of Error, returns true if MoE for all labels
            % are within the target
            withinTarget = true;
            for key = C.Map.keys
                label = key{:};
                A = C.Map(label);
                
                withinTarget = (A.N >= 2) && (A.std == 0 || ...
                    TScore(A.N-1) * A.relStdErr <= targetMoE);
                
                if ~withinTarget
                    return;
                end
            end
        end
    end
end