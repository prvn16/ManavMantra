function fullName = fileResolver(file)
% This function is undocumented.

%  Copyright 2015 The MathWorks, Inc.

validateattributes(file,{'char','string'},{'scalartext','nonempty'},'', 'file');
if isstring(file)
    matlab.unittest.internal.validateNonemptyText(file);
    file = char(file);
end

if ~exist(file, 'file')
    error(message('MATLAB:unittest:FileIO:InvalidFile', file));
end

[status, fileInfo] = fileattrib(file);
if ~status || fileInfo.directory
    error(message('MATLAB:unittest:FileIO:InvalidFile', file));
end

fullName = fileInfo.Name;
end

