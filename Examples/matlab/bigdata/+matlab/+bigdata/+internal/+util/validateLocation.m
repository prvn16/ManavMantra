function [location, isHdfs] = validateLocation(location)
%VALIDATELOCATION Validate location provided to tall/write method.
%
%   [location, isHdfs] = VALIDATELOCATION(location) returns the char
%   location back and a logical ISHDFS indicating whether the location
%   is a Hadoop location or not.

%   Copyright 2016 The MathWorks, Inc.
    validateattributes(location, {'char', 'string'}, {'nonempty'}, ...
        'tall/write', 'location');
    % in case if location is a string
    location = char(location);
    isAnIri = matlab.io.datastore.internal.isIRI(location);
    isHdfs = isAnIri && ~isempty(regexp(location, '^hdfs', 'once'));
    
    import matlab.io.datastore.internal.localPathToIRI;
    import matlab.io.datastore.internal.localPathFromIRI;
    if ~isAnIri
        % This is to canonicalize any relative paths.
        location = localPathFromIRI(localPathToIRI(location));
        location = location{1};
    end

    % TODO: We need a datastore api just for checking if location is empty or
    %       non-existing folder

    import matlab.io.datastore.internal.pathLookup;
    files = [];
    try
        files = pathLookup(location);
    catch
        % either not found or empty folder
    end

    if ~isempty(files)
        error(message('MATLAB:bigdata:array:InvalidWriteLocation', location));
    end

    % empty folder
    if ~isHdfs
        matlab.mapreduce.internal.validateFolderForWriting(location);
    end
end
