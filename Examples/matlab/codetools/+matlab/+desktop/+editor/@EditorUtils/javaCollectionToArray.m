function cellArray = javaCollectionToArray(javaCollection)
%javaCollectionToArray converts a java.util.Collection implementation into a MATLAB cell array
%
%   This function is unsupported and might change or be removed without
%   notice in a future version.

% These are utility functions to be used by matlab.desktop.editor functions
% and are not meant to be called by users directly.

% array = javaCollectionToArray(javaCollection) returns the contents of a
% java collection in a cell array. Note the resulting objects in each cell
% may be java objects themselves.
%
% If the elements are all the same data type, the result can be converted
% to a regular MATLAB array using the following command:
%
%    newarray = [array{:}];
%
%  Examples:
%       vec = java.util.Vector;
%       vec.add(1)
%       vec.add(2)
%       vec.add(3)
%       javaCollectionToArray(vec)
%
%       ans =
%        [1]    [2]    [3]
%

%  Copyright 2009-2010 The MathWorks, Inc.

assert(~isempty(javaCollection) && isa(javaCollection,'java.util.Collection'), ...
    message('MATLAB:Editor:Document:JavaCollectionBadInput'));

cellArray = cell(1, javaCollection.size);
for i=0:javaCollection.size - 1
    cellArray{i+1} = javaCollection.get(i);
end
