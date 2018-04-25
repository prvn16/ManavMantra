% NET.invokeGenericMethod Invokes generic method.
%   [varargout] = NET.invokeGenericMethod(obj,'methodName', ...
%                                         paramTypes, args ...)
%
%   Arguments:
%   obj        - Instances of class containing the generic method, 
%                or class name or definition for static generic method  
%                invocation. Allowed argument types are: 
%                - Instances of class containing the generic method.
%                - Strings with fully qualified class name, if calling  
%                  static generic methods.
%                - Instances of NET.GenericClass definitions, if calling 
%                  static generic methods of a generic class. 
%
%   methodName - Generic method name to be invoked.
%
%   paramTypes - Cell vector (1 to N) with the types for generic method 
%                parameterization. Allowed cell types are: 
%                - Strings with fully qualified parameter type name.
%                - Instances of NET.GenericClass definitions, if using 
%                  nested parameterization with another parameterized type.
%
%   args       - Optional, variable length (0 to N) list of 
%                method arguments matching the arguments of
%                the .NET generic method intended to be invoked.
%                        
%   Returns:     varargout
%
%   Example: Call a generic method that takes two parameterized types 
%   and returns a parameterized type.
%
%   a = NET.invokeGenericMethod(obj, ...
%                               'myGenericMethod', ... 
%                               {'System.Double', 'System.Double'}, ...
%                               5, 6);
%
%
%   See also:  NET.GenericClass  class 
%              NET.createGeneric function

%   Copyright 2009 The MathWorks, Inc.
%    $Date  $
