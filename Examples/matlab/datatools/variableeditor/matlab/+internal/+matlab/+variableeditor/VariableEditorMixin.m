classdef VariableEditorMixin < handle
    %VariableEditorMixin Generic Variable Editor Support Mixin
    %   Implement this mixin to get Variable Editor Support

    % Copyright 2013 The MathWorks, Inc.

    % Public Abstract Methods
    methods(Access='public',Abstract=true)
        % getDataModel
        dataModel = getDataModel(this, document);

        % getViewModel
        dataModel = getViewModel(this, document);
        
        % getType
        type = getType(this);
    end
end

