classdef MatKVFileSplitReader < matlab.io.datastore.internal.SplitReader
%MATKVFILESPLITREADER SplitReader for reading key value mat file splits.
%    A split reader that reads key value pair data off of an assigned Split
%    struct. The splits are assigned by the SplittableDatastore, when this
%    split reader runs out of data to read. MATKVFILESPLITREADER reads
%    KeyValueLimit number of key value pairs in the mat file specified by
%    the Split struct.
%
% See also - matlab.io.datastore.KeyValueDatastore

%   Copyright 2014 The MathWorks, Inc.

    properties (Hidden)
        % Split to read
        Split;
        % Number of key value pairs to read
        KeyValueLimit;
        % File type in the info struct returned by readSplitData
        FileType;
    end

    properties (Access = private)
        % Maximum Split size determined by the Splitter.
        SplitSizeLimit;
        % Number of files from Splitter.
        NumFiles;
    end

    properties (Access = private, Transient)
        % Index from which to read KeyValueLimit number of key value pairs.
        StartIdx;
        % A cache of mat file objects indexed by FileIndex provided by the Split.
        MatFileObjects;
        % Current KeyValue Object or MatFile Object
        CurrentObject;
        % Info struct fo this Split.
        Info;
        % End index on the file.
        SplitEnd;
    end

    methods
        function rdr = MatKVFileSplitReader(numfiles, keyValueLimit, splitSize)
            rdr.NumFiles = numfiles;
            rdr.MatFileObjects = cell(numfiles, 1);
            rdr.FileType = 'mat';
            rdr.KeyValueLimit = keyValueLimit;
            rdr.SplitSizeLimit = splitSize;
        end
    end

    methods (Access = public, Hidden)

        function frac = progress(rdr)
        % Percentage of read completion between 0.0 and 1.0 for the split.
            splitSize = rdr.SplitEnd - rdr.Split.Offset;
            keyValueLimit = rdr.StartIdx - rdr.Split.Offset;
            frac = min(keyValueLimit/splitSize, 1.0);
        end

        function tf = hasSplitData(rdr)
        % Return logical scalar indicating availability of data
            tf = ~isempty(rdr.Split) && rdr.StartIdx <= rdr.SplitEnd;
        end

        function [data, info] = readSplitData(rdr)
        % Return data and info as appropriate for the datastore
            endidx = rdr.StartIdx + rdr.KeyValueLimit - 1;
            if endidx > rdr.SplitEnd
                endidx = rdr.SplitEnd;
            end
            data = table;
            data.Key = rdr.CurrentObject.Key(rdr.StartIdx:endidx, 1);
            data.Value = rdr.CurrentObject.Value(rdr.StartIdx:endidx, 1);
            rdr.Info.Offset = rdr.StartIdx;
            info = rdr.Info;
            rdr.StartIdx = endidx + 1;
        end

        function reset(rdr)
        % Reset the reader to the beginning of the split
            if isempty(rdr.Split)
                return;
            end
            if exist(rdr.Split.File, 'file') ~= 2
                error(message('MATLAB:datastoreio:pathlookup:fileNotFound',rdr.Split.File));
            end
            setMatKVReadBuffer(rdr);
            % initialize the index from which to read
            rdr.StartIdx = rdr.Split.Offset;
            rdr.SplitEnd = rdr.StartIdx + rdr.SplitSizeLimit - 1;
            if rdr.SplitEnd > rdr.Split.Size
                rdr.SplitEnd = rdr.Split.Size;
            end
            % initialize the info struct to be returned by readSplitData
            rdr.Info = struct('FileType', rdr.FileType, ...
                'Filename', rdr.Split.File, ...
                'FileSize', rdr.Split.Size, ...
                'Offset', rdr.Split.Offset);
        end

        function [key, value] = readFullSplit(rdr, splitSize)
            endidx = rdr.Split.Offset + splitSize - 1;
            key = rdr.CurrentObject.Key(rdr.Split.Offset:endidx, 1);
            value = rdr.CurrentObject.Value(rdr.Split.Offset:endidx, 1);
        end
    end

    methods (Access = private)
        function setMatKVReadBuffer(rdr)
            split = rdr.Split;
            if (split.SchemaAvailable)
                if isempty(rdr.CurrentObject) || ...
                    ~strcmp(rdr.CurrentObject.Source, split.File)
                    rdr.CurrentObject = matlab.io.datastore.internal.MatKVReadBuffer(split.File);
                end
                return;
            end
            if isempty(rdr.MatFileObjects)
                rdr.MatFileObjects = cell(rdr.NumFiles, 1);
            end
            if isempty(rdr.MatFileObjects{split.FileIndex})
                rdr.MatFileObjects{split.FileIndex} = matfile(split.File);
            end
            rdr.CurrentObject = rdr.MatFileObjects{split.FileIndex};
        end
    end
end
