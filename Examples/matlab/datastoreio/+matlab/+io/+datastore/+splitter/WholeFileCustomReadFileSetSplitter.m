classdef WholeFileCustomReadFileSetSplitter < matlab.io.datastore.splitter.FileBasedSplitter
% WHOLEFILECUSTOMREADFILESETSPLITTER Splitter with a custom reader and a matlab.io.datastore.DsFileSet.
%
% See also - matlab.io.datastore.DsFileSet, matlab.io.datastore.ImageDatastore

%   Copyright 2017 The MathWorks, Inc.

    properties (Hidden)
        % Custom read function
        ReadFcn;
    end

    properties (GetAccess = 'public', SetAccess = 'private')
        % The fileset object to be used by any datastore.
        Files;
    end

    methods (Static, Hidden)
        function splitter = create(location)
            %CREATE Create Splitter from a given location.
            % Pass through to create the Splitter with the fileset object.
            import matlab.io.datastore.splitter.WholeFileCustomReadFileSetSplitter;
            splitter = WholeFileCustomReadFileSetSplitter(location);
        end

        function splitter = createFromSplits(~)
            %CREATEFROMSPLITS Create Splitter from existing Splits.
            %
            % Empty stub to satisfy the Splittable architecture.
        end

        function split = createBasicSplit(filepath, offset, size)
            split = struct('FileName', filepath, 'Offset', offset, ...
                'Size', size);
        end
    end

    methods (Access = protected)
        function splitter = WholeFileCustomReadFileSetSplitter(files)
            splitter.Files = files;
            % This just blends into the current architecture.
            % This can go away once move to the new custom datastore api
            % and get rid of the old SplittableDatastore apis.
            splitter.Splits = matlab.io.datastore.internal.NumelOverride;
            updateNumSplits(splitter);
        end

        function cpObj = copyElement(splitter)
            %COPYELEMENT Deep copy the splitter and the fileset object it holds.
            cpObj = copyElement@matlab.mixin.Copyable(splitter);
            cpObj.Files = copy(splitter.Files);
        end

    end

    methods(Access = 'public')
        function newSplitter = partitionBySubset(splitter, N, ii)
            %PARTITIONBYSUBSET   Return a partitioned part of the Splitter.
            %   This function will return a splitter that represents the part
            %   of the data corresponding with the partition and index chosen.

            if ~ischar(N) && ~isa(N, 'double')
                error(message('MATLAB:datastoreio:splittabledatastore:invalidPartitionStrategyType'));
            elseif ischar(N)
                validateattributes(N, {'char'}, {'nonempty', 'row'}, 'partition', 'PartitionStrategy');
                error(message('MATLAB:datastoreio:splittabledatastore:invalidPartitionStrategy', N(:)'));
            end
            validateattributes(N, {'double'}, {'scalar', 'positive', 'integer'}, 'partition', 'NumPartitions');
            validateattributes(ii, {'double'}, {'scalar', 'positive', 'integer'}, 'partition', 'Index');
            if ii > N
                error(message('MATLAB:datastoreio:splittabledatastore:invalidPartitionIndex', ii));
            end

            import matlab.io.datastore.splitter.WholeFileCustomReadFileSetSplitter;
            % call into the partition of the DsFileSet object.
            subFiles = partition(splitter.Files, N, ii);
            newSplitter = WholeFileCustomReadFileSetSplitter(subFiles);
            newSplitter.ReadFcn = splitter.ReadFcn;
        end
    end

    methods (Hidden)

        function setFiles(splitter, files)
            %SETFILES Set the fileset object and update the num splits value
            splitter.Files = files;
            updateNumSplits(splitter);
        end

        function setFilesAndFileSizes(splitter, varargin)
            %SETFILES Sets the provided files and filesizes.
            % This needs to update the num splits as well once the
            % file list changes.
            splitter.Files.setFilesAndFileSizes(varargin{:});
            updateNumSplits(splitter);
        end

        function updateNumSplits(splitter)
            %UPDATENUMSPLITS Update the num splits if something changed.
            % Clients can use this to update the num splits value,
            % if something changed in the files represented.
            splitter.Splits.NumelValue = splitter.Files.NumFiles;
        end

        function filesAsCellStr = getFilesAsCellStr(splitter, indices)
            %GETFILESASCELLSTR Implementation to obtain a column cell array of files
            % that can be obtained from the fileset object of this Splitter.
            if nargin == 1
                indices = 1:splitter.Files.NumFiles;
            end
            filesAsCellStr = getFiles(splitter.Files, indices);
        end

        function fileSizes = getFileSizes(splitter, varargin)
            %GETFILESIZES Get the file sizes from the fileset object of this Splitter.
            %   This is a pass through into the fileset object.
            fileSizes = splitter.Files.getFileSizes(varargin{:});
        end

        function rdr = createReader(splitter, ii)
            %CREATEREADER Return a reader for the ii-th split.
            rdr = matlab.io.datastore.splitreader.WholeFileCustomReadSplitReader;
            rdr.ReadFcn = splitter.ReadFcn;
            % Get the ii-th file name using the fileset object.
            file = splitter.Files.getFiles(ii);
            if ~isempty(file)
                rdr.Split.Filename = file{1};
                rdr.Split.FileSize = splitter.getFileSizes(ii);
            else
                rdr.Split = [];
            end
        end

        function splitterCopy = createCopyWithSplits(splitter, splits)
            %CREATECOPYWITHSPLITS Create Splitter from existing Splits
            % Splits passed as input must be of identical in structure to the
            % splits used by this Splitter class.
            import matlab.io.datastore.splitter.WholeFileCustomReadFileSetSplitter;
            % This is called with splits being a struct with FileName, Offset
            % and Size fields, that a DsFileSet can take.
            files = matlab.io.datastore.DsFileSet(splits);
            splitterCopy = WholeFileCustomReadFileSetSplitter(files);
            splitterCopy.ReadFcn = splitter.ReadFcn;
        end

        function tf = isFullFileSplitter(~)
            % A WholeFileSplitter is always a full file splitter.
            tf = true;
        end

        function tf = isSplitsOverAllOfFiles(~)
            % A WholeFileSplitter always have splits over all files.
            tf = true;
        end

    end
end
