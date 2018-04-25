%meta.DynamicProperty    Describe a dynamic property of a MATLAB object
%    The meta.DynamicProperty class contains descriptive information about 
%    dynamic properties that have been added to an instance of a MATLAB
%    class that is a subclass of dynamicprops.  Properties of a 
%    meta.DynamicProperty instance correspond to attributes of the dynamic
%    property being described.  
%
%    The meta.DynamicProperty metaclass differs from meta.property in 
%    that all meta.property properties are read-only, where-as many
%    properties of meta.DynamicProperty are both readable and writable.
%
%    A dynamic property is added to a class instance using the addprop
%    method of the dynamicprops class.  The addprop method returns a
%    meta.DynamicProperty instance representing the new dynamic property,
%    and can be modified to change attributes of the property or add
%    SetMethod and GetMethod functions.  These functions work just like
%    get and set access functions defined for properties inside of classes.
%    The dynamic property can be removed from the class instance by
%    calling the delete function on the meta.DynamicProperty instance.
  
%   Copyright 2008 The MathWorks, Inc. 
%   Built-in class.