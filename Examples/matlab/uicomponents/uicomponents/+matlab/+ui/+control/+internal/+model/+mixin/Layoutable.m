classdef (Hidden) Layoutable < appdesservices.internal.interfaces.model.AbstractModelMixin
    % This undocumented class may be removed in a future release.
    %
    % This class provides the implementation for components that can be
    % parented to a layout container
    %
    % TODO: Implement this class in C++ so components implemented in C++
    % can also inherit from it
    %
    % Copyright 2017 The MathWorks, Inc.
    
    properties(Dependent, Transient, Access = {...
            ?matlab.ui.container.internal.model.Grid, ...
            ?matlab.ui.control.internal.controller.mixin.LayoutableController})
        LayoutConstraints
    end
    
    properties(Transient, Access = 'private')
        PrivateLayoutConstraints
    end
    
    methods
        
        function obj = Layoutable
            obj.PrivateLayoutConstraints = matlab.ui.control.internal.model.NoLayoutConstraints;
        end
        
        function set.LayoutConstraints(obj, value)
            
            % Error Checking
            if ~isa(value, 'matlab.ui.control.internal.model.LayoutConstraints')
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidLayoutConstraints';

                % Error message displayed to user
                messageText = 'LayoutConstraints must be in instance of matlab.ui.control.internal.model.LayoutConstraints';

                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throwAsCaller(exceptionObject);
            end
            
            % Property Setting
            obj.PrivateLayoutConstraints = value;
            
            % Update View
            markPropertiesDirty(obj, {'LayoutConstraints'});
        end
        
        function value = get.LayoutConstraints(obj)
            value = obj.PrivateLayoutConstraints;
        end
        
    end
    
end
