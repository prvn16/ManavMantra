classdef CharArrayDataModel < ...
        internal.matlab.variableeditor.ArrayDataModel & ...
        internal.matlab.variableeditor.EditableVariable
    % CharArrayDataModel - The Data Model for char array variables
    
    % Copyright 2014 The Mathworks, Inc.
    
    % Type Property
    properties (Constant)
        Type = 'Char';
        ClassType = 'char';
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
            % Set the data if it is a char array variable
            if ~ischar(newValue)
                error(message('MATLAB:codetools:variableeditor:NotACharArrayVariable'));
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
            rhs =  newValue;
        end        
    end
end


