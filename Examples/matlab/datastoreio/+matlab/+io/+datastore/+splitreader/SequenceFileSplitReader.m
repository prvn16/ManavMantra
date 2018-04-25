%SequenceFileSplitReader
% An internal object that allows the KeyValueDatastore to operate while in
% the Hadoop context.

%   Copyright 2014-2016 The MathWorks, Inc.

classdef (Sealed, Hidden) SequenceFileSplitReader < matlab.io.datastore.splitreader.SplitReader

    properties (Hidden)
        Split = []; % Split to read
        % Number of key value pairs to read
        KeyValueLimit;
        % File type in the info struct returned by getNext
        FileType;
        % To obtain only the values.
        ValuesOnly;
    end

    % These properties are transient as they are only available when an
    % instance of this object is initialized. If this object is saved and
    % then loaded, reset must be called before futher reading.
    properties (Access = private, Transient)
        InternalSequenceReader = []; % The internal java object.
        Filename; % The filename currently being read.
        EndPosition = 0; % The end position of the split inside the file in bytes.

        KeyClassName; % The java key class name string
        ValueClassName; % The java value class name string
        IsSequenceFile2; % Is this the new MxArrayWritable2 based sequence file.
        NextKey = []; % The next key to be read.
        NextValue = []; % The next value to be read.
        Info; % Info needed as 2nd output of getNext()
        Position; % Byte position of the data read
        PrevPosition; % Previous byte position used in the error message
        ReadingDone = false; % boolean to indicate if reading is done
    end

    methods
        % Construct a SequenceFileSplitReader that reads from the given split.
        function obj = SequenceFileSplitReader()
            obj.KeyValueLimit = 1;
            obj.FileType = 'seq';
            obj.ValuesOnly = false;
            obj.ReadingDone = false;
        end

        % Return logical scalar indicating availability of data
        function tf = hasNext(obj)
            tf = ~obj.ReadingDone;
        end

        % Return data and info as appropriate for the datastore
        function [data, info] = getNext(obj)
            obj.Info.Offset = obj.Position;
            info = obj.Info;
            if obj.ValuesOnly
                data = createValuesData(obj);
                return;
            end
            size = 0;
            Key = cell(obj.KeyValueLimit, 1);
            if ~iscell(obj.NextKey)
                Key = zeros(obj.KeyValueLimit, 1, 'like', obj.NextKey);
            end
            Value = cell(obj.KeyValueLimit, 1);
            while size < obj.KeyValueLimit && ~obj.ReadingDone
                try
                    Key(size+1) = obj.NextKey;
                catch e
                    invalidKeyError(obj, class(Key), e);
                end
                Value(size+1) = obj.NextValue;
                obj.next();
                size = size + 1;
            end
            data = table(Key(1:size), Value(1:size), 'VariableNames', {'Key', 'Value'});
        end

        % Reset the reader to the beginning of the split.
        function reset(obj)
            close(obj);
            initialize(obj);
        end

        % Ensure no internal state is left open when deleted.
        function delete(obj)
            close(obj);
        end

        % No-Op as this will only be instantiated for data returned by
        % ParallelHadoopMapRedcuer.
        function checkFileType(~)
        end
        
        function frac = progress(obj)
        % Percentage of read completion between 0.0 and 1.0 for the split.
            readSize = obj.Position - obj.Split.Offset;
            frac = min(readSize/obj.Split.Size, 1.0);
        end

        % Used only by TallDatastore for best ReadSize and preview
        % This gets the buffered value in the underlying file container - Sequence-Files
        function v = getBufferedValue(obj)
            v = zeros(0,1); % empty matrix if Split is empty
            if obj.ValuesOnly && ~isempty(obj.Split) 
                v = obj.NextValue;
            end
        end
    end

    methods (Access = private)
        % Create only Values data
        function data = createValuesData(obj)
            size = 0;
            data = cell(obj.KeyValueLimit, 1);
            while size < obj.KeyValueLimit && ~obj.ReadingDone
                data{size+1} = obj.NextValue;
                obj.next();
                size = size + 1;
            end
            data = data(1:size);
        end

        % Retrieve the next key-value pair from the sequence file.
        function next(obj)
            obj.PrevPosition = obj.Position;
            obj.Position = obj.InternalSequenceReader.getPosition();
            if obj.Position > obj.EndPosition
                obj.ReadingDone = true;
                return;
            end
            if ~obj.ValuesOnly
                keyObject = javaObject(obj.KeyClassName);
            else
                keyObject = org.apache.hadoop.io.NullWritable.get();
            end
            valueObject = javaObject(obj.ValueClassName);

            if obj.InternalSequenceReader.next(keyObject, valueObject)
                if obj.ValuesOnly
                    obj.NextValue = mxarraywritabledeserialize(valueObject);
                elseif obj.IsSequenceFile2
                    obj.NextKey = mxarraywritabledeserialize(keyObject);
                    obj.NextValue = {mxarraywritabledeserialize(valueObject)};
                else
                    obj.NextKey = com.mathworks.hadoop.WritableMLArrayRef.fromByteArray(keyObject.getBytes());
                    obj.NextValue = {com.mathworks.hadoop.WritableMLArrayRef.fromByteArray(valueObject.getBytes())};
                end
                if ischar(obj.NextKey)
                    obj.NextKey = {obj.NextKey};
                end
            else
                obj.ReadingDone = true;
            end
        end

        % Initialize the internal state of this object.
        function initialize(obj)
            assert(isempty(obj.InternalSequenceReader));
            obj.ValuesOnly = obj.Split.ValuesOnly;
            % Call the helper method to create obj.InternalSequenceReader.
            createNewISequenceReader(obj);

            obj.Info.FileType = 'seq';
            obj.Info.Filename = obj.Split.Filename;
            obj.Info.FileSize = obj.Split.FileSize;
            obj.EndPosition = obj.Split.Offset + obj.Split.Size;

            if obj.Split.Offset ~= 0
                obj.InternalSequenceReader.sync(obj.Split.Offset);
            end

            obj.ReadingDone = false;
            % Cache the first value if it exists. We do this to ensure
            % hasNext returns accurate information.
            obj.next();
        end

        % Close the internal state of this object.
        function close(obj)
            obj.ReadingDone = true;
            if ~isempty(obj.InternalSequenceReader)
                obj.InternalSequenceReader.close();
                obj.InternalSequenceReader = [];
            end
        end

        function createNewISequenceReader(obj)
            import matlab.io.datastore.internal.SequenceFileReader;
            import matlab.io.datastore.KeyValueDatastore;
            filename = obj.Split.Filename;
            % On reset filename needs to be checked for sequence files.
            % Additionally, hadoopLoader might not be loaded. This check
            % takes care of that.
            if ~SequenceFileReader.isSeqSupported(filename, obj.ValuesOnly)
                error(message('MATLAB:datastoreio:sequencefilesplitreader:invalidFileType',filename));
            end
            try
                obj.InternalSequenceReader = SequenceFileReader.create(filename);
            catch ME
                if strcmp(ME.identifier, 'MATLAB:Java:GenericException') && ...
                        isa(ME.ExceptionObject, 'java.io.FileNotFoundException')
                     error(message('MATLAB:datastoreio:pathlookup:fileNotFound',filename));
                end
                throwAsCaller(ME);
            end
            [obj.KeyClassName, obj.ValueClassName] = SequenceFileReader.getKeyValueClasses(obj.InternalSequenceReader);
            tfArr = SequenceFileReader.isValidSequenceClassNames(obj.KeyClassName, obj.ValueClassName, obj.ValuesOnly);
            obj.IsSequenceFile2 = tfArr(2);
            obj.ValuesOnly = tfArr(3);
        end

        function invalidKeyError(obj, c1, e)
            c2 = class(obj.NextKey);
            if ~strcmp(c1, c2)
                f1 = obj.Split.Filename;
                f2 = obj.Split.Filename;
                if ~isempty(obj.PrevPosition)
                    f1 = [f1 ' (Offset: ' num2str(obj.PrevPosition) ')'];
                end
                if ~isempty(obj.Position)
                    f2 = [f2 ' (Offset: ' num2str(obj.Position) ')'];
                end
                msgid = 'MATLAB:datastoreio:keyvaluedatastore:invalidKeyConversion';
                msg = message(msgid, c1, c2, f1, f2);
                throw(MException(msg));
            end
            throw(e);
        end
    end

    methods (Access = protected)
        function copiedObj = copyElement(obj)
            % Shallow copy
            copiedObj = copyElement@matlab.mixin.Copyable(obj);
            % Deep copy
            createNewISequenceReader(copiedObj);
            if obj.Position ~= 0
                copiedObj.InternalSequenceReader.sync(obj.Position);
            end
        end
    end
end
