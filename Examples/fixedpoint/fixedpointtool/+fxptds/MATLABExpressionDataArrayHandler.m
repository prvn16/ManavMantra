classdef MATLABExpressionDataArrayHandler < fxptds.AbstractDataArrayHandler
%MATLABVariableDataArrayHandler
    
% Copyright 2013-2014 The MathWorks, Inc.
    methods
        function this = MATLABExpressionDataArrayHandler(data_array)
            if nargin==0
                return
            end
            this.DataArray = data_array;
        end % MATLABVariableDataArrayHandler
        
    end
    
    methods
        function expression_identifier = getUniqueIdentifier(~,data)
            expression_identifier = ...
                fxptds.MATLABExpressionIdentifier(...
                    data.MATLABFunctionIdentifier,...
                    data.MxInfoID,...
                    data.TextStart,...
                    data.TextLength,...
                    data.IsArgin,...
                    data.IsArgout,...
                    data.IsGlobal,...
                    data.IsPersistent,...
                    data.Reason);
        end
        function expression_result = createResult(~,data)
            expression_result = fxptds.MATLABExpressionResult(data);
        end
    end
    
end
