function subds = partition(imds, partitionStrategy, partitionIndex)
%PARTITION Returns a partitioned portion of the ImageDatastore.
%
%   SUBDS = PARTITION(IMDS,NUMPARTITIONS,INDEX) partitions IMDS into
%   NUMPARTITIONS parts and returns the partitioned ImageDatastore, SUBDS,
%   corresponding to INDEX. An estimate for a reasonable value for the
%   NUMPARTITIONS input can be obtained by using the NUMPARTITIONS function.
%
%   SUBDS = PARTITION(IMDS,'Files',INDEX) partitions IMDS by files in the
%   Files property and returns the partition corresponding to INDEX.
%
%   SUBDS = PARTITION(IMDS,'Files',FILENAME) partitions IMDS by files and
%   returns the partition corresponding to FILENAME.
%
%   Example:
%   --------
%      folders = fullfile(matlabroot,'toolbox','matlab',{'demos','imagesci'});
%      exts = {'.jpg','.png','.tif'};
%      imds = imageDatastore(folders,'FileExtensions',exts);
%
%      % For images, numpartitions returns the number of files by default
%      n = numpartitions(imds);
%
%      % subds contains the first file from the ImageDatastore
%      subds = partition(imds,n,1);
%
%      % If not empty, read the file represented by subds
%      while hasdata(subds)
%         img = read(subds);
%      end
%
%   See also imageDatastore, numpartitions.

%   Copyright 2015-2017 The MathWorks, Inc.

if nargin > 1
    partitionStrategy = convertStringsToChars(partitionStrategy);
end

if nargin > 2
    partitionIndex = convertStringsToChars(partitionIndex);
end
try
    if ~ischar(partitionStrategy) || ~strcmpi(partitionStrategy, 'Files')
        if ~isempty(imds.Labels)
            % set indexes on splits which can be used to remove labels
            % after file-based partition
            setHoldPartitionIndices(imds.Splitter.Files, true);
        end
        % This will not copy the internal fileset unnecessarily. partition
        % of the fileset makes a copy anyway.
        setDoNotCopyInternalFileSet(imds.Splitter.Files, true);
        c = onCleanup(@()setDoNotCopyInternalFileSet(imds.Splitter.Files, false));
        subds = partition@matlab.io.datastore.SplittableDatastore(imds, partitionStrategy, partitionIndex);
        setDoNotCopyInternalFileSet(subds.Splitter.Files, false);
        if ~isempty(imds.Labels)
            % Get only the Labels that are partitioned
            idxes = getPartitionIndices(imds.Splitter.Files);
            if ~isempty(idxes)
                % set the labels
                subds.Labels = subds.Labels(idxes);
                % set only the existing labels
                setExistingCategories(subds);
            end
            % Turn off to hold partition indices
            % and clear them
            setHoldPartitionIndices(imds.Splitter.Files, false);
            clearPartitionIndices(imds.Splitter.Files);
        end
    else
        subds = partitionFileStrategy(imds, partitionIndex);
    end

catch e
    throw(e)
end
end

function subds = partitionFileStrategy(imds, index)
    %PARTITIONFILESTRATEGY Return a partitioned part of the datastore using Files.
    %
    %   SUBDS = PARTITION(DS,'Files',INDEX) partitions DS by files in the
    %   Files property and returns the partition corresponding to INDEX.
    %
    %   SUBDS = PARTITION(DS,'Files',FILENAME) partitions DS by files and
    %   returns the partition corresponding to FILENAME.
    %
    %   See also matlab.io.datastore.ImageDatastore, numpartitions.
    try
        % Input checking
        validateattributes(index, {'double', 'char'}, {}, 'partition', 'Index');
        if ischar(index)
            filename = index;
            validateattributes(filename, {'char'}, {'nonempty', 'row'}, 'partition', 'Filename');

            % There's no good way right now to compare a filename to the files
            % held by the fileset object. This will be slow.
            index = find(strcmp(imds.Files, filename));
            if isempty(index)
                error(message('MATLAB:datastoreio:splittabledatastore:invalidPartitionFile', filename));
            end

            if numel(index) > 1
                error(message('MATLAB:datastoreio:splittabledatastore:ambiguousPartitionFile', filename));
            end
        else
            validateattributes(index, {'double'}, {'scalar', 'positive', 'integer'}, 'partition', 'Index');
            if index > imds.NumFiles
                error(message('MATLAB:datastoreio:splittabledatastore:invalidPartitionIndex', index));
            end
        end

        [subds, files] = getCopyWithOriginalFiles(imds);
        % FileIndices of the split always have a 1-1 mapping with the
        % Files contained by the datastore. Set the fileset object of the splitter and
        % reset.
        initWithIndices(subds, index, files);
    catch ME
        throwAsCaller(ME);
    end
end
