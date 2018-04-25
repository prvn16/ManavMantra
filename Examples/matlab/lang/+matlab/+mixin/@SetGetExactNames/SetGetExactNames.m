%SETGETEXACTNAMES   Set and get for MATLAB objects.
%   The matlab.mixin.SetGetExactNames class is an abstract class that provides a
%   property set and get interface.  Classes derived from matlab.mixin.SetGetExactNames 
%   require case-sensitive, exact property name matches. To support inexact name matches, 
%   derive from the matlab.mixin.SetGet class.
%
%   classdef MyClass < matlab.mixin.SetGetExactNames makes MyClass a subclass of matlab.mixin.SetGetExactNames.
%
%   Classes that are derived from matlab.mixin.SetGetExactNames inherit no properties  
%   but do inherit methods that can be overridden as needed.
%
%   matlab.mixin.SetGetExactNames methods:
%       SET      - Set MATLAB object property values.
%       GET      - Get MATLAB object properties.
%       SETDISP  - Specialized MATLAB object property display.
%       GETDISP  - Specialized MATLAB object property display.
%
%   See also matlab.mixin.SetGet
 
%   Copyright 2016 The MathWorks, Inc.
%   Built-in class.
