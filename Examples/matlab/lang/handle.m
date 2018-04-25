% HANDLE   Superclass of all handle classes.
%   A handle is an object that indirectly references its data.  When a
%   handle is constructed, an object with storage for property values is
%   created.  The constructor returns a handle to this object.  When a
%   handle object is copied, for example during assignment or when passed
%   to a MATLAB function, the handle is copied but not the underlying
%   object property values.
%
%   The HANDLE class is an abstract class and cannot be directly
%   constructed.  It is the superclass for all classes that follow handle
%   semantics.
%
%   Classes that define events must be handle classes (i.e., they must be
%   derived from HANDLE).  Classes that are derived from the built-in 
%   classes matlab.mixin.SetGet or dynamicprops become handle classes.  
%   When defining a class that inherits from two or more super-classes ,  
%   simultaneously all superclasses must be handle classes or none can be.   
%   A derived class cannot inherit from both handle and value classes 
%   simultaneously.
%
%   Classes that are derived from HANDLE inherit no properties, but do 
%   inherit the following methods which can be overridden as needed.
%
% handle methods:
%   addlistener  - Add listener for event and bind to source
%   delete       - Delete a handle object.
%   eq           - Test handle equality.
%   findobj      - Find objects with specified property values.
%   findprop     - Find property of MATLAB handle object.
%   ge           - Greater than or equal relation.
%   gt           - Greater than relation.
%   isvalid      - Test handle validity.
%   le           - Less than or equal relation for handles.
%   listener     - Add listener for event without binding to source
%   lt           - Less than relation for handles.
%   ne           - Not equal relation for handles.
%   notify       - Notify listeners of event.

%   Copyright 2007-2017 The MathWorks, Inc.
