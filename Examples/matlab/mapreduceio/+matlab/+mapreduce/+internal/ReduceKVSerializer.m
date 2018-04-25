classdef (Hidden) ReduceKVSerializer < matlab.mapreduce.internal.AbstractKVSerializer
%REDUCEKVSERIALIZER A serializer to flush reducer keys and values to disk.
%   ReduceKVSerializer Methods:
%   serialize - Serialize given key-value pairs to disk
%
%   See also datastore, mapreduce.

%   Copyright 2014-2015 The MathWorks, Inc.

    properties (Access = private)
        OutputFolder;
        OutputFilePrefix;
        OutputFileSuffix;        
        SerializedFiles;
        NthFile;
        WrittenToMat;
    end

    properties (Constant = true, Access = private)
        DEFAULT_FLUSH_LIMIT = 32 * 1024 * 1024; % 32 MB
        FILE_EXTENSION = '.mat';
        FILEPREFIX_SEPARATOR = '_';
    end

    methods (Access = private)
        function writeToMatfile(rkvsr, Key, Value)
            matlab.mapreduce.internal.checkFolderExistence(rkvsr.OutputFolder);
            import matlab.mapreduce.internal.ReduceKVSerializer;
            import matlab.io.datastore.internal.MatKVReadBuffer;
            newFilename = fullfile(rkvsr.OutputFolder, ...
                [rkvsr.OutputFilePrefix, ...
                ReduceKVSerializer.FILEPREFIX_SEPARATOR, ...
                num2str(rkvsr.NthFile), ...
                ReduceKVSerializer.FILEPREFIX_SEPARATOR, ...
                rkvsr.OutputFileSuffix, ...
                ReduceKVSerializer.FILE_EXTENSION]);
            SchemaVersion = MatKVReadBuffer.MAT_FILE_SCHEMA_VERSION;
            save(newFilename, 'Key', 'Value', 'SchemaVersion');
            rkvsr.SerializedFiles{rkvsr.NthFile} = newFilename;
            rkvsr.NthFile = rkvsr.NthFile + 1;
            if ~rkvsr.WrittenToMat
                rkvsr.WrittenToMat = true;
            end
        end
    end

    methods (Hidden = true)
        function rkvsr = ReduceKVSerializer(prefix, folder, suffix)
            rkvsr.OutputFolder = folder;
            rkvsr.OutputFilePrefix = prefix;
            rkvsr.OutputFileSuffix = suffix;
            rkvsr.NthFile = 1;
            rkvsr.WrittenToMat = false;
        end
        
        function tf = serialize(rkvsr, keys, values, bytesUsed, varargin)
            %serialize(kvsr, keys, values, varargin)
            %   Serialize given key-value pairs to disk appropriate for the
            %   keyvaluestore that owns this Serializer.
            tf = false;
            if bytesUsed > matlab.mapreduce.internal.ReduceKVSerializer.DEFAULT_FLUSH_LIMIT
                if nargin > 4
                    sizeToSerialize = varargin{1};
                    keys = keys(1:sizeToSerialize);
                    values = values(1:sizeToSerialize);
                end
                rkvsr.writeToMatfile(keys, values);
                tf = true;
            end
        end
        function outputds = constructDatastore(rkvsr)
            outFiles = rkvsr.SerializedFiles;
            if ~rkvsr.WrittenToMat
                outFiles = {};
            end
            outputds = datastore(outFiles, 'Type', 'keyvalue');
        end
    end
end % classdef end
