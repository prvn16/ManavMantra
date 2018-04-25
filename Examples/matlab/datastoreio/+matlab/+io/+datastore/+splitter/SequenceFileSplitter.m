classdef (Sealed, Hidden) SequenceFileSplitter < matlab.io.datastore.splitter.FileSizeBasedSplitter
%SEQUENCEFILESPLITTER Splitter to handle Sequence files.
% Helper class that wraps around FileSizeBasedSplitter to adapt this to the
% interface expected by KeyValueDatastore.

%   Copyright 2015-2016 The MathWorks, Inc.

    properties (Constant, Access = private)
        % KeyValueLimit to be set for readall.
        READALL_KEY_VALUE_LIMIT = 1000;
        % Split size analogous to hdfs block size
        DEFAULT_SEQ_SPLIT_SIZE = 64*1024*1024; % 64 MB
    end

    properties (Access = public)
        % KeyValueLimit for this Splitter
        KeyValueLimit;
    end

    methods (Access = public, Hidden)
        % Required function for KeyValueDatastore/readall. Reads all data
        % from all files.
        function output = readAllSplits(obj)
            import matlab.io.datastore.splitreader.SequenceFileSplitReader;
            import matlab.io.datastore.splitter.SequenceFileSplitter;
            splitReader = SequenceFileSplitReader();
            splitReader.KeyValueLimit = SequenceFileSplitter.READALL_KEY_VALUE_LIMIT;
            splits = obj.Splits;
            valuesOnly = false;
            if ~isempty(splits)
                valuesOnly = splits(1).ValuesOnly;
            end

            output = cell(numel(splits), 1);
            if ~valuesOnly
                % Key classes can be different. Values are always in a cell.
                % Used for throwing useful error messages.
                splitKeyClasses = cell(numel(splits), 1);
            end
            for ii = 1:numel(splits)
                splitReader.Split = splits(ii);
                splitReader.reset;

                splitOutput = {};
                while hasNext(splitReader)
                    splitOutput{end + 1} = getNext(splitReader); %#ok<AGROW>
                end
                output{ii} = vertcat(splitOutput{:});
                if ~valuesOnly && ~isempty(output{ii})
                    splitKeyClasses{ii} = class(output{ii}.Key);
                end
            end
            try
                output = vertcat(output{:});
            catch e
                if ~valuesOnly && strcmp(e.identifier, 'MATLAB:table:vertcat:VertcatCellAndNonCell')
                    SequenceFileSplitter.invalidKeyError(splitKeyClasses, splits);
                end
                throw(e);
            end
            % if empty, we do not want empty double array as output.
            if isempty(output)
                output = table;
            end

            if valuesOnly
                % output.Value is used in the readall of TallDatastore for both
                % MAT-files and Sequence files.
                % valuesOnly is true only for TallDatastore.
                data.Value = output;
                output = data;
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
        function splitter = create(fileInfo)
            import matlab.io.datastore.splitter.SequenceFileSplitter;
            import matlab.io.datastore.splitter.FileSizeBasedSplitter;
            [splits, splitSize] = FileSizeBasedSplitter.createArgs(fileInfo.Files, ...
                                    SequenceFileSplitter.DEFAULT_SEQ_SPLIT_SIZE, fileInfo.FileSizes);
            splitter = SequenceFileSplitter(splits, splitSize);
        end

        % Create Splitter from existing Splits
        function splitter = createFromSplits(splits)
            import matlab.io.datastore.splitter.SequenceFileSplitter;
            import matlab.io.datastore.splitter.FileSizeBasedSplitter;
            [splits, ~] = FileSizeBasedSplitter.createFromSplitsArgs(splits);
            splitter = SequenceFileSplitter(splits, ...
                                SequenceFileSplitter.DEFAULT_SEQ_SPLIT_SIZE);
        end
    end

    methods (Static, Hidden)

        function tfArr = filterSeqFiles(files, valuesOnly)
            import matlab.io.datastore.internal.SequenceFileReader;
            numFiles = numel(files);
            tfArr = true(numFiles, 1);
            for ii = 1:numFiles
                tfArr(ii) = SequenceFileReader.isSeqSupported(files{ii}, valuesOnly);
            end
        end

        function [tf, idx] = areSeqFilesSupported(files, valuesOnly)
            import matlab.io.datastore.internal.SequenceFileReader;
            numFiles = numel(files);
            tf = true;
            idx = -1;
            for ii = 1:numFiles
                if ~SequenceFileReader.isSeqSupported(files{ii}, valuesOnly)
                    idx = ii;
                    tf = false;
                    break;
                end
            end
        end
    end

    methods (Access = private)
        % Private constructor for static build methods
        function splitter = SequenceFileSplitter(splits, splitSize)
            splitter@matlab.io.datastore.splitter.FileSizeBasedSplitter(splits, splitSize);
        end
    end

    methods (Access = 'public')
        % Create reader for the ii-th split
        function rdr = createReader(splitter, ii)
            rdr = matlab.io.datastore.splitreader.SequenceFileSplitReader;
            rdr.Split = splitter.Splits(ii);
            rdr.KeyValueLimit = splitter.KeyValueLimit;
        end

        % Create Splitter from existing Splits
        %
        % Splits passed as input must be of identical in structure to the
        % splits used by this Spltiter class.
        function splitterCopy = createCopyWithSplits(splitter, splits)
            splitterCopy = copy(splitter);
            splitterCopy.Splits = splits;
        end
    end
end
