function [dsClsNames, fileBased] = getAvailableDatastores()
%getAvailableDatastores   Find the available datastore classes.
%   This function returns a cell array containing fully qualified names of
%   classes in the matlab.io.datastore package that are not abstract.

%   Copyright 2014-2017 The MathWorks, Inc.

% filter out abstract classes
% we expect all concrete classes in matlab.io.datastore to be datastores
dsClsNames = {'matlab.io.datastore.DatabaseDatastore','matlab.io.datastore.FileDatastore', ...
    'matlab.io.datastore.ImageDatastore','matlab.io.datastore.KeyValueDatastore', ...
    'matlab.io.datastore.SpreadsheetDatastore','matlab.io.datastore.TabularTextDatastore', ...
    'matlab.io.datastore.TallDatastore'};
    fileBased = ones(1,7);
    fileBased(1) = 0;
end
