% horzcat   Horizontal concatenation for heterogeneous arrays
%    [A B] is the horizontal concatenation of matlab.mixin.Heterogeneous  
%    objects A and B.  A and B must have the same number of rows.  Any
%    number of matlab.mixin.Heterogeneous objects can be concatenated 
%    within one pair of brackets provided they are all derived from the  
%    same root superclass derived from matlab.mixin.Heterogeneous.  
%
%    The matlab.mixin.Heterogeneous method C = HORZCAT(A,B) is called for  
%    the expressions [A  B] and [A, B] when A is an array of
%    matlab.mixin.Heterogeneous objects.  If A and B are of the same class,
%    the class of the resulting array is unchanged.  If A and B are of
%    different classes derived from the same root class, then the result is
%    a heterogeneous array and its class is that of the most specific
%    superclass shared by A and B.  If B is not a member of the same
%    hierarchy as A, MATLAB will automatically call the root class'
%    convertObject method if defined, and will error if not defined.
%
%    The HORZCAT method is sealed in the matlab.mixin.Heterogeneous class 
%    and cannot be overridden by subclasses.
%
%    See also HORZCAT, matlab.mixin.Heterogeneous, convertObject
 
%   Copyright 2009-2010 The MathWorks, Inc.
%   Built-in method.