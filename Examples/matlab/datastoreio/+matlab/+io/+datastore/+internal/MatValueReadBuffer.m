classdef (Sealed, Hidden) MatValueReadBuffer < handle
%MatValueReadBuffer A value buffer by loading an entire MAT-file.
%
% See also - matlab.io.datastore.TallDatastore

%   Copyright 2016 The MathWorks, Inc.
    properties (SetAccess = private)
        Source;
        Value;
        SchemaVersion;
    end

    properties (Access=public, Hidden, Constant)
        % To identify that MAT-files are created by 16b or later for loading the whole file.
        MAT_FILE_SCHEMA_VERSION = 2.0;
    end

    methods
        function bfr = MatValueReadBuffer(filename)
            % Constructor for the read buffer
            % Loads the MAT-file and checks for the Supported SchemaVersion.
            import matlab.io.datastore.internal.MatValueReadBuffer;
            bfr.Source = filename;
            S = load(filename, 'Value', 'SchemaVersion');
            bfr.Value = S.Value;
            bfr.SchemaVersion = S.SchemaVersion;
            if S.SchemaVersion ~= MatValueReadBuffer.MAT_FILE_SCHEMA_VERSION
                error(message('MATLAB:datastoreio:talldatastore:unsupportedFiles', filename));
            end
        end
    end
end
