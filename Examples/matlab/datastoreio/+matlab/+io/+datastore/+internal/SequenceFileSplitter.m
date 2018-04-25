%SequenceFileSplitter
% Helper class that wraps around FileSplitter to adapt this to the
% interface expected by KeyValueDatastore.

%   Copyright 2014-2016 The MathWorks, Inc.

classdef (Sealed, Hidden) SequenceFileSplitter < matlab.io.datastore.internal.FileSplitter    
    
    properties (Constant, Access = private)
        % KeyValueLimit to be set for readall.
        READALL_KEY_VALUE_LIMIT = 1000;
        % Split size analogous to hdfs block size
        DEFAULT_SEQ_SPLIT_SIZE = 64*1024*1024; % 64 MB
    end

    properties (GetAccess = private, SetAccess = immutable)
        InternalFileSplitter; % Internal FileSplitter instance that most functionality is delegated towards.
        IsSplitsOverAllOfFiles;
    end

    methods (Access = public, Hidden)
        % Required function for KeyValueDatastore/readall. Reads all data
        % from all files.
        function output = readAllSplits(obj)
            import matlab.io.datastore.internal.SequenceFileSplitReader;
            import matlab.io.datastore.internal.SequenceFileSplitter;
            splitReader = SequenceFileSplitReader();
            splitReader.KeyValueLimit = SequenceFileSplitter.READALL_KEY_VALUE_LIMIT;
            splits = obj.Splits;

            output = cell(numel(splits), 1);
            % Key classes can be different. Values are always in a cell.
            % Used for throwing useful error messages.
            splitKeyClasses = cell(numel(splits), 1);
            for ii = 1:numel(splits)
                splitReader.Split = splits(ii);
                splitReader.reset;

                splitOutput = {};
                while hasSplitData(splitReader)
                    splitOutput{end + 1} = readSplitData(splitReader); %#ok<AGROW>
                end
                output{ii} = vertcat(splitOutput{:});
                if ~isempty(output{ii})
                    splitKeyClasses{ii} = class(output{ii}.Key);
                end
            end
            try
                output = vertcat(output{:});
            catch e
                if strcmp(e.identifier, 'MATLAB:table:vertcat:VertcatCellAndNonCell')
                    SequenceFileSplitter.invalidKeyError(splitKeyClasses, splits);
                end
                throw(e);
            end
            % if empty, we do not want empty double array as output.
            if isempty(output)
                output = table;
            end
        end

        % set all splits to have the SchemaAvailable field to the
        % given boolean.
        function setSchemaAvailable(splitter, tf)
            [splitter.Splits.SchemaAvailable] = deal(tf);
        end

        % set all splits to have the ValuesOnly field to the
        % given boolean.
        function setSplitsWithValuesOnly(splitter, tf)
            [splitter.Splits.ValuesOnly] = deal(tf);
        end

    end

    methods (Static, Access = private)
        function invalidKeyError(keyClasses, splits)
            if isempty(keyClasses) || numel(keyClasses) < 2
                return;
            end
            c1 = keyClasses{1};
            c2 = '';
            j = [];
            % We just need the first 2 differing key classes
            % Below for loop breaks when we find the first different class.
            % Better than [i, j, k] = unique(keyClasses).
            for ii = 2:numel(keyClasses)
                c2 = keyClasses{ii};
                if ~strcmp(c2, c1)
                    j = ii;
                    break;
                end
            end
            if ~isempty(j)
                msgid = 'MATLAB:datastoreio:keyvaluedatastore:invalidKeyConversion';
                msg = message(msgid, c1, c2, splits(1).Filename, splits(j).Filename);
                throw(MException(msg));
            end
        end
    end

    methods (Static = true)
        % Create Splitter from appropriate arguments
        function splitter = create(args)
            import matlab.io.datastore.internal.SequenceFileSplitter;
            import matlab.io.datastore.internal.FileSplitter;
            [files, splits, splitSize] = FileSplitter.createArgs(args, ...
                                    SequenceFileSplitter.DEFAULT_SEQ_SPLIT_SIZE);
            splitter = SequenceFileSplitter(files, splits, splitSize);
        end

        % Create Splitter from existing Splits
        function splitter = createFromSplits(splits)
            import matlab.io.datastore.internal.SequenceFileSplitter;
            import matlab.io.datastore.internal.FileSplitter;
            [files, splits, ~] = FileSplitter.createFromSplitsArgs(splits);
            splitter = SequenceFileSplitter(files, splits, ...
                                SequenceFileSplitter.DEFAULT_SEQ_SPLIT_SIZE);
        end
    end

    methods (Access = private)
        % Private constructor for static build methods
        function splitter = SequenceFileSplitter(files, splits, splitSize)
            splitter@matlab.io.datastore.internal.FileSplitter(files, splits, splitSize);
        end
    end
end
