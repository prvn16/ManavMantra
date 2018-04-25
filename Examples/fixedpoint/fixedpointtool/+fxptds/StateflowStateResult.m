classdef StateflowStateResult < fxptds.StateflowResult
% STATEFLOWRESULT Class definition for results corresponding to stateflow objects excluding charts

% Copyright 2013-2015 The MathWorks, Inc.

    methods
        function this = StateflowStateResult(data)
        % Class should be able to instantiate with no input arguments
            if nargin == 0
                argList = {};
            else
                argList{1} = data;
            end
            this@fxptds.StateflowResult(argList{:});            
        end           
    end    
    
    methods(Hidden)
      
        function computeIfInheritanceReplaceable(this)
            this.IsInheritanceReplaceable  = false;
        end
    end

end

% LocalWords:  truthtable
