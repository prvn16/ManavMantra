%META.EVENT    Describe an event of a MATLAB class
%    The META.EVENT class contains descriptive information about 
%    methods of MATLAB classes.  Properties of a META.EVENT instance 
%    correspond to attributes of the class event being described.  
%
%    All META.EVENT properties are read-only.  The META.EVENT
%    instance can be queried to obtain information about the event it 
%    describes.  All information about class events are specified in the 
%    class definition for the class to which the event belongs.
%
%    Obtain a META.EVENT instance from the EventList property of the
%    META.CLASS instance.  EventList is an array of META.EVENT
%    instances, one per class event.
%
%    %Example 1
%    %Display the properties of a META.EVENT instance
%    mc = ?handle;
%    mevents = mc.EventList;
%    properties(mevents);
%    
%    See also META.CLASS, META.PROPERTY, META.METHOD

%   Copyright 2008-2010 The MathWorks, Inc. 
%   Built-in class.