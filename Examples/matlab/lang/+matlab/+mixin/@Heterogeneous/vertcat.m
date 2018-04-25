% VERTCAT   Vertical concatenation for heterogeneous arrays
%    [A ; B] is the vertical concatenation of matlab.mixin.Heterogeneous
%    objects A and B.  A and B must have the same number of columns.  You  
%    can concatenate any number of matlab.mixin.Heterogeneous objects  
%    within one pair of brackets, provided they are all subclasses of the  
%    same root class derived from matlab.mixin.Heterogeneous.    
%
%    The matlab.mixin.Heterogeneous method Y = VERTCAT(A,B) is called for 
%    the expression [A; B] when A is an array of matlab.mixin.Heterogeneous 
%    objects.  If A and B are of the same class, the class of the 
%    resulting array is unchanged.  If A and B are of different classes 
%    derived from the same root class, then the result is a heterogeneous
%    array and its class is that of the most specific superclass shared by
%    A and B.  If B is not a member of the same hierarchy as A, MATLAB will 
%    automatically call the root class' convertObject method if defined, 
%    and will error if not defined.
%
%    The VERTCAT method is sealed in the matlab.mixin.Heterogeneous class 
%    and cannot be overridden by subclasses.
%
%    See also VERTCAT, matlab.mixin.Heterogeneous, convertObject
 
%   Copyright 2009-2010 The MathWorks, Inc.
%   Built-in method.
