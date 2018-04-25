% getDefaultScalarElement   Create a default object for heterogeneous arrays
%    The getDefaultScalarElement method is called automatically by MATLAB 
%    when an expression such as indexed assignment creates gaps in any
%    array derived from matlab.mixin.Heterogeneous.  It is not legal to
%    have gaps in an array of  MATLAB objects, so the gaps are filled in
%    with default objects returned by this method.
%
%    Consider the following heterogeneous hierarchy, with the root class
%    Root defining the set of classes that can be combined together into a
%    valid heterogeneous array:
%
%                       matlab.mixin.Heterogeneous
%                                  |
%                                 Root
%                              /        \
%                           Middle       LeafD
%                         /    |   \ 
%                    LeafA   LeafB  LeafC
%
%    %Example #1:
%    o = LeafA;
%    o(2) = LeafB; 
%    o(5) = LeafC;
%
%    In the sequence above, the assignment to array position 5 leaves a 
%    gap in the array, because positions o(3) and o(4) are not explicitly
%    assigned values.  MATLAB will call the getDefaultScalarElement
%    method to fill the gap. 
%
%    The getDefaultScalarElement method has the following signature, and 
%    must be implemented as static, sealed, and protected:
%        obj = getDefaultScalarElement
%
%    The matlab.mixin.Heterogeneous class provides a default implementation 
%    of getDefaultScalarElement, which will return an instance of the root 
%    class if the root class is not abstract, and will error otherwise.  
%    If the root class is abstract, or it is not an appropriate default 
%    object for the collection of classes, override getDefaultScalarElement 
%    in the root class to return an instance of some other member of the 
%    class hierarchy.  
%
%    getDefaultScalarElement can return an instance of any class
%    derived from Root.  The class of the resulting array will then be
%    determined on the basis of the specific class instances in the 
%    resulting array.  MATLAB will issue an error if the value returned
%    by getDefaultScalarElement is not scalar or is not a valid member of
%    the hierarchy of classes.
%
%    The getDefaultScalarElement method is also called when loading an 
%    object  from  a MAT-file if a specific class definition cannot be 
%    found or contains an error.  MATLAB will issue a warning if a default 
%    object is being used in place of a specific object due to an error.
%
%    See also matlab.mixin.Heterogeneous, LOAD
 
%   Copyright 2009-2010 The MathWorks, Inc.
%   Built-in method.

