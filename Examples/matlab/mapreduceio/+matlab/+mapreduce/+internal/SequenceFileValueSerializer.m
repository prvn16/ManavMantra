classdef (Sealed, Hidden) SequenceFileValueSerializer < matlab.mapreduce.internal.Serializer
%SequenceFileValueSerializer
% Helper class that writes only value output to a Sequence File.
%

%   Copyright 2016 The MathWorks, Inc.


    properties (Access = private)
        % The internal SequenceFile.Writer Java Object.
        InternalWriter = [];
        % Null Writable Key
        NullWritableKey = [];
    end

    methods
        function obj = SequenceFileValueSerializer(filename)
            % Construct a SequenceFileKeyValueSerializer that outputs to the sequence
            % file of given name.
            import matlab.io.datastore.internal.hadoopLoader;
            import matlab.io.datastore.internal.ContextClassLoaderGuard;
            import matlab.io.datastore.internal.HadoopConfiguration;

            % Load hadoop provider, if not loaded already.
            hadoopLoader;

            mxArrayWritable2 = com.mathworks.hadoop.MxArrayWritable2;
            obj.NullWritableKey = org.apache.hadoop.io.NullWritable.get();

            valueClass = mxArrayWritable2.getClass();
            keyClass = obj.NullWritableKey.getClass();

            guard = ContextClassLoaderGuard(); %#ok<NASGU>

            if matlab.io.datastore.internal.isIRI(filename)
                filename = java.net.URI(filename);
            end
            
            path = org.apache.hadoop.fs.Path(filename);
            fileSystem = HadoopConfiguration.getGlobalFileSystem(path.toUri());

            % Use the compatible api for both 1.x and 2.x
            obj.InternalWriter = org.apache.hadoop.io.SequenceFile.createWriter(fileSystem, fileSystem.getConf(), path, keyClass, valueClass);
        end

        function tf = serialize(obj, values)
            % Add the given values to the Sequence file.
            % The values input must be a cell array.
            writer = obj.InternalWriter;
            writer.sync();
            for ii = 1:numel(values)
                value = mxarraywritableserialize(values{ii});
                writer.append(obj.NullWritableKey, value);
            end
        end

        function delete(obj)
            % Cleanup of internal resources
            if ~isempty(obj.InternalWriter)
                obj.InternalWriter.close();
            end
        end
    end
end
