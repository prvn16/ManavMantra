%NET.createGeneric creates an instance of specialized .NET generic type.
%  genObj = NET.createGeneric(className, paramTypes, varargin ctorArgs)
%
%  className  - fully qualified string with the generic type name.
%  paramTypes - cell vector (1 to N) with the types for generic class 
%               parameterization.
%               Allowed cell types are: strings with fully qualified 
%               parameter type names and instances of NET.GenericClass 
%               class when parameterization with another parameterized
%               type is needed.
%  ctorArgs   - optional, variable length (0 to N) list of constructor  
%               arguments matching the arguments of the .NET generic 
%               class constructor intended to be invoked.
%          
%  Returns:     handle to the specialized generic class instance.
%
%  Example: Create an instance of System.Collections.Generic.List of
%    System.Double values with initial storage capacity for 10 elements.
%
%  dblLst = NET.createGeneric('System.Collections.Generic.List', ...
%    {'System.Double'}, 10);
%
%  Example: Create an instance of System.Collections.Generic.List of 
%    System.Collections.Generic.KeyValuePair generic associations where 
%    Key is of System.Int32 type and Value is a System.String class with 
%    initial storage capacity for 10 key-value pairs.
%
%  kvpType =
%  NET.GenericClass('System.Collections.Generic.KeyValuePair',...
%    'System.Int32', 'System.String');
%  kvpList = NET.createGeneric('System.Collections.Generic.List',...
%    { kvpType }, 10);
%
%  See also:  NET.GenericClass class

%  Copyright 2008 The MathWorks, Inc. 
