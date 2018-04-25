classdef (Hidden) ButtonComponent < matlab.ui.control.internal.model.mixin.IconableComponent & ...
        matlab.ui.control.internal.model.mixin.IconAlignableComponent & ...
        matlab.ui.control.internal.model.mixin.HorizontallyAlignableComponent & ...
        matlab.ui.control.internal.model.mixin.VerticallyAlignableComponent & ...
        matlab.ui.control.internal.model.mixin.MultilineTextComponent & ...
        matlab.ui.control.internal.model.mixin.BackgroundColorableComponent 
   
    % This undocumented class may be removed in a future release.
    
    % This class gathers mixins that are at the core of button components, 
    % e.g. Push Button, Toggle Button, etc.
    %
    % Those mixins provide the properties related to the Text and Icon of
    % the button components
    
    % Copyright 2014 The MathWorks, Inc.
    methods
        function obj = ButtonComponent()
    
            % Set default BackgroundColor
            obj.BackgroundColor = obj.DefaultGray;
        end
    end
end