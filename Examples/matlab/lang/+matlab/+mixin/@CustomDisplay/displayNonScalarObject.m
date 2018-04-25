%displayNonScalarObject    Display format for non-scalar objects
%   displayNonScalarObject(A) is called by the DISP method when the object
%   array A is non-scalar (i.e., PROD(SIZE(A)) > 1). The default display
%   of a non-scalar object array consists of a header and list of 
%   properties.  The properties are shown in the order that they are
%   defined in the class definition. 
%
%   Override this method as a protected method to customize the appearance 
%   of a non-scalar objectarray.
%
%   The default display of a non-scalar object array consists of a header
%   and a list of property names. The header consists of the object's
%   dimensions and the properties are shown in the order defined in the
%   class definition.  Only visible properties with public GetAccess are
%   shown. 
%
%   See also matlab.mixin.CustomDisplay, displayScalarObject,
%   displayEmptyObject

%   Copyright 2013-2015 The MathWorks, Inc.
%   Built-in method.   
