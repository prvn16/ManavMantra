classdef LogicalArrayDataModel < ...
        internal.matlab.variableeditor.ArrayDataModel
    % LOGICALARRAYDATAMODEL 
    % Logical Array Data Model
    %
    % Copyright 2015 The MathWorks, Inc.

    properties (Constant)
        % Type Property
        Type = 'LogicalArray';
        
        ClassType = 'logical';
    end

    % Data
    properties (SetObservable = true)
        % Data Property
        Data
    end
    
    methods
        function storedValue = get.Data(this)
            storedValue = this.Data;
        end
        
        % Sets the data - Data must be a two dimensional logical array
        function set.Data(this, newValue)
            if ~islogical(newValue) || numel(size(newValue)) ~= 2
                error(message(...
                    'MATLAB:codetools:variableeditor:NotAnMxNLogicalArray'));
            end
            this.Data = newValue;
        end        
        
        % Returns the right hand side of a formatted assignment string
        function rhs = getRHS(~, newValue)
            rhs = newValue;            
        end        
    end

    methods (Access = protected)
        % Returns the left hand side of an assigntment operation
        function lhs=getLHS(~,idx)
            lhs = sprintf('(%s)',idx);
        end
    end
end