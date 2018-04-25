classdef CategoricalViewModel < internal.matlab.variableeditor.ArrayViewModel
    % CategoricalViewModel
    % Categorical variables ViewModel

    % Copyright 2013-2017 The MathWorks, Inc.

    % Public Abstract Methods
    methods(Access='public')
        % Constructor
        function this = CategoricalViewModel(dataModel)
            this@internal.matlab.variableeditor.ArrayViewModel(dataModel);
        end
        
        % Returns the categories for the categorical variable.
        function c = getCategories(this)
            c = categories(this.DataModel.getData());
            
            % Limit the number of categories displayed, otherwise we
            % hit OutOfMemory errors
            c(internal.matlab.variableeditor.FormatDataUtils.MAX_CATEGORICALS:end) = [];
        end
        
        % Returns true if the categorical variable is protected, and false
        % if it is not.  (Protected categorical variables cannot have new
        % categories added to them).
        function p = isProtected(this)
            p = isprotected(this.DataModel.getData());
        end
    end
end
