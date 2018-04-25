function matlabCodeAsCellArray = getmcode(filename)
%GETMCODE  Returns a cell array of the text in a MATLAB code file
%   matlabCodeAsCellArray = getmcode(filename)

% Copyright 1984-2013 The MathWorks, Inc.

fileContentsAsString = matlab.internal.getCode(filename);
if (isempty(fileContentsAsString))
    matlabCodeAsCellArray ={};
else
    matlabCodeAsCellArray = strsplit(fileContentsAsString, {'\r\n','\n', '\r'}, 'CollapseDelimiters', false)';
end
end
