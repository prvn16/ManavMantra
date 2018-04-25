%NET.createArray creates a single or multi-dimensional.NET 
%array in MATLAB.
%  array = NET.createArray(typeName, [m,n,p,...]) 
%  array = NET.createArray(typeName, m,n,p,...) 
%
% typeName - Either fully qualified .NET array type name (namespace and
% array type name) or NET.GenericClass instance in case of arrays of
% generic type
%
% m,n,p ... - The number of elements in each dimension of the array.
%
%  Example: 
%  strArray = NET.createArray('System.String', 3);
%  class(strArray)
%       System.String[]
%  
%  strArray = NET.createArray('System.String', [2,3]);
%  class(strArray)
%       System.String[,]
%
%  strArray2 = NET.createArray('System.String', 2,3);
%  class(strArray)
%       System.String[,]
%
%  See also: NET.convertArray
 
%  Copyright 2008 The MathWorks, Inc.
%    $  $
