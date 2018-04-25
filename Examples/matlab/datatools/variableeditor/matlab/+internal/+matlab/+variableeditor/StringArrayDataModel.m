classdef StringArrayDataModel < ...
        internal.matlab.variableeditor.ArrayDataModel & ...
        internal.matlab.variableeditor.EditableVariable
    % StringArrayDataModel - The Data Model for string array variables
    
    % Copyright 2015 The Mathworks, Inc.
    
    % Type Property
    properties (Constant)
        Type = 'String';
        ClassType = 'string';
    end
    
    % Data
    properties (SetObservable=true, SetAccess='public', ...
            GetAccess='public', Dependent=false, Hidden=false)
        % Data Property
        Data;
    end
    
    methods
        function storedValue = get.Data(this)
            % Store the data
            storedValue = this.Data;
        end
        
        function set.Data(this, newValue)
            % Set the data if it is a string array variable
            if ~internal.matlab.variableeditor.FormatDataUtils.checkIsString(newValue)
                error(message('MATLAB:codetools:variableeditor:NotAStringArrayVariable'));
            end
            
            reallyDoCopy = ~isequal(this.Data, newValue);
            if reallyDoCopy
                this.Data = newValue;
            end
        end
    end
    
    methods(Access='public')
        % returns the rhs value. In this case, it is the value as specified
        % by the user
        function rhs = getRHS(~, newValue)
            val = newValue;
            if isempty(newValue)
                rhs = '""';
            else
                rhs = val; %['"' val '"'];
            end
        end
    end
    
    methods(Access='protected')
        % Returns the left hand side of an assigntment operation
        function lhs=getLHS(~,idx)
            lhs = sprintf('(%s)',idx);
        end
    end
end


