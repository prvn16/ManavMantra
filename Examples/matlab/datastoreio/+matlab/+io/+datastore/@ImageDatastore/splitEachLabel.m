function varargout = splitEachLabel(imds, varargin)
%SPLITEACHLABEL Split each label with specified proportions of files.
%   [DS1,DS2] = SPLITEACHLABEL(DS,F1) splits the datastore's files from
%   each label according to proportion F1. DS1 contains the files
%   corresponding to F1 and DS2 contains the remaining files.
%   F1 can be:
%      - A fraction such that 0 < F1 < 1
%      - A numerical value denoting the number of files in each label,
%        where F1 >= 1
%
%   [DS1,...,DSm] = SPLITEACHLABEL(DS,F1,...,Fn) splits the datastore's
%   files from each label according to the proportions F1,...,Fn into
%   datastores DS1,...DSm, where m = n + 1.
%   The proportions F1,...,Fn must satisfy either of the following:
%      - The sum of fractions F1,...,Fn must be less than or equal to 1.
%      - The sum of numbers F1,...,Fn must be less than or equal to the
%        minimum of the number of files in each label.
%
%   [DS1,...,DSm] = SPLITEACHLABEL(__,'randomized') uses randperm to draw
%   image files randomly using randperm from each label according to
%   proportions F1,...,Fn resulting in datastores DS1,...DSm, where
%   m = n + 1.
%
%   [DS1,...,DSm] = SPLITEACHLABEL(__,'Include',LABELS) includes image
%   files belonging to LABELS. LABELS and the Labels property must have the
%   same type.
%
%   [DS1,...,DSm] = SPLITEACHLABEL(__,'Exclude',LABELS) excludes image
%   files belonging to LABELS. LABELS and the Labels property must have the
%   same type.
%
%   Note: The 'Include' and 'Exclude' parameters cannot be combined.
%
%   Example: Split using percentages
%   --------------------------------
%      folders = fullfile(matlabroot,'toolbox','matlab',{'demos','imagesci'});
%      exts = {'.jpg','.png','.tif'};
%      imds = imageDatastore(folders,'LabelSource','foldernames','FileExtensions',exts)
%
%      % Split 60% of the files from each label into ds60 and the rest into dsRest
%      [ds60,dsRest] = splitEachLabel(imds,0.6)
%
%      % split 70% of the files from each label into ds70, 20% into ds20 and the rest into dsRest
%      [ds70,ds20,dsRest] = splitEachLabel(imds,0.7,0.2)
%
%   Example: Split using number of files
%   ------------------------------------
%      folders = fullfile(matlabroot,'toolbox','matlab',{'demos','imagesci'});
%      exts = {'.jpg','.png','.tif'};
%      imds = imageDatastore(folders,'LabelSource','foldernames','FileExtensions',exts)
%
%      % Use countEachLabel to find the number of files in each label
%      tbl = countEachLabel(imds);
%
%      % Split using the minimum from the number of files in each label
%      [dsMin,dsRest] = splitEachLabel(imds,min(tbl.Count))
%
%   Example: Split by drawing random images
%   ---------------------------------------
%      folders = fullfile(matlabroot,'toolbox','matlab',{'demos','imagesci'});
%      exts = {'.jpg','.png','.tif'};
%      imds = imageDatastore(folders,'LabelSource','foldernames','FileExtensions',exts)
%
%      % Draw 70% of files from each label randomly into randDs70 with the rest in randDsRest
%      [randDs70,randDsRest] = splitEachLabel(imds,0.7,'randomized')
%
%   Example: Include or Exclude specific labels
%   -------------------------------------------
%      folders = fullfile(matlabroot,'toolbox','matlab',{'demos','imagesci'});
%      exts = {'.jpg','.png','.tif'};
%      imds = imageDatastore(folders,'LabelSource','foldernames','FileExtensions',exts)
%
%      % Split by drawing 70% of the images randomly from only files with the demos label
%      [dsDemos,dsDemosRest] = splitEachLabel(imds,0.7,'randomized','Include','demos')
%
%      % Split by drawing 70% of the images randomly but exclude files with the imagesci label
%      [dsDemos,dsDemosRest] = splitEachLabel(imds,0.7,'randomized','Exclude','imagesci')
%
%   See also imageDatastore, countEachLabel, shuffle, hasdata, readimage,
%   readall, preview, reset.

%   Copyright 2015-2017 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

