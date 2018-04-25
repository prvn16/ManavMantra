%javaObject  Invoke a Java object constructor letting MATLAB choose the thread.
%   javaObject is used to construct a Java Object. Typically, MATLAB constructs
%   Java objects from the main MATLAB thread. The primary exception is if the 
%   class is an instance of com.mathworks.jmi.ComponentBridge. To construct a
%   subclasses of java.awt.Component, use javaObjectEDT.
%
%   If C is a character vector containing the name of a Java class, then
%
%   javaObject(C,x1,...,xn)
%
%   invokes the Java constructor for class C with  the signature
%   matching the arguments x1,...,xn. The resulting Java object 
%   is returned as a Java object array.
%
%   For example,
%
%   X = javaObject('java.awt.Color', 0.1, 0, 0.7)
%
%   constructs and returns a java.awt.Color object array.
%
%   If a constructor matching the specified class and signature does
%   not exist, an error will occur.
%
%   javaObject will not normally be needed or used; the usual way 
%   to invoke Java constructors is by the MATLAB constructor syntax,
%   such as X = java.awt.Color(0.1, 0, 0.7). javaObject is provided
%   for those instances that the MATLAB constructor syntax cannot be
%   used (such as when class parametric object construction is
%   required).
%
%   See also javaMethod, IMPORT, METHODS, ISJAVA.

%   Copyright 1984-2016 The MathWorks, Inc.

