classdef (Hidden) EditableComponent < appdesservices.internal.interfaces.model.AbstractModelMixin
    % This undocumented class may be removed in a future release.
    
    % This is a mixin parent class for all visual components that have an
    % 'Editable' property
    %
    % This class provides all implementation and storage for 'Editable'
    
    % Copyright 2012-2015 The MathWorks, Inc.
    
    properties(Dependent)
        Editable@matlab.graphics.datatype.on_off;
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
        
        PrivateEditable@matlab.graphics.datatype.on_off = 'on';
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        function set.Editable(obj, newEditable)
            
            % Error Checking done through the datatype specification
            
            % Property Setting
            obj.PrivateEditable = newEditable;
            
               % Update View
            markPropertiesDirty(obj, {'Editable'});
        end
        
        function value = get.Editable(obj)
            value = obj.PrivateEditable;
        end
    end
end
