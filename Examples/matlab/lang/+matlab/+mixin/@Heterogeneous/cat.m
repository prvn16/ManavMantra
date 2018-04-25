% cat    Concatenation for heterogeneous arrays
%    CAT(DIM,A,B) concatenates objects A and B along the dimension DIM.
%    The class of object arrays A and B must be derived from the same root
%    class, which must be a direct subclass of matlab.mixin.Heterogeneous.
%
%    If A and B are of the same class, the class of the resulting array
%    is unchanged.  If A and B are of different subclasses of a common
%    root superclass derived from matlab.mixin.Heterogeneous, then the
%    result is a heterogeneous array and its class is that of the most 
%    specific superclass shared by A and B.  If B is not a member of the 
%    same hierarchy as A, MATLAB will automatically call the convertObject
%    method if defined in the root class, and will error if the method is 
%    not defined.
%
%    The CAT method is sealed in the matlab.mixin.Heterogeneous class and
%    cannot be overridden by subclasses.
%
%    See also CAT, matlab.mixin.Heterogeneous
 
%   Copyright 2009-2010 The MathWorks, Inc.
%   Built-in method.
