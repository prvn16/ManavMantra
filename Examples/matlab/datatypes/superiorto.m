%SUPERIORTO Superior class relationship.
%   This function establishes a precedence that determines which object
%   method is called.  
%
%   This function is used only from a constructor that uses the 
%   CLASS function to create an object (the only way to create MATLAB 
%   classes in versions prior to MATLAB Version 7.6).
%
%   SUPERIORTO('CLASS1','CLASS2',...) invoked within a class
%   constructor method establishes that class as having precedence over
%   the classes in the function argument list for purposes of function
%   dispatching.
%
%   For example, suppose that object A is of class 'CLASS_A', object B is 
%   of class 'CLASS_B' and object C is of class 'CLASS_C', and all three
%   classes contain a method named FUN.  Suppose also that constructor
%   method class_c.m contains the statement:
%      SUPERIORTO('CLASS_A');
%
%   This establishes CLASS_C as taking precedence over CLASS_A for function
%   dispatching.  Therefore, either of the following two statements:
%       E = FUN(A,C);
%       E = FUN(C,A);
%   will invoke CLASS_C/FUN.
%
%   If a function is called with two objects with an unspecified
%   relationship, then the two objects are considered to be of equal
%   precedence and the leftmost object's method is called.  So
%   FUN(B,C) calls CLASS_B/FUN, while FUN(C,B) calls CLASS_C/FUN.
%
%   See also INFERIORTO, CLASS.

%   Copyright 1984-2008 The MathWorks, Inc.
%   Built-in function.

