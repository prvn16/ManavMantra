classdef PropertyGroup< matlab.mixin.Heterogeneous
%matlab.system.display.PropertyGroup   Abstract base class for System object display property group

     
    %   Copyright 2012-2014 The MathWorks, Inc.

    methods
        function out=PropertyGroup
            %matlab.system.display.PropertyGroup   Abstract base class for System object display property group
        end

    end
    methods (Abstract)
    end
    properties
        %Actions   Group actions
        %   Actions of this property group as matlab.system.display.Action
        %   objects.  The default value of this property is empty.
        Actions;

        %Description   Group description    
        %   Description of this property group as a string.  The default 
        %   value of this property is an empty string.
        Description;

        %PropertyList   Group property list
        %   List of property names in this group as a cell array of 
        %   strings.  The default value of this property is an empty cell
        %   array.
        PropertyList;

        %Title   Group title
        %   Title of this property group as a string.  The default value of 
        %   this property is an empty string.
        Title;

        %TitleSource   Group title source
        %   Source of this property group's title.  May be set to 'Auto' or 
        %   'Property'.  If TitleSource is set to 'Auto', an automatic 
        %   property group title is used.  If TitleSource is set to
        %   'Property', then the title defined in the Title property is 
        %   used.  The default value of this property is 'Property'.
        TitleSource;

    end
end
