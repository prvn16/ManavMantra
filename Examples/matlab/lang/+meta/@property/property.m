%META.PROPERTY    Describe a property of a MATLAB class
%    The META.PROPERTY class contains descriptive information about 
%    properties of MATLAB classes.  Properties of a META.PROPERTY instance 
%    correspond to attributes of the class property being described.  
%
%    All META.PROPERTY properties are read-only.  The META.PROPERTY
%    instance can be queried to obtain information about the class
%    property it describes.  All information about class properties are
%    specified in the class definition for the class to which the property 
%    belongs.
%
%    Obtain a META.PROPERTY instance from the PropertyList property of the
%    META.CLASS instance.  PropertyList is an array of META.PROPERTY
%    instances, one per class property.
%    
%    %Example 1
%    e = MException('msg:id','text');
%    mc = metaclass(e);
%    mprop = mc.PropertyList;
%    properties(mprop);
%
%    %Example 2
%    mc = ?MException;
%    mprop = mc.PropertyList;
%    mprop.Name
%    
%    See also META.CLASS, META.METHOD, META.EVENT

%   Copyright 2008-2010 The MathWorks, Inc. 
%   Built-in class.