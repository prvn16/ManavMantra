function data = readDatastoreImage(filename)
%READDATASTOREIMAGE Read file formats supported by IMREAD.
%
%   See also matlab.io.datastore.ImageDatastore, datastore,
%            mapreduce.

%   Copyright 2016 The MathWorks, Inc.

% Turn off warning backtrace before calling imread
onState = warning('off', 'backtrace');
c = onCleanup(@() warning(onState));
data = imread(filename);
