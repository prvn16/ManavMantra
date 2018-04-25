classdef (Hidden) BackgroundColorableComponent < appdesservices.internal.interfaces.model.AbstractModelMixin
    % This undocumented class may be removed in a future release.
    
    % This is a mixin parent class for all visual components that support
    % background color customization.
    %
    % This class provides all implementation and storage for:
    %
    % * BackgroundColor   3x1 numeric array represting the rgb color value     
    
    % Copyright 2013-2015 The MathWorks, Inc.
    
    
    properties
        % BackgroundColor has its own validation and limited logic in the 
        % public setter.  There will be no PrivateBackgroundColor storage
        % In order to cut down on the number of Private properties
        BackgroundColor@matlab.graphics.datatype.RGBColor = 'white';
        
    end
    
    properties (Access = protected)
        % These values will be used to help standardize the colors commonly
        % used by the components as a default color. Components can choose
        % to use these color constants when constructing themselves.
        DefaultWhite = [1, 1, 1];
        DefaultGray = [.96, .96, .96];
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
            
        function set.BackgroundColor(obj, newColor)
            
            % Update Model
            obj.BackgroundColor = newColor;
            
            % Update View
            markPropertiesDirty(obj, {'BackgroundColor'});
        end
    end
end


