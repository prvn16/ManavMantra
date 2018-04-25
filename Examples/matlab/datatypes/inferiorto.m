%INFERIORTO Specify inferior class relationship.
%   This function establishes a precedence that determines which object
%   method is called.  
%
%   This function is used only from a constructor that uses the 
%   CLASS function to create an object (the only way to create MATLAB 
%   classes in versions prior to MATLAB Version 7.6).
%
%   INFERIORTO('CLASS1','CLASS2',...) invoked within a class
%   constructor method establishes that class as having lower precedence
%   than the classes in the function argument list for purposes of
%   function dispatching (i.e., which method or function is called in
%   any given situation).
%
%   For example, suppose that object A is of class 'CLASS_A', object B is 
%   of class 'CLASS_B' and object C is of class 'CLASS_C', and all three
%   classes contain a method named FUN.  Suppose also that constructor
%   method class_c.m contains the statement:
%      INFERIORTO('CLASS_A');
%
%   This establishes CLASS_A as taking precedence over CLASS_C for function
%   dispatching.  Therefore, either of the following two statements:
%       E = FUN(A,C);
%       E = FUN(C,A);
%   will invoke CLASS_A/FUN.
%
%   If a function is called with two objects with an unspecified
%   relationship, then the two objects are considered to be of equal
%   precedence and the leftmost object's method is called.  So
%   FUN(B,C) calls CLASS_B/FUN, while FUN(C,B) calls CLASS_C/FUN.
%
%   See also SUPERIORTO, CLASS.

%   Copyright 1984-2008 The MathWorks, Inc.
%   Built-in function.

