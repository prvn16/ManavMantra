%META.METHOD    Describe a method of a MATLAB class
%    The META.METHOD class contains descriptive information about 
%    methods of MATLAB classes.  Properties of a META.METHOD instance 
%    correspond to attributes of the class method being described.  
%
%    All META.METHOD properties are read-only.  The META.METHOD
%    instance can be queried to obtain information about the class
%    method it describes.  All information about class methods are
%    specified in the class definition for the class to which the method 
%    belongs.
%
%    Obtain a META.METHOD instance from the MethodList property of the
%    META.CLASS instance.  MethodList is an array of META.METHOD
%    instances, one per class method.
%
%    
%    %Example 1
%    %Display the properties of a META.METHOD instance
%    e = MException('msg:id','text');
%    mc = metaclass(e);
%    mmethods = mc.MethodList;
%    properties(mmethods);
%
%    %Example 2
%    %Display the name of each method using the META.METHOD instances for
%    %class MException
%    mc = ?MException;
%    mmethods = mc.MethodList;
%    mmethods.Name
%
%    See also META.CLASS, META.PROPERTY, META.EVENT

%   Copyright 2008-2010 The MathWorks, Inc. 
%   Built-in class.