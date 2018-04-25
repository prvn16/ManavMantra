classdef (Hidden) HorizontallyAlignableComponent < appdesservices.internal.interfaces.model.AbstractModelMixin
    % This undocumented class may be removed in a future release.
    
    % This is a mixin parent class for all visual components that have an
    % 'HorizontalAlignment' property
    %
    % This class provides all implementation and storage for
    % 'HorizontalAlignment'
    
    % Copyright 2012-2015 The MathWorks, Inc.
    
    properties(Dependent)
        HorizontalAlignment = 'left';
    end
    
    properties(Access = 'private')
        % Internal properties
        %
        % These exist to provide: 
        % - fine grained control for each property
        %
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateHorizontalAlignment = 'left';
    end
      
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        function set.HorizontalAlignment(obj, newValue)
            % Error Checking
            try
                newHorizontalAlignment = matlab.ui.control.internal.model.PropertyHandling.processEnumeratedString(...
                    obj, ...
                    newValue, ...
                    {'center', 'left', 'right'});
            catch %#ok<*CTCH>
                messageObj = message('MATLAB:ui:components:invalidThreeStringEnum', ...
                    'HorizontalAlignment', 'left', 'center', 'right');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidHorizontalAlignment';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception 
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting
            obj.PrivateHorizontalAlignment = newHorizontalAlignment;
            
            % Update View
            markPropertiesDirty(obj, {'HorizontalAlignment'});
        end
        
        function value = get.HorizontalAlignment(obj)
            value = obj.PrivateHorizontalAlignment;
        end
    end
end
