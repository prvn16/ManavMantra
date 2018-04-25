%javaMethodEDT  Invoke a Java method from the Event Dispatch Thread (EDT).
%   javaMethodEDT is used to invoke either static or non-static Java methods
%   from the Swing Event Dispatch Thread (EDT).
%
%   If M is a character vector containing the name of a Java method, and C
%   is a character vector containing the name of a Java class, then
%
%      javaMethodEDT(M,C,x1,...,xn)
%
%   invokes the Java method M in the class C with the signature matching
%   the arguments x1,...,xn from the Event Dispatch Thread (EDT).
%
%   For example, 
%   
%      javaMethodEDT('setDefaultLookAndFeelDecorated', 'javax.swing.JFrame', true)
%
%   invokes the static Java method setDefaultLookAndFeelDecorated in
%   class javax.swing.JFrame from the Event Dispatch Thread (EDT).
%
%   If J is a Java object array, then 
%
%      javaMethodEDT(M,J,x1,...,xn) 
%
%   invokes the non-static Java method M in J with the signature matching
%   the arguments x1,...,xn from the Event Dispatch Thread (EDT).  This form of the
%   function would be needed to invoke a method on the EDT if the object
%   was not previously "tagged" using javaObjectEDT.  For example,
%
%      v = java.util.Vector;
%      javaMethodEDT('add',v,'string');
%
%   creates a Vector v on the MATLAB thread and invokes v.add('string') 
%   from the Event Dispatch Thread (EDT). 
%
%   See also javaMethod, javaObject, javaObjectEDT, IMPORT, METHODS, ISJAVA.

%   Copyright 2007-2016 The MathWorks, Inc.
%   Built-in function.