try
    if isempty(imds.Labels)
        error(message('MATLAB:datastoreio:imagedatastore:splitWhenLabelsEmpty'));
    end
    numargin = nargin - 1;
    [idx, nonNum] = getNumericIndex(numargin, varargin);
    options = '';
    if nonNum
        options = validatestring(varargin{idx}, {'randomized', 'Include', 'Exclude'}, 'datastoreio:imagedatastore:splitEachLabel');
        nums = [varargin{1:idx-1}];
    else
        nums = [varargin{1:idx}];
    end
    numargout = nargout;
    if numargout == 0
        numargout = 1;
    end

    numsGiven = numel(nums);
    if numargout > numsGiven + 1
        error(message('MATLAB:datastoreio:imagedatastore:numOutMoreThanNumProps', numsGiven + 1));
    end

    if any(nums <= 0)
        error(message('MATLAB:datastoreio:imagedatastore:nonPositiveProportions'));
    end

    randomized = false;
    if strcmpi(options, 'randomized')
        idx = idx + 1;
        randomized = true;
    elseif numargin > idx + 1
        try
            options = validatestring(varargin{idx+2}, {'Include', 'Exclude'});
        catch exc
            error(message('MATLAB:datastoreio:imagedatastore:optionsAfterIncExc'));
        end
    end
    includeAll = true;
    includeNonDefault = false;
    if idx < numargin
        inpP = inputParser;
        addParameter(inpP, 'Include', {});
        addParameter(inpP, 'Exclude', {});
        inpP.FunctionName = 'splitEachLabel';
        parse(inpP, varargin{idx:end});
        if isempty(inpP.UsingDefaults)
            error(message('MATLAB:datastoreio:imagedatastore:combineIncExcNVPair'));
        end
        res = inpP.Results;
        if ~ismember('Exclude', inpP.UsingDefaults)
            includeAll = false;
            include = res.Exclude;
            if ischar(include)
                include = {include};
            end
            errorBasedOnType(imds.Labels, include);
            include = setdiff(imds.Labels, include);
            if iscategorical(res.Exclude) && any(isundefined(res.Exclude))
                include = include(~isundefined(include));
            end
        elseif ~ismember('Include', inpP.UsingDefaults)
            includeAll = false;
            includeNonDefault = true;
            include = res.Include;
            if ischar(include)
                include = {include};
            end
            errorBasedOnType(imds.Labels, include);
        end
        if numel(include) == imds.NumFiles && isempty(setdiff(imds.Labels, include))
            includeAll = true;
        end
    end

    if ~includeAll
        idxes = compareLabels(imds.Labels, include, imds.NumFiles, includeNonDefault);
        idxes = find(idxes);
        copiedDs = getNewDs(imds, idxes);
    else
        % Copy the existing datastore
        copiedDs = copy(imds);
    end


    if copiedDs.NumFiles == 0
        varargout = arrayfun(@(x)copy(copiedDs), 1:numargout, 'UniformOutput', false);
        return;
    end

    [uniq, count, groups, nans] = groupAndCountLabels(copiedDs);
    numLabels = numel(uniq);
    fileCount = getFileCount(numargout, nums, count, numLabels);
    res = getLabelIndexes(groups, numLabels, nans, randomized);
    varargout = cell(1, numargout);
    for ii = 2:numargout+1
        indexes = double.empty(1,0);
        % If the number of files from each label is zero, then
        % output an empty datastore. For example, if each label
        % contains less than 5 files and splitEachLabel is as below:
        %     [ds1, ds2, ds3] = splitEachLabel(ds, 0.1, 0.1);
        % ds1 and ds2 will be empty; ds3 will contain all the files.
        if nnz(fileCount(:,ii) - fileCount(:, ii-1)) == 0
            varargout{ii-1} = imageDatastore({});
            continue;
        end
        for j = 1:numLabels
            startIdx = fileCount(j, ii-1) + 1;
            endIdx = fileCount(j, ii);
            r = res{j};
            idxes = r(startIdx:endIdx);
            if isempty(idxes)
                % vertcat(double.empty(n,0), m) throws a warning now
                % and will error eventually.
                continue;
            end
            indexes = vertcat(indexes, idxes); %#ok<AGROW>
        end
        % Maintain indexes of original datastore
        indexes = sort(indexes);
        varargout{ii-1} = getNewDs(copiedDs, indexes);
    end
catch e
    throw(e)
end
end

