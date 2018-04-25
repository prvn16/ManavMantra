%VALUES Return values of containers.Map object
%
%   V = VALUES(mapObj, keySet) returns a cell array of values V that correspond
%   to the specified keySet in mapObj. The keySet argument is optional.
%   If not specified, it defaults to all keys in the Map.
%
%   Examples:
%   Return all values in Map object mapObj:
%
%       mapObj = containers.Map({'a', 'b', 'c'}, ...
%                   {'Boston', 'New York', 'Natick'});
%       valueSet = values(mapObj)
%       valueSet = 
%           'Boston'    'New York'   'Natick'
%
% 	Return those values in Map object mapObj that correspond to the keys
% 	specified in the input cell array:
%	
%       valueSet = values(mapObj, {'a', 'c'}) 
%       valueSet = 
%           'Boston'   'Natick'
%
%   See Also containers.Map, keys, isKey
%

%   Copyright 2008 The MathWorks, Inc.
%   Built-in function.