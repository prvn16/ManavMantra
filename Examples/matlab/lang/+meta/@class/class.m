%META.CLASS    Describe a MATLAB class
%    The META.CLASS class contains descriptive information about MATLAB
%    classes.  Properties of a META.CLASS instance correspond to attributes
%    of the MATLAB class being described.  All META.CLASS properties are
%    read-only.
%    
%    MC = METACLASS(OBJECT) returns a META.CLASS instance for the class  
%    of OBJECT.  OBJECT can be either a scalar object or an array of 
%    objects, but the META.CLASS returned is always a scalar instance 
%    for the class of OBJECT.
%
%    MC = ?CLASSNAME returns a META.CLASS instance for the class with name
%    CLASSNAME.
%
%    %Example 1
%    %Given a class instance, obtain the META.CLASS and display its 
%    %properties. 
%    e = MException('msg:id','text');
%    mc = metaclass(e);
%    properties(mc);
%
%    %Example 2
%    %Obtain the META.CLASS using the class name.
%    mc = ?MException;
%    mc.Name
%    mc.Description
%
%    %Example 3
%    %Use the ContainingPackage property of META.CLASS to obtain the
%    %META.PACKAGE for the package to which the class belongs.
%    mc = ?containers.Map;
%    mc.ContainingPackage
%
%    CLASS methods:
%        fromName - Obtain META.CLASS from class name
%    
%    See also META.PACKAGE, META.PROPERTY, META.METHOD, META.EVENT,
%    METACLASS

%   Copyright 2008-2010 The MathWorks, Inc. 
%   Built-in class.