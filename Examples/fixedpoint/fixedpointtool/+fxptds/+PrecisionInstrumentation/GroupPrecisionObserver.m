classdef GroupPrecisionObserver < handle
    %% GROUPPRECISIONOBSERVER class
    % This class is responsible to provide observed precision information
    % about data type groups. The public API getObservedPrecision will
    % return an Nx2 vector of observed precision values, where N is the
    % number of groups
    % See also: ObservedPrecisionInstrumenter
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        instrumenter = fxptds.PrecisionInstrumentation.ObservedPrecisionInstrumenter();
    end
        
    methods
        function gop = getObservedPrecision(this, groups)
            gop = zeros(numel(groups), 2);
            for gIndex = 1:numel(groups)
                gop(gIndex,:) = this.getObservedPrecisionForGroup(groups{gIndex});
            end
        end
        
    end
    
    methods(Hidden)
        
        function gop = getObservedPrecisionForGroup(this, group)
            members = group.members.values;
            mop = zeros(numel(members), 2);
            for mIndex = 1:numel(members)
                
                mmop = this.getObservedPrecisionForMember(members{mIndex});
                mop(mIndex, :) = mmop;
                if any(isinf(mmop))
                    break
                end
            end
            gop = [SimulinkFixedPoint.extractMin(mop) SimulinkFixedPoint.extractMax(mop)];
        end
        
        function mmop = getObservedPrecisionForMember(this, result)
            values = this.getvalues(result);
            mmop = this.instrumenter.getPrecision(values);
        end
        
        function values = getvalues(~, result)
            values = [];
            if ~isempty(result.WholeNumber) && result.WholeNumber
                values = 1;
            else
                blkObj = result.getUniqueIdentifier.getObject;
                if isa(blkObj, 'Simulink.Constant')
                    % yes, 4 unecessary outputs, its not weird, its wabi
                    % sabi
                    [~,~,~,~, values] = SimulinkFixedPoint.slfxpprivate('evalNumericParameterRange',blkObj, blkObj.Value);
                    
                end
            end
        end
    end
end