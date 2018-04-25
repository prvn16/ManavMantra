function location = getFileNamesFromFileSet(location)
%GETFILENAMESFROMFILESET Get a cellarray of filenames from DsFileSet.
%   FILENAMES = getFileNamesFromFileSet(DSFILESET) returns a cell array of
%   character vectors with fully resolved file names using DSFILESET.
%   DSFILESET is a matlab.io.datastore.DsFileSet object.
%
%   See also matlab.io.datastore.DsFileSet,
%            matlab.io.Datastore.

%   Copyright 2017 The MathWorks, Inc.

if isa(location, 'matlab.io.datastore.DsFileSet')
    location = resolve(location);
    % resolve returns a table of variables FileName and FileSize
    % FileName is a string array
    location = cellstr(location.FileName);
end
end
