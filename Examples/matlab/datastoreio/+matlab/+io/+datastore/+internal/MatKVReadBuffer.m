classdef (Sealed, Hidden) MatKVReadBuffer < handle
%MATKVREADBUFFER A key-value buffer for by loading an entire MAT-file.
%
% See also - matlab.io.datastore.KeyValueDatastore

%   Copyright 2014 The MathWorks, Inc.
    properties (SetAccess = private)
        Source;
        Key;
        Value;
        SchemaVersion;
    end

    properties (Access=public, Hidden, Constant)
        % To identify that MAT-files are created by 15a or later for loading the whole file.
        MAT_FILE_SCHEMA_VERSION = 1.0;
    end

    methods
        function bfr = MatKVReadBuffer(filename)
            import matlab.io.datastore.internal.MatKVReadBuffer;
            bfr.Source = filename;
            S = load(filename, 'Key', 'Value', 'SchemaVersion');
            bfr.Key = S.Key;
            bfr.Value = S.Value;
            bfr.SchemaVersion = S.SchemaVersion;
            if S.SchemaVersion ~= MatKVReadBuffer.MAT_FILE_SCHEMA_VERSION
                error(message('MATLAB:datastoreio:keyvaluedatastore:unsupportedFiles', filename));
            end
        end
    end
end
