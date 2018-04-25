classdef CustomIcon< handle
%matlab.system.mixin.CustomIcon Mixin for defining custom icon
%   The CustomIcon mixin is a base class for System objects that use the
%   getIcon method to show an icon in Simulink.   
%
%   To use this mixin, subclass your System object from this
%   class in addition to the matlab.System base class and define the icon 
%   in the getIconImpl method.  Use the following syntax as the first line
%   of your class definition file, where ObjectName is the name of 
%   your object:
%   
%   classdef ObjectName < matlab.System &...    
%       matlab.system.mixin.CustomIcon

     
%   Copyright 2013-2016 The MathWorks, Inc.

    methods
        function out=CustomIcon
            %matlab.system.mixin.CustomIcon Mixin for defining custom icon
            %   The CustomIcon mixin is a base class for System objects that use the
            %   getIcon method to show an icon in Simulink.   
            %
            %   To use this mixin, subclass your System object from this
            %   class in addition to the matlab.System base class and define the icon 
            %   in the getIconImpl method.  Use the following syntax as the first line
            %   of your class definition file, where ObjectName is the name of 
            %   your object:
            %   
            %   classdef ObjectName < matlab.System &...    
            %       matlab.system.mixin.CustomIcon
        end

    end
    methods (Abstract)
        getIconImpl; %#ok<NOIN>

    end
end
