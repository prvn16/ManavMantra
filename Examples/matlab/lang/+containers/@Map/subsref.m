%SUBSREF Subscripted reference into containers.Map objects.
%   myMap(keySet) return a value stored in myMap that is associated
%   with the scalar keySet.
%
%   Supported syntax for map objects:
%
%       myMap = containers.Map({'a', 'b', 'c'}, ...
%                           {'Boston', 'New York', 'Natick'});
%       d1 = myMap('a');
%
%   Map objects do NOT support '.' or '{}' indexing.  They also do not
%   support multiple indexing, i.e. myMap(key1:keyN).
%
%   See Also containers.Map, values, keys, remove, subsasgn

%   Copyright 2008 The MathWorks, Inc.
%   Built-in function.