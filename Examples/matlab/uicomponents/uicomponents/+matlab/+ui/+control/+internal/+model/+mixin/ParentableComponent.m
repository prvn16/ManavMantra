classdef (Hidden) ParentableComponent < ...
        appdesservices.internal.interfaces.model.AbstractModelMixin
    % ParentableComponent is the parent class of a component that can be
    % parented to other components.
    
    % Copyright 2012-2015 The MathWorks, Inc.
    
    properties(Access = 'protected')
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        PrivateParent;
    end
    
    methods
        function obj = ParentableComponent()
            
        end
    end
    
    methods(Access = 'protected')
        function validateParentAndState(obj, newParent)
            % Validator for 'Parent'
            %
            % Can be extended / overriden to provide additional validation
            
            % Error Checking
            %
            % A valid parent is one of:
            % - a parenting component
            % - empty []
            
            % Only validate if the value is non empty
            %
            % Empty values are acceptible for not having a parent
            if(~isempty(newParent))
                
                isAcceptableParent = ...
                    ... TODO: figure out why we are checking specifically against CanvasContainer
                    isa(newParent, 'matlab.ui.container.CanvasContainer') || ...
                    isa(newParent, 'matlab.ui.container.internal.model.Grid');
                
                if( ~isAcceptableParent )
                    
                    messageObj = message('MATLAB:ui:components:invalidParent', ...
                        'Parent');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'invalidParent';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                    throw(exceptionObject);
                    
                end
            end
            
        end
	end      
end



