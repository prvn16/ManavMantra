%NET.GenericClass class represents parameterized generic type definitions.
%   Instances of this class are used by NET.createGeneric function when 
%   creation of generic specialization requires parameterization with 
%    another parameterized type.
%
%   Constructor:  
%       genType = NET.GenericClass (className, varargin paramTypes)
%   Arguments: 
%       className  - fully qualified string with the generic type name.
%       paramTypes - variable length (1 to N) list of types for generic 
%                    class parameterization. Allowed argument types are: 
%                    strings with fully qualified parameter type name and 
%                    instances of NET.GenericClass class when deeper nested
%                    parameterization with another parameterized type is needed.
%
%   Example: Create an instance of System.Collections.Generic.List of 
%            System.Collections.Generic.KeyValuePair generic associations 
%            where Key is of System.Int32 type and Value is a System.String 
%            class with initial storage capacity for 10 key-value pairs.
%
%   kvpType = NET.GenericClass('System.Collections.Generic.KeyValuePair',...
%                              'System.Int32', 'System.String');
%   kvpList = NET.createGeneric('System.Collections.Generic.List',...
%                               {kvpType}, 10);
%
%   See also: NET.createGeneric function.

%   Copyright 2009 The MathWorks, Inc.
%    $Date $
