%REMOVE Remove key-value pairs from containers.Map
%   REMOVE(mapObj, keySet) erases all key-value pairs in Map object mapObj that
%   are specified by the keySet argument. keySet can be a scalar key or a cell
%   array of keys.
%
%   Using REMOVE changes the count of the elements in the Map. 
%
%   Examples:
%   Remove Key-Value Pairs from a Map
%   Create a map and view the keys and the Count property:
%
%   mKeys = {'a','b','c','d'};
%   myValues = [1,2,3,4];
%   mapObj = containers.Map(myKeys,myValues);
%
%   mapKeys = keys(mapObj)
%   mapCount = mapObj.Count
%
%   The initial map contains four key-value pairs:
%   mapKeys = 
%       'a'    'b'    'c'    'd'
%
%   mapCount =
%                       4
%
%   Remove the pairs corresponding to keys b and d:
%   keySet = {'b','d'};
%   remove(mapObj,keySet)
%
%   mapKeys = keys(mapObj)
%   mapCount = mapObj.Count
%
%   The modified map contains two key-value pairs:
%   mapKeys = 
%       'a'    'c'
%
%   mapCount =
%                       2
%
%   See Also containers.Map, values, isKey, keys, size, length

%   Copyright 2011 The MathWorks, Inc.
%   Built-in function.