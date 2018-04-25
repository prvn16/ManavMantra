classdef ObservedPrecisionInstrumenter < handle
    %% OBSERVEDPRECISIONINSTRUMENTER class
    
    % Copyright 2017 The MathWorks, Inc.
    methods
        function op = getPrecision(this, values)
            % flatten the values into a vector (could be an N-dimensional
            % array)
            values = double(reshape(values, 1, numel(values)));
            
            op = [-Inf Inf];
            
            % precision is a power of 2 i.e. 4.5, -0.25, 23.125 etc. {k<=0}
            if ~isempty(values) && this.iswholeandbin(values)
                vf = values - floor(values);
                vzero = vf==0;
                v = log2(vf);
                v(vzero) = 0;
                op = [min(v) max(v)];
            end
        end
        
    end
    
    methods(Hidden)
        
        function s = iswholeandbin(this, values)
            s = this.isbin(values - floor(values));
        end
        
        function s = isbin(this, values)
            s = this.iswhole(log2(values));
        end
        
        function s = iswhole(~, values)
            s = all(floor(values)==values);
        end
    end
    
end