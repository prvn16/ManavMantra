classdef Icon
%matlab.system.display.Icon   System object icon
%   ICON = matlab.system.display.Icon(FILE) creates an icon used for
%   displaying the image in FILE. The FILE input is a string containing the 
%   name of a file and can include a path and file name extension.
%
%   You use matlab.system.display.Icon to define an icon in getIconImpl.

     
    %   Copyright 2016 The MathWorks, Inc.

    methods
        function out=Icon
            %matlab.system.display.Icon   System object icon
            %   ICON = matlab.system.display.Icon(FILE) creates an icon used for
            %   displaying the image in FILE. The FILE input is a string containing the 
            %   name of a file and can include a path and file name extension.
            %
            %   You use matlab.system.display.Icon to define an icon in getIconImpl.
        end

    end
    methods (Abstract)
    end
end
