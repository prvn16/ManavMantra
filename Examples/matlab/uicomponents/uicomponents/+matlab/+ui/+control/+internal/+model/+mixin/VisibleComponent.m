classdef (Hidden) VisibleComponent < appdesservices.internal.interfaces.model.AbstractModelMixin
    % This undocumented class may be removed in a future release.
    
    % This is a mixin parent class for all visual components that have an
    % 'Visible' property
    %
    % This class provides all implementation and storage for 'Visible'
    
    % Copyright 2014-2015 The MathWorks, Inc.
    
    properties(Dependent)
        Visible@matlab.graphics.datatype.on_off = 'on';
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
        
        PrivateVisible@matlab.graphics.datatype.on_off = 'on';
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        function set.Visible(obj, newVisible)
            
            % Error Checking done through the datatype specification
            
            % Property Setting
            obj.PrivateVisible = newVisible;
            
            % Mark dirty so that update traversal kicks in. see g1243066
            obj.markComponentDirty();
            
            % Update View
            markPropertiesDirty(obj, {'Visible'});
        end
        
        function value = get.Visible(obj)
            value = obj.PrivateVisible;
        end
    end
end
