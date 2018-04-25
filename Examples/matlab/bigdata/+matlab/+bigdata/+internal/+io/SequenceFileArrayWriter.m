classdef SequenceFileArrayWriter < matlab.bigdata.internal.io.Writer & matlab.mixin.Copyable
%SEQUENCEARRAYWRITER A writer to add tall data to Sequence files on disk.
%   SequenceArrayWriter Methods:
%   add - Add array values to Sequence Files
%
%   See also datastore, tall, mapreduce.

%   Copyright 2016-2017 The MathWorks, Inc.
    properties (SetAccess = immutable)
        Serializer;
    end

    properties (Constant, Access = private)
        OUTPUT_FILE_NAME_FORMAT = 'part-%s-snapshot.seq';
    end

    methods
        function obj = SequenceFileArrayWriter(arrayIdx, numIndices, location)
            import matlab.bigdata.internal.io.SequenceFileArrayWriter;
            arrayIdxStr = matlab.bigdata.internal.util.convertToZeroPaddedString(arrayIdx, numIndices);
            filename = sprintf(SequenceFileArrayWriter.OUTPUT_FILE_NAME_FORMAT, arrayIdxStr);
            if matlab.io.datastore.internal.isIRI(location)
                filename = matlab.io.datastore.internal.iriFullfile(location, filename);
            else
                filename = fullfile(location, filename);
            end
            try
                obj.Serializer = matlab.mapreduce.internal.SequenceFileValueSerializer(filename);
            catch ME
                % If tall data is on hdfs and if the cluster cannot write to this location 
                % directory, then we need to error asking to provide a writable location.
                if ~isempty(regexp(ME.message, 'java.io.FileNotFoundException:.*Permission denied', 'once'))
                    error(message('MATLAB:bigdata:array:UnwritableLocation', location));
                end
                throw(ME);
            end
        end

        function add(obj, value)
            obj.Serializer.serialize({value});
        end

        % In a Hadoop context, commit is dealt with by Hadoop.
        function commit(~)
        end
    end
end
