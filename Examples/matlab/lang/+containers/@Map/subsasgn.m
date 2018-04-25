%SUBSASGN Subscripted assignment into containers.Map objects.
%   myMap(keySet) = V assigns the value of V into the element of myMap specified 
%   by the keySet. V must be of the same type as other values of the Map.
%
%   Example:
%       myMap = containers.Map({'a', 'b', 'c'}, ...
%                    {'Boston', 'New York', 'Natick'});
%       myMap('dE') = 'Cambridge';
%
%   Map objects do NOT support '.' or '{}' indexing.  They also do not
%   support multiple indexing, i.e. myMap(key1:keyN).
%
%   See Also containers.Map, values, keys, remove, subsref

%   Copyright 2008 The MathWorks, Inc.
%   Built-in function.