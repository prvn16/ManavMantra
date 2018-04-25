%NET.convertArray converts a MATLAB array to a .NET array.
%  arrObj = NET.convertArray(V, 'arrType', [m,n,p,...]) 
%
%  V         - MATLAB array to be converted 
%  arrType   - Optional Namespace qualified .NET array type name string
%  m,n,p ... - Optional number of elements in each dimension of the array
%   
%  Examples:
%  a =[1 2 3 4];
%  arr =NET.convertArray(a, 'System.Double', 4);
%  class(arr)
%    System.Double[]
% 
%  arr2 = NET.convertArray(a, 'System.Double', [4,1]);
%  class(arr2)
%    System.Double[,]
% 
%  a =[1 2 3 4; 5 6 7 8];
%  arr =NET.convertArray(a, 'System.Double', 2,4);
%  class(arr)
%    System.Double[,]
% 
% 
%  a =[1 2 3 4];
%  arr =NET.convertArray(a, 'System.Int32', 4);
%  class(arr)
%    System.Int32[]
%
%  See also: NET.createArray

% Copyright 2008 The MathWorks, Inc.
%  $Date $
