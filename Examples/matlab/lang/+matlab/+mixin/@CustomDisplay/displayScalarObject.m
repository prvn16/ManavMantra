%displayScalarObject Display format for scalar objects
%   displayScalarObject(A) is called by the DISP method when the object
%   array is scalar (i.e., PROD(SIZE(A) == 1). The default display of a
%   scalar object array consists of a header and a list of properties and
%   their values.  Properties are shown in the order that they are defined
%   in the class definition.  Only visible properties with public
%   GetAccess are shown. 
%
%   Override this method as a protected method to customize the appearance 
%   of a scalar object array.
%   
%   The default display of a scalar object consists of a header and a list
%   of property names with corresponding property values. The header
%   consists of the object's dimensions and the properties are shown in
%   the order defined in the class definition. Only visible properties
%   with public GetAccess are shown.
%
%   See also matlab.mixin.CustomDisplay, displayNonScalarObject,
%   displayEmptyObject

%   Copyright 2013-2015 The MathWorks, Inc.
%   Built-in method.   
