%SequenceFileHeader
% Helper to get Sequence file header information.

%   Copyright 2014-2016 The MathWorks, Inc.

classdef (Sealed, Hidden) SequenceFileReader < handle
    properties (Access = private, Constant)
        JAVA_SEQUENCE_FILE_READER_NAME = 'org.apache.hadoop.io.SequenceFile$Reader';
        SEQUENCE_FILE_STR = 'Sequence file';
        SEQUENCE_KEY_VALUE_CLASSNAME = 'com.mathworks.hadoop.MxArrayWritable';
        SEQUENCE_KEY_VALUE_CLASSNAME_2 = 'com.mathworks.hadoop.MxArrayWritable2';
        SEQUENCE_KEY_VALUE_CLASSNAME_3 = 'org.apache.hadoop.io.NullWritable';
    end

    methods (Static)
        function [keyClass, valueClass] = getKeyValueClasses(sequenceFileReader)
            import matlab.io.datastore.internal.SequenceFileReader;
            assert(isa(sequenceFileReader, SequenceFileReader.JAVA_SEQUENCE_FILE_READER_NAME))
            keyClass = char(sequenceFileReader.getKeyClassName());
            valueClass = char(sequenceFileReader.getValueClassName());
        end

        function sequenceReader = create(filename)
            import matlab.io.datastore.internal.ContextClassLoaderGuard;
            import matlab.io.datastore.internal.HadoopConfiguration;
            import matlab.io.datastore.internal.SequenceFileReader;
            import matlab.io.datastore.internal.PathTools;
            guard = ContextClassLoaderGuard(); %#ok<NASGU>

            pth = matlab.io.datastore.internal.buildHadoopPath(filename);
            conf = HadoopConfiguration.getGlobalConfiguration();
            fileSystem = HadoopConfiguration.getGlobalFileSystem(pth.toUri());
            sequenceReader = javaObject(SequenceFileReader.JAVA_SEQUENCE_FILE_READER_NAME, fileSystem, pth, conf);
        end

        function tf = isSeqSupported(filename, valuesOnly)
            import matlab.io.datastore.internal.ContextClassLoaderGuard;
            import matlab.io.datastore.internal.SequenceFileReader;
            error(javachk('jvm', SequenceFileReader.SEQUENCE_FILE_STR))
            tf = true;
            import matlab.io.datastore.internal.filesys.createStream;
            ch = createStream(filename,'rb');
            c1 = onCleanup(@() close(ch));
            % read 3 uint8 (bytes) as column vector
            data = read(ch, 3, 'uint8');
            if ~strcmp(char(data'), 'SEQ')
                tf = false;
                return;
            end
            import matlab.io.datastore.internal.hadoopLoader;
            hadoopLoader;
            guard = ContextClassLoaderGuard(); %#ok<NASGU>
            reader = SequenceFileReader.create(filename);
            c2 = onCleanup(@() reader.close());
            [kname, vname] = SequenceFileReader.getKeyValueClasses(reader);
            tfArr = SequenceFileReader.isValidSequenceClassNames(kname, vname, valuesOnly);
            if (valuesOnly && ~tfArr(3)) || sum(tfArr) ~= 1
                tf = false;
            end
        end

        function tfArr = isValidSequenceClassNames(kname, vname, valuesOnly)
            import matlab.io.datastore.internal.SequenceFileReader;
            tfArr = [false, false, false];
            if valuesOnly
                ktf = strcmp(SequenceFileReader.SEQUENCE_KEY_VALUE_CLASSNAME_3, kname);
                vtf = strcmp(SequenceFileReader.SEQUENCE_KEY_VALUE_CLASSNAME_2, vname);
                tfArr(3) = ktf && vtf;
            end
            if all(strcmp(SequenceFileReader.SEQUENCE_KEY_VALUE_CLASSNAME, ...
                    {kname, vname}))
                tfArr(1) = true;
            end
            if all(strcmp(SequenceFileReader.SEQUENCE_KEY_VALUE_CLASSNAME_2, ...
                    {kname, vname}))
                tfArr(2) = true;
            end
        end
    end

    methods (Access = private)
        % Not instantiable
        function obj = SequenceFileReader(); end
    end
end
