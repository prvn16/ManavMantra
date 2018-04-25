classdef StringSet< matlab.system.internal.ConstrainedSet & matlab.mixin.CustomDisplay
%StringSet string validation object for use with System objects
%
%   StringSet objects define valid values for System object string
%   properties.  StringSets limit property values to specified
%   strings. StringSets also allow tab completion and case-insensitive
%   matching. 
%
%   For example, to use a StringSet for a string property
%   named "MyProp", create a StringSet property by concatenating 
%   the property name with the word "Set" ("MyPropSet").
%
%   classdef MyClass < matlab.System
%     properties 
%       MyProp = "Value1"  % default value
%     end
%     properties (Hidden)
%       MyPropSet = matlab.system.StringSet(["Value1", "Value2", "Value3"])
%     end
%   end

   
  %   Copyright 1995-2017 The MathWorks, Inc.

    methods
        function out=StringSet
            %StringSet string validation object for use with System objects
            %
            %   StringSet objects define valid values for System object string
            %   properties.  StringSets limit property values to specified
            %   strings. StringSets also allow tab completion and case-insensitive
            %   matching. 
            %
            %   For example, to use a StringSet for a string property
            %   named "MyProp", create a StringSet property by concatenating 
            %   the property name with the word "Set" ("MyPropSet").
            %
            %   classdef MyClass < matlab.System
            %     properties 
            %       MyProp = "Value1"  % default value
            %     end
            %     properties (Hidden)
            %       MyPropSet = matlab.system.StringSet(["Value1", "Value2", "Value3"])
            %     end
            %   end
        end

        function displayScalarObject(in) %#ok<MANU>
        end

        function findMatch(in) %#ok<MANU>
        end

        function getAllowedValues(in) %#ok<MANU>
        end

        function getIndex(in) %#ok<MANU>
        end

        function getValueFromIndex(in) %#ok<MANU>
        end

        function isAllowedValue(in) %#ok<MANU>
        end

        function setValues(in) %#ok<MANU>
        end

    end
    methods (Abstract)
    end
end
