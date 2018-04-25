%getPropertyGroups   Construct an array of property groups 
%   GROUPS = getPropertyGroups(A) returns a array of
%   matlab.mixin.util.PropertyGroup objects. When displayed, property
%   groups are separated by blank lines.
%
%   This method is called by the default state handler methods each time
%   an instance of the class is displayed. Override this method as a protected
%    method to construct one or more customized groups of properties to display.
%
%   Each PropertyGroup has the following fields:
%   Title (string) - property group header or '' if no group header needed 
%   PropertyList   - either a 1x1 struct of name-value pairs, OR a cell
%      array of string property names. Use the struct of name-value pairs
%      only if the object is scalar and custom property values are
%      required.  Otherwise, return a cell array of string property
%      names. If the PropertyList is a cell array and A is scalar the
%      property values will be retrieved from the object when it is
%      displayed.
%
%   The default implementation returns a 1x1 PropertyGroup with:
%   Title         - empty string (default has no header)
%   PropertyList  - a cell array of string property names, where each name
%      corresponds to one visible, gettable property of the object. If the
%      object is scalar, dynamic properties (if present) are included.
%
%   See also matlab.mixin.util.PropertyGroup, matlab.mixin.CustomDisplay,
%   getHeader, getFooter

%   Copyright 2013-2015 The MathWorks, Inc.
%   Built-in method.   
