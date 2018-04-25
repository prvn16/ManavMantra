classdef (Hidden) MatValueSerializer < matlab.mapreduce.internal.Serializer
%MATVALUESERIALIZER A serializer to flush reducer keys and values to disk.
%   MatValueSerializer Methods:
%   serialize - Serialize values to disk
%
%   See also datastore, tall, mapreduce.

%   Copyright 2016-2017 The MathWorks, Inc.

    properties (Access = private)
        % Temporary file name to hold on to input
        % prefix and suffix strings
        TempFileName;
    end

    properties (Constant = true, Access = private)
        HEX_PREFIX_STR = '0x';
    end

    methods (Access = private)
        function appendNumValuesToFileName(obj, numValues)
            % Append number of values to be serialized as a
            % hexadecimal value to the output file name.
            import matlab.mapreduce.internal.Serializer;
            import matlab.mapreduce.internal.MatValueSerializer;

            obj.OutputFileName = [obj.TempFileName,...
                Serializer.DEFAULT_FILEPREFIX_SEPARATOR, ...
                MatValueSerializer.HEX_PREFIX_STR, ...
                dec2hex(numValues), ...
                Serializer.DEFAULT_FILE_EXTENSION];
        end
    end
    methods (Hidden = true)
        function obj = MatValueSerializer(prefix, folder, suffix)
            %Constructor for MatValueSerializer
            %  Just store the OutputFolder and OutputFileName format
            %  Later use the OutputFileName to sprintf any integers.
            import matlab.mapreduce.internal.Serializer;
            obj.OutputFolder = folder;
            obj.TempFileName = [prefix, ...
                Serializer.DEFAULT_FILEPREFIX_SEPARATOR, ...
                Serializer.FILE_NUMBER_FILL, ...
                Serializer.DEFAULT_FILEPREFIX_SEPARATOR, ...
                suffix];
        end

        function tf = serialize(obj, varargin)
            %serialize(kvsr, values, bytesUsed, sizeToSerialize)
            %   Serialize given values to disk appropriate for the
            %   MAT-File Writer or Store that owns this Serializer.
            tf = false;
            values = varargin{1};
            bytesUsed = varargin{2};
            if bytesUsed > matlab.mapreduce.internal.Serializer.DEFAULT_FLUSH_LIMIT
                if numel(varargin) > 2
                    sizeToSerialize = varargin{3};
                    values = values(1:sizeToSerialize);
                end
                import matlab.io.datastore.internal.MatValueReadBuffer;
                s.SchemaVersion = MatValueReadBuffer.MAT_FILE_SCHEMA_VERSION;
                s.Value = values;
                obj.appendNumValuesToFileName(numel(values));
                obj.writeToMatfile(s);
                tf = true;
            end
        end

        function outFiles = getFiles(obj)
            %getFiles
            %   Return the serialized MAT-Files.
            outFiles = obj.SerializedFiles;
        end
    end
end % classdef end
