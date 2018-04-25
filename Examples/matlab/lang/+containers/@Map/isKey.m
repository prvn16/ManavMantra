%ISKEY Determine whether containers.Map contains key
%
%   TF = ISKEY(mapObj, KeySet) looks for the specified KeySet in the Map instance
%   mapObj, and returns logical TRUE (1) for those elements that it finds, and
%   logical FALSE (0) for those it does not. KeySet is a scalar key or cell
%   array of keys. If KeySet is nonscalar, then return value TF is a
%   nonscalar logical array that has the same dimensions and size as KeySet.
%
%   Examples: 
%   Check myMap and verify that it contains the key 'a':
%
%       myMap = containers.Map({'a', 'b', 'c'}, {'Boston', 'New York', ...
%           'Natick'}); 
%       hasKey = isKey(myMap, 'a'); 
%       hasKey = 
%    		1
%
%   Check the same Map for two keys: 'a' and 'z'. The value
%   returned in hasKeys is a two-element array that shows that the first
%   key has been found and the second has not:
%
%       hasKeys = isKey(myMap, {'a', 'z'})
%       hasKeys = 
%     		[ 1 0 ]
%
%   See Also containers.Map, values, keys, remove

%   Copyright 2008 The MathWorks, Inc.
%   Built-in function.