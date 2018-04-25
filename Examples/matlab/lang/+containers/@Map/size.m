%SIZE Size of containers.Map object
%   dim = SIZE(mapObj,1) returns a scalar numeric value that indicates the 
%   number of key-value pairs in mapObj. If you call size with a numeric 
%   second input argument other than 1, the size method returns the scalar 
%   numeric value 1.
%
%   dimVector = SIZE(mapObj) returns the two-element row vector [k,1], 
%   where k is the number of key-value pairs in mapObj. 
%
%   [dim1,dim2,...,dimN] = SIZE(mapObj) returns [k,1,...,1].
%
%
%   Example:	
%   Construct a map and find the number of key-value pairs:
% 
%   myKeys = {'a','b','c'};
%   myValues = [1,2,3];
%   mapObj = containers.Map(myKeys,myValues);
%   dim = SIZE(mapObj,1)
%
%   This code returns a scalar numeric value:
%   dim =
%       3
%
%   If you do not specify a second input argument,
%   dimVector = SIZE(mapObj)
%   
%   then the size method returns a vector:
%   dimVector =
%       3     1
%
%   See Also containers.Map, values, isKey, keys, length

%   Copyright 2008 The MathWorks, Inc.
%   Built-in function.