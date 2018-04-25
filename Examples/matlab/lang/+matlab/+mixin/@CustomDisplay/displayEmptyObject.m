% displayEmptyObject Display for empty object arrays
%    displayEmptyObject(A) displays the empty object array A.
%
%    This method is called by the sealed DISP and DISPLAY methods of
%    matlab.mixin.CustomDisplay when the input object array is empty. An
%    object array is considered to be empty if one or more of its
%    dimensions are zero.
%
%    Override this method as a protected method to customize the appearance 
%    of an empty object array. 
%
%    The default display of an empty object array consists of a header and
%    a list of property names. The header consists of the object's
%    dimensions and the properties are shown in the order defined in the
%    class definition.  Only visible properties with public GetAccess are
%    shown.
%
%    See also matlab.mixin.CustomDisplay, displayScalarObject,
%    displayNonScalarObject

%   Copyright 2013-2015 The MathWorks, Inc.
%   Built-in method.   
