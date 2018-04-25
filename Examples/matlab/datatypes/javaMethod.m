%javaMethod  Invoke a Java method letting MATLAB choose the thread.
%   javaMethod is used to invoke either static or non-static Java
%   methods. Typically, MATLAB invokes methods on Java objects from the main
%   MATLAB thread. The primary exceptions are if the class is an instance of
%   com.mathworks.jmi.ComponentBridge or the object was created with
%   javaObjectEDT. To invoke methods on subclasses of java.awt.Component, use
%   javaObjectEDT.
%
%   If M is a character vector containing the name of a Java method, and C
%   is a character vector containing the name of a Java class, then
%
%   javaMethod(M,C,x1,...,xn)
%
%   invokes the Java method M in the class C with the signature matching the
%   arguments x1,...,xn. For example,
%   
%   javaMethod('isNaN', 'java.lang.Double', x)
%
%   invokes the static Java method isNaN in class java.lang.Double.
%
%   If J is a Java object array, then javaMethod(M,J,x1,...,xn) invokes the
%   non-static Java method M in the class of J with the signature matching
%   the arguments x1,...,xn. For example, if V is a java.util.Vector Java
%   object array, then
%
%   V = java.util.Vector;
%   javaMethod('setSize', V, 10)
%
%   sets the size of the vector. javaMethod is not normally needed or used
%   in this form. The usual way to invoke Java methods on a Java object is
%   by the MATLAB method invocation syntax, such as setSize(V, 10), or the
%   Java invocation syntax, such as V.setSize(10). javaMethod is provided
%   for those instances when the normal method invocation syntax cannot be
%   used (such as when complete control is required).
%
%   See also javaObject, IMPORT, METHODS, ISJAVA.

%   Copyright 1984-2016 The MathWorks, Inc.