function fileCount = getFileCount(numargout, nums, count, numLabels)
    lessThanOne = nums < 1;
    if all(lessThanOne)
        numsum = sum(nums);
        if numsum > 1
            error(message('MATLAB:datastoreio:imagedatastore:sumFracMoreThanOne'));
        end
        if numargout <= numel(nums)
            nums = nums(1:numargout);
        end
        fileCount = round(cumsum(count * nums, 2));
    elseif all(~lessThanOne)
        if ~isequal(round(nums), nums)
            error(message('MATLAB:datastoreio:imagedatastore:fracMoreThanOne'));
        end
        numsum = sum(nums);
        if numsum > min(count)
            error(message('MATLAB:datastoreio:imagedatastore:sumPropMoreThanLabels', numsum, min(count)));
        end
        if numargout <= numel(nums)
            nums = nums(1:numargout);
        end
        fileCount = repmat(nums, numLabels, 1);
        fileCount = cumsum(fileCount, 2);
    else
        error(message('MATLAB:datastoreio:imagedatastore:neitherFracNorNum'));
    end
    fileCount = [zeros(size(count)), fileCount, count];
end

function [idx, nonNumFound] = getNumericIndex(numargs, varargs)
    oneNumeric = false;
    nonNumFound = false;
    if numargs < 1
        error(message('MATLAB:datastoreio:imagedatastore:emptyArguments'));
    end
    for idx = 1:numargs
        v = varargs{idx};
        if ~isnumeric(v)
            nonNumFound = true;
            break;
        end
        if ~isscalar(v)
            error(message('MATLAB:datastoreio:imagedatastore:nonScalarNumericalInput'));
        end
        oneNumeric = true;
    end
    if ~oneNumeric
        error(message('MATLAB:datastoreio:imagedatastore:noNumericalInput'));
    end
end

function ds = getNewDs(ds, idxes)
    if isempty(idxes)
        ds = imageDatastore({});
        return;
    end
    % set ReadFcn to the parent datastore and initialize with
    % only specific indexes of files.
    [ds, files] = getCopyWithOriginalFiles(ds);
    initWithIndices(ds, idxes, files);
end

function res = getLabelIndexes(g, numLabels, nans, randomized)
    res = cell(numLabels, 1);
    if ~isempty(nans)
        res{end} = find(nans);
        numLabels = numLabels - 1;
    end
    for i = 1:numLabels
        indexes = find(g==i);
        if randomized
            indexes = indexes(randperm(numel(indexes)));
        end
        res{i} = indexes;
    end
end

function idxes = compareLabels(labels, other, numLabels, includeNonDefault)
    idxes = zeros(numLabels, 1);

    % Take only the unique labels to compare.
    other = unique(other);
    compareFcn = @(x)labels == x;
    switch class(labels)
        case 'cell'
            compareFcn = @(x)strcmp(labels, x{1});

        case 'categorical'
            switch class(other)
                case 'cell'
                    compareFcn = @(x)labels == x{1};
                case 'categorical'
                    % if other says to include undefined categoricals
                    % include them.
                    undef = isundefined(other);
                    if any(undef)
                        other = other(~undef);
                        compares = isundefined(labels);
                        errorIfIncludeNotExists(includeNonDefault, compares, categorical(nan));
                        idxes = or(idxes, compares);
                    end
            end
    end
    for ii = 1:numel(other)
        element = other(ii);
        compares = compareFcn(element);
        errorIfIncludeNotExists(includeNonDefault, compares, element);
        idxes = or(idxes, compares);
    end
end

function errorIfIncludeNotExists(includeNonDefault, compares, other)
    if ~includeNonDefault || nnz(compares) ~= 0
        return;
    end

    switch class(other)
        case 'cell'
            other = other{1};
        case 'categorical'
            other = char(other);
        otherwise
            other = mat2str(other);
    end

    error(message('MATLAB:datastoreio:imagedatastore:includeNotInLabels', other));
end

function errorBasedOnType(labels, other)
    switch class(labels)
        case 'cell'
            if iscellstr(other)
                return;
            end
        case 'categorical'
            switch class(other)
                case 'cell'
                    if iscellstr(other)
                        return;
                    end
                case 'categorical'
                    return;
            end
        case 'logical'
            if islogical(other)
                return;
            end
        otherwise
            if isnumeric(other)
                return;
            end
    end
    error(message('MATLAB:datastoreio:imagedatastore:incExcInvalidType'));
end
