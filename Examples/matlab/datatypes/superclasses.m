%SUPERCLASSES Display superclass names.
%   SUPERCLASSES CLASSNAME displays the names of all visible superclasses 
%   of the MATLAB class with the name CLASSNAME.  Visible classes are those
%   with class attribute Hidden set to false (the default).
%
%   Use the functional form of SUPERCLASSES, such as SUPERCLASSES(S), when 
%   CLASSNAME is a string scalar.
%
%   SUPERCLASSES(OBJECT) displays the names of the visible superclasses for
%   the class of OBJECT, where OBJECT is an instance of a MATLAB class.
%   OBJECT can be either a scalar object or an array of objects.
%
%   S = SUPERCLASSES(...) returns the superclass names in a cell array of 
%   character vectors.
%
%   %Example:
%   %Retrieve the names of the visible superclasses of class 
%   %AbstractFileDialog and store the result in a cell array of character
%   vectors.
%   classnames = superclasses('AbstractFileDialog');
%
%   See also PROPERTIES, METHODS, EVENTS, CLASSDEF.

%   Copyright 2007-2017 The MathWorks, Inc.
%   Built-in function.