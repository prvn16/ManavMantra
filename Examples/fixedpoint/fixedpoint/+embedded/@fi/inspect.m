function inspect(varargin)
%INSPECT Open the inspector and inspect object properties
%
%   INSPECT (h) edits all properties of the given object whose handle is h,
%   using a property-sheet-like interface.
%   INSPECT ([h1, h2]) edits both objects h1 and h2; any number of objects
%   can be edited this way.  If you edit two or more objects of different
%   types, the inspector might not be able to show any properties in common.
%   INSPECT with no argument launches a blank inspector window.
%
%   Note that "INSPECT h" edits the string 'h', not the object whose
%   handle is h.

%   Copyright 1984-2012 The MathWorks, Inc.
%   

error(message('fixed:fi:undefinedFunction','inspect'));
