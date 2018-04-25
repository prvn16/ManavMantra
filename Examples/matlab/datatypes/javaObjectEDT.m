%javaObjectEDT  Invoke a Java object constructor and subsequent methods on the Event Dispatch Thread (EDT).
%   This function can also tag an already existing object so that any future
%   method invocations on the object are dispatched from the EDT.
%
%   If C is a character vector containing the name of a Java class, then
%
%      javaObjectEDT(C,x1,...,xn)
%
%   invokes the Java constructor for class C with the signature matching the
%   arguments x1,...,xn from the Swing Event Dispatch Thread (EDT). The
%   resulting Java object is returned as a Java object array. All subsequent
%   methods invoked on the returned object will be dispatched from the EDT.
%
%   For example,
%
%      f = javaObjectEDT('javax.swing.JFrame', 'New Title')
%
%   constructs and returns a javax.swing.JFrame object array from the
%   Event Dispatch Thread (EDT).
%
%   If passed an existing Java object array, all subsequent methods invoked
%   on the object will be dispatched from the EDT.
%
%   Static methods on the specified class or Java object are not affected.
%   They always run on the MATLAB thread unless invoked using javaMethodEDT.
%
%   For example,
%
%      % Create a JOption pane on the EDT
%      optPane = javaObjectEDT('javax.swing.JOptionPane');
%      % Call the createDialog method - this is automatically done on the EDT
%      dlg = optPane.createDialog([],'Sample Dialog');
%      % Tell MATLAB to dispatch methods on dlg from the EDT
%      javaObjectEDT(dlg);
%
%   See also javaMethod, javaObject, javaMethodEDT, IMPORT, METHODS, ISJAVA.

%   Copyright 2007-2016 The MathWorks, Inc.
%   Built-in function.
