%matlab.mixin.util.PropertyGroup Display customization helper class
%   P = matlab.mixin.util.PropertyGroup(PROPERTYLIST) constructs a
%   property group with the supplied PROPERTYLIST. The PROPERTYLIST may
%   either be a cell array of property names, or a scalar struct with
%   property name-value pairs. 
%
%   P = matlab.mixin.util.PropertyGroup(PROPERTYLIST, TITLE) constructs a
%   property group with a optional TITLE. The TITLE will display above the
%   list of properties.   
%
%   Objects of the PropertyGroup class are used by
%   matlab.mixin.CustomDisplay to customize the appearance of properties
%   for display. The matlab.mixin.CustomDisplay method getPropertyGroups
%   can be overloaded to return a customized PropertyGroup.
%
%   The PropertyList is the list of properties to display for a
%   matlab.mixin.CustomDisplay object. When the PropertyList is a cell
%   array of strings, each element must be the name of a visible property
%   that is publicly gettable. When the PropertyList is a scalar struct,
%   the field names will be shown as the properties of the
%   matlab.mixin.CustomDisplay object, and the struct values will be shown
%   as if they belong to the object.
%
%
%   PropertyGroup properties:
%     PropertyList   - The list of properties to display, stored as a
%                      scalar struct or a cell array of strings
%     Title          - An optional Title for the PropertyGroup    
%     NumProperties  - The number of properties in the PropertyList
%
%   See also matlab.mixin.CustomDisplay,
%   matlab.mixin.CustomDisplay/getPropertyGroups 

%   Copyright 2013 The MathWorks, Inc.
%   Built-in class.   

