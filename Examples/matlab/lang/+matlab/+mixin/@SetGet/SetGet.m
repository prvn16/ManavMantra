%SETGET   Set and get for MATLAB objects.
%   The matlab.mixin.SetGet class is an abstract class that provides a
%   property set and get interface.  matlab.mixin.SetGet is a subclass of 
%   handle, so any classes derived from matlab.mixin.SetGet are handle 
%   classes.  
%
%   classdef MyClass < matlab.mixin.SetGet makes MyClass a subclass of matlab.mixin.SetGet.
%
%   Classes that are derived from matlab.mixin.SetGet inherit no properties  
%   but do inherit methods that can be overridden as needed.
%
%   matlab.mixin.SetGet methods:
%       SET      - Set MATLAB object property values.
%       GET      - Get MATLAB object properties.
%       SETDISP  - Specialized MATLAB object property display.
%       GETDISP  - Specialized MATLAB object property display.
%
%   See also HANDLE
 
%   Copyright 2007-2014 The MathWorks, Inc.
%   Built-in class.
