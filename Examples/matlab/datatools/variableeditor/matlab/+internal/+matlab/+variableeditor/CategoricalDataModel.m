classdef CategoricalDataModel < ...
        internal.matlab.variableeditor.ArrayDataModel & ...
        internal.matlab.variableeditor.EditableVariable
    % CategoricalDataModel - The Data Model for categorical variables
    
    % Copyright 2013-2017 The Mathworks, Inc.
    
    % Type Property
    properties (Constant)
        Type = 'Categorical';
        ClassType = 'categorical';
    end
    
    % Data
    properties (SetObservable=true, SetAccess='public', ...
            GetAccess='public', Dependent=false, Hidden=false)
        % Data Property
        Data;
        Categories;
        Protected;
    end
    
    methods
        function storedValue = get.Data(this)
            % Store the data
            storedValue = this.Data;
        end
        
        function set.Data(this, newValue)
            % Set the data if it is a categorical variable
            if ~isa(newValue, 'categorical')
                error(message('MATLAB:codetools:variableeditor:NotACategoricalVariable'));
            end
            
            reallyDoCopy = ~isequal(this.Data, newValue);
            if reallyDoCopy
                this.Data = newValue;
                this.Categories = categories(newValue); %#ok<*MCSUP>
                
                % Limit the number of categories displayed, otherwise we
                % hit OutOfMemory errors
                this.Categories(internal.matlab.variableeditor.FormatDataUtils.MAX_CATEGORICALS:end) = [];
                this.Protected = isprotected(newValue);
            end
        end
    end
    
    methods(Access='public')
        function rhs = getRHS(~, newValue)
            % Overriding ArrayDataModel version to add in quotes
            rhs=['''' newValue ''''];
        end
        
    end
end
