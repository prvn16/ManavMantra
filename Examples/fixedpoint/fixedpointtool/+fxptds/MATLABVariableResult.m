classdef MATLABVariableResult < fxptds.MATLABExpressionResult
    %MATLABVariableResult
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    methods
        
        function this = MATLABVariableResult(data)
            if nargin  == 0
                argList = {};
            else
                argList = {data};
            end
            this@fxptds.MATLABExpressionResult(argList{:});
        end % MATLABVariableResult()
        
        function icon = getDisplayIcon(this)
            icon = fullfile('toolbox','fixedpoint','fixedpointtool',...
                'resources',['Var' this.Alert '.png']);
        end % getDisplayIcon()
        
        function setDerivedRangeState(this)
            % HASISSUESWITHDERIVEDRANGES Inspect the result and find if there is an issue with the derived range
            % If the result is an output then check if the derived ranges are based on sufficient range information.
            this.DerivedRangeState = fxptds.DerivedRangeStates.Default;
            hasinsufficientrange = this.hasInsufficientRange && this.hasDerivedMinMax;
            if hasinsufficientrange
                % If there is insuffifient range, check if any design range on the
                % block is empty or if it is an inport block as a
                % possible source of empty ranges. The user facing message can be
                % more granular based on the source of this insufficient range.
                this.DerivedRangeState = fxptds.DerivedRangeStates.InsufficientRange;
            else % does has sufficient range but check for empty intersection
                % check to see intersection
                if this.hasConflictingDesignAndDerivedRangeIntersection
                    this.DerivedRangeState = fxptds.DerivedRangeStates.EmptyIntersection;
                end
            end
            this.setCommentsForDerivedRanges;
        end
    end
    
    methods(Access=protected)
        
        function uniqueID = createUniqueIdentifierForData(~, data)
            dh = fxptds.MATLABVariableDataArrayHandler;
            uniqueID = dh.getUniqueIdentifier(data);
        end % createUniqueIdentifierForData()
        
        
    end % methods(Access=protected)
    
end
