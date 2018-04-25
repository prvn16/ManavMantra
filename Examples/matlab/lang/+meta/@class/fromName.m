%FROMNAME    Obtain META.CLASS for specified class name
%    METACLS = META.CLASS.FROMNAME(CLASSNAME) returns the META.CLASS
%    object associated with the named class.  CLASSNAME can be a string 
%    scalar or character vector.  If CLASSNAME is contained within a 
%    package, you must provide the fully qualified name.
%
%    %Example 1: Obtain the META.CLASS instance for class HANDLE
%    mc = meta.class.fromName('handle');
%
%    %Example 2: Obtain the META.CLASS instance for class META.EVENT using
%    %the fully qualified classname
%    mc = meta.class.fromName('meta.event');
%    
%    See also META.PACKAGE, METACLASS

%   Copyright 2008-2017 The MathWorks, Inc. 
%   Built-in method.