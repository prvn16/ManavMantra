%containers.Map constructs a Map object.
%   myMap = containers.Map() creates an empty object myMap that is an
%   instance of the MATLAB containers.Map class. The properties of myMap
%   are Count (set to 0), KeyType (set to 'char'), and ValueType (set to
%   'any').
%
%   The Map object is a data structure which is a container for other data.
%   It consists of keys and values. A map allows you to retrieve any value 
%   from the Map using its corresponding key. 
%
%   myMap = containers.Map(KEYS, VALUES) constructs a Map object myMap that
%   contains one or more keys and a value for each of these keys, as 
%   specified in the KEYS and VALUES arguments.  A value is some unit of 
%   data that you want stored in the Map object and a key is a unique 
%   reference to that data.  Either the KEYS or the VALUES array may be a 
%   cell array, in which case the actual keys and/or values are extracted 
%   from the cell array.  Valid keys are either numeric real scalars, or 
%   character vectors.  Values can be of any type.  The Map's
%   KeyType and ValueType properties are set based on the key and value 
%   provided.
% 
%   myMap = containers.Map(KEYS, VALUES, 'uniformValues', B) where B is a 
%   logical scalar.  If B is false, this creates a Map object with the 
%   ValueType set to 'any'.  If it is true, all values must be of the same 
%   type.
%
%   myMap = containers.Map('KeyType', kType, 'ValueType', vType) constructs 
%   a Map object with no data that uses a key type of kType, and a value
%   type of vType. Valid values for kType are: 'char','double', 'single', 
%   'int32', 'uint32', 'int64', 'uint64'. Valid values for vType are: 
%   'char', 'double', 'single', 'int8', 'uint8', 'int16', 'uint16', 
%   'int32', 'uint32', 'int64', 'uint64', 'logical', or 'any'. 
%   The order of the key type and value type arguments is not important,
%   but both must be provided.
%
%   Examples:
%
%   To extract a value from a Map:
%       myValue = myMap(key);   
%
%   To modify existing key-value pairs in a Map:
%       myMap(key) = newValue;       %Set existing key to a new value.
%
%   To add new key-value pairs to a Map:
%       myMap(newKey) = newerValue;  
%
%   Values can be deleted from a Map by using the remove method.
%
%   Because a Map is a handle class, calling methods of the object may 
%   modify the object itself.
%
%   Map methods:
%       isKey       -   Determine whether Map contains given key.
%       keys        -   Return cell array of keys of Map.
%       values      -   Return cell array of values of Map.
%       remove      -   Remove key-value pairs from Map.
%       size        -   Return size of Map.
%       length      -   Return length of Map.  This is the number of 
%                       key-value pairs in Map.
%       isempty     -   Determine if Map contains any data.
%
%   Map public fields:
%       KeyType     -   Type of key used by this instance of Map.
%       ValueType   -   Type of value used by this instance of Map.
%       Count       -   Number of key-value pairs in Map.

%   Copyright 2008 The MathWorks, Inc.
%   Built-in function.

%{
properties
% KeyType  -- The type of key used by this instance of a Map.
%   This is a read-only field which is determined based on the keys
%   supplied in the creation of a map.  The value of this property can be 
%   one of: 'char', 'double', 'single', 'int32', 'uint32', 'int64', 'uint64'.  
%   If a different numeric type is used as a
%   key, it will be converted to 'double' automatically.
%
%   See Also containers.Map, ValueType, keys, values, isKey
KeyType;

% ValueType  -- The type of value used by this instance of a Map.
%   This is a read-only field which is determined based on the values
%   supplied in the creation of a Map.  The value of this property can be 
%   one of: 'char', 'double', 'single', 'int8', 'uint8', 'int16', 'uint16', 
%   'int32', 'uint32', 'int64', 'uint64','logical', or 'any'.
%
%   See Also containers.Map, KeyType, keys, values
ValueType;

% Count  -- The number of key-value pairs in this instance of a Map.
%   This is a read-only field.  The return value is of type uint64.
%
%   See Also containers.Map, length, size
Count;
end
%}
