%Using .NET from within MATLAB
%
%   You can construct .NET objects from within MATLAB by using the
%   name of their class to instantiate them. For example:
%
%    >> obj = System.String('hello')
%
%    obj =
%
%    hello
%
%   For more details, you can use 'help' with these commands or refer to
%   the documentation for details.
%
%   NET.addAssembly            - Makes a .NET assembly visible to MATLAB
%   NET.convertArray           - Converts a MATLAB array to a .NET array
%   NET.createArray            - Creates a single or multi-dimensional.NET
%                                array in MATLAB
%   NET.createGeneric          - Creates an instance of specialized .NET
%                                generic type
%   NET.invokeGenericMethod    - Invokes generic methods
%   NET.GenericClass           - Represents parameterized generic type
%                                definitions
%   NET.NetException           - Represents a .NET exception
%   NET.setStaticProperty      - Sets static property or field
%   NET.disableAutoRelease     - Locks a .NET object representing a RunTime
%                                Callable Wrapper (COM Wrapper)
%   NET.enableAutoRelease      - Unlocks a .NET object representing a RunTime
%                                Callable Wrapper (COM Wrapper) if it was
%                                locked using NET.disableAutoRelease
%   NET.isNETSupported         - Returns true if a supported version of the 
%                                .NET Framework is found, otherwise returns 
%                                false.

%   Copyright 2009 The MathWorks, Inc. 

