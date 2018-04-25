%matlab.mixin.Copyable Superclass providing copy functionality for handle 
%   objects
%
%   The matlab.mixin.Copyable class is an abstract class that provides a
%   COPY method for copying handle objects. 
%   The COPY method makes a shallow copy of the object (i.e. shallow copies 
%   all non-dependent properties from the source to the destination 
%   object).
%   matlab.mixin.Copyable is a subclass of handle, so any classes derived
%   from matlab.mixin.Copyable are handle classes.  
% 
%   classdef MyClass < matlab.mixin.Copyable makes MyClass a subclass of
%   matlab.mixin.Copyable.
%
%   matlab.mixin.Copyable does not provide any properties.
%
%   matlab.mixin.Copyable methods:
%     copy         - Public, sealed method that copies an input array of
%                    handle objects
%     copyElement  - Protected method that can be overridden by the class
%                    author to provide custom behavior for making a copy of
%                    a scalar object.
%
%   See also HANDLE
 
%   Copyright 2010 The MathWorks, Inc.
%   Built-in class.