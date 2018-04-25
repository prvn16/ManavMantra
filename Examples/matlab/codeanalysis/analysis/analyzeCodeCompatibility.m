function [analysis] = analyzeCodeCompatibility(varargin)
%analyzeCodeCompatibility Creates code compatibility analysis results.
%
%   RESULTS = analyzeCodeCompatibility creates code compatibility analysis
%   results for current working folder and subfolders, and returns the
%   result as a CodeCompatibilityAnalysis object.
%
%   RESULTS = analyzeCodeCompatibility(names), analyzes the files or folders
%   specified by names, where names is a string scalar, character vector,
%   string array, or cell array of character vectors. The filename must be
%   a valid MATLAB code or App file (*.m, *.mlx, or *.mlapp).
%
%   RESULTS = analyzeCodeCompatibility(..., 'IncludeSubfolders', false)
%   excludes subfolders from the code compatibility analysis. Use this
%   syntax with any of the arguments in previous syntaxes.
%
%   Example:
%
%   result = analyzeCodeCompatibility
%   result =
%     CodeCompatibilityAnalysis with properties:
%
%                  Date: 24-Jan-2017 11:43:13
%         MATLABVersion: "R2017b"
%                 Files: [3x1 string]
%       ChecksPerformed: [291x6 table]
%       Recommendations: [16x7 table]
%
%   See also CodeCompatibilityAnalysis, codeCompatibilityReport

%   Copyright 2017 The MathWorks, Inc.

% Setup input argument constraints and input parser
% When we have an even number of input arguments, input inputParser can't
% identify whether the first input argument is a file list or the start of
% a name/value pair.
% Since there is only one optional input argument, we only get an even
% number of arguments if the file list is not provided. We can therefore
% safely prepend the default value of file list to the input argument list.
    defaultFileList = pwd;
    defaultIncludeSubfolders = true;
    if mod(nargin, 2) == 0
        input = [defaultFileList, varargin];
    else
        input = varargin;
    end
    validateFileList =  @(x) ischar(x) || iscellstr(x) || isstring(x);
    validateIncludeSubfolders = @(x) validateattributes(x,{'logical','numeric'},{'real','nonnan'});

    inputArguments = inputParser;
    inputArguments.addRequired('FileList', validateFileList);
    inputArguments.addParameter('IncludeSubfolders', defaultIncludeSubfolders, validateIncludeSubfolders);
    parse(inputArguments, input{:} );

    fileList = inputArguments.Results.FileList;

    % Non-zero numeric values are treated as true.
    includeSubfolders = logical(inputArguments.Results.IncludeSubfolders);

    rerunConfiguration.includeSubfolders = includeSubfolders;

    % Resolve input arguments and extract filelist.
    [resolvedNameList, fileList] = resolveAndGetFileList(fileList, includeSubfolders);

    rerunConfiguration.resolvedNameList = string(resolvedNameList);

    % The checks are returned in a table.
    checks = matlab.internal.codecompatibilityreport.codeAnalyzerChecks;

    checkcodeConfig = configIdentifiers(checks.Identifier);

    if isempty(fileList)
        checkcodeResult = cell(0,1);
        fileList = string.empty(0,1);
    else
        % checkcode returns the results in a cell array of structures and
        % a list of files analyzed.
        [checkcodeResult, fileList] = ...
            checkcode(fileList, '-id', '-severity', '-config=factory', '-notok', '-CFG:0*', checkcodeConfig{:});
    end

    locations = getLocations(fileList, checkcodeResult);



    analysis = CodeCompatibilityAnalysis(string(fileList), checks, locations, rerunConfiguration);

end

function locations = getLocations(files, results)
% Using the result from the Code Analyzer, create a table with the
% locations of issues found.

    issueCount = cellfun(@numel, results); % Issue count per file.

    % Build up row vectors/matrices of all the checkcode results. Each row
    % corresponds to one message.
    %
    % First, expand the file names so that there is one occurrence of the file name
    % for each issue.
    expandedFiles = strings(sum(issueCount), 1);
    % The cumulative sum of the issue counts per file gives us the indices where we
    % should put the file names.
    range = cumsum([1; issueCount(:)]);
    for i = 1:numel(issueCount)
        expandedFiles(range(i):range(i+1)-1) = files(i);
    end

    if ~isempty(expandedFiles)
        % Expand the cell array of struct arrays into a single struct array with all of
        % the issues. This allows us to perform a vectorized conversion of the issues.
        messages = vertcat(results{:});
        id = categorical({messages.id})';
        description = string({messages.message})';
        line = vertcat(messages.line);
        column = vertcat(messages.column);
    else
        % Ensure that even if there are no files or no messages, the columns will have
        % the right size of empty arrays.
        id = categorical.empty(0, 1);
        description = string.empty(0, 1);
        line = zeros(0, 1);
        column = zeros(0, 2);
    end

    locations = table(id, description, expandedFiles, line, column, 'VariableNames', ...
                      {'Identifier', 'Description', 'File', 'LineNumber', 'ColumnRange'});
end

function [fullFileList] = getFileList(items, recurseDirectory, validExtension)
% Input is the user specified list of items.
% An item can be a file or folder.
% From the list of items, return a fully qualified list of files.

% To perform directory recursion, use dir in this form:
% dir('**/*.m')
    if recurseDirectory
        recurseWildcard = [filesep, '**', filesep];
    else
        recurseWildcard = filesep;
    end

    fullFileList = [];
    for i = 1:numel(items)
        % For directory items, expand its contents.
        if isfolder(items{i})
            dirItems = [];
            for ext = 1:numel(validExtension)
                dirOut = dir([items{i}, recurseWildcard, '*', validExtension{ext}]);
                dirItems = [dirItems; dirOut]; %#ok<AGROW>
            end
            dirFileList = fullfile({dirItems.folder}, {dirItems.name});
            for j = 1:numel(dirItems)
                % A directory can be named like a file.
                % An example directory name:  mydirectory.m
                % In that case, we ignore it because files inside of it
                % should have been collected already.
                if ~isfolder(dirFileList{j}) && isValidMatlabFileName(dirFileList{j}, validExtension)
                    fullFileList = [fullFileList, {dirFileList{j}}]; %#ok<AGROW>
                end
            end
        else
            fullFileList = [fullFileList, {items{i}}]; %#ok<AGROW>
        end
    end

end

function dirItems = findFile(filename, validExtension)
% Find the file in the file system.
% If the file does not have extension, attempt to find it with supported
% extension.
% If the file cannot be found, throw an error.
    [~, ~, extension] = fileparts(filename);
    if ~isempty(extension)
        dirItems = dir(filename);
    else
        dirItems = [];
        for ext = 1:numel(validExtension)
            fullname = [filename, validExtension{ext}];
            % We do not want to find folder with extension
            if ~isfolder(fullname)
                dirOut = dir([filename, validExtension{ext}]);
                dirItems = [dirItems; dirOut]; %#ok<AGROW>
            end
        end
    end
    if isempty(dirItems)
        error(message('codeanalysis:ccrAnalysis:FileNotFound', filename));
    end
end

function nameIsValid = isValidMatlabFileName(filename, validExtension)
% If filename is invalid, do not add it to the list.
% Code Analyzer can handle them with either
%   1) a message which is noise to users.
%   2) or throws an exception.

    [~, filePartsName, extension] = fileparts(filename);
    [~, wasNameModified] = matlab.lang.makeValidName(filePartsName);
    nameIsValid = (~wasNameModified) && any(strcmpi(extension, validExtension));
end

function configID = configIdentifiers(checks)
% From a array of check identifiers, create a config list for checkcode.
% This list will be used to turn on messages.
% Example of turning on one message:
%   -CFG:1TREEFIT
% Example of returned data:
%   configID = {'-CFG:1TREEFIT', '-CFG:1tagABC', '-CFG:1tagDEF', ...}
% This will be used when calling checkcode, like:
% checkcode(..., '-CFG:0*', configID{:});

    checks = cellstr(checks);
    configID = cellfun(@(id) ['-CFG:1', id], checks, 'UniformOutput', false);
end

function inputList = resolveInput(items, validExtension)
% Resolve the input list provided to fully qualified names. If a directory
% is provided, resolve the path, but not expand it.

    inputList = [];
    items = string(items);
    for i = 1:numel(items)
        % For directory items, expand its contents.
        if isfolder(items{i})
            dirName = dir(items{i});
            folderName = dirName.folder;
            inputList = [inputList, {folderName}]; %#ok<AGROW>
        else
            % Disallow wildcard in file names
            invalid = '*?';
            nameWithoutWildCard = strtok(items{i},invalid);
            if ~strcmp(nameWithoutWildCard, items{i})
                error(message('codeanalysis:ccrAnalysis:WildCard'));
            end
            % find the file in the file system
            dirItems = findFile(items{i}, validExtension);
            fileList = fullfile({dirItems.folder}, {dirItems.name});
            % If extension is specified by the user, there should be one
            % file in the list.
            % If extension is not specified by the user, there could be
            % multiple files in the list, but all have valid extension.
            % Therefore we only need to check the validness of the first
            % file.
            if isValidMatlabFileName(fileList{1}, validExtension)
                inputList = [inputList, {fileList{:}}]; %#ok<AGROW>
            else
                error(message('codeanalysis:ccrAnalysis:InvalidFile', items{i}));
            end
        end
    end
end

function [resolvedInputList, fileList] = resolveAndGetFileList(fileList, includeSubfolders)


    validExtension = {'.m', '.mlx', '.mlapp'};

    % Get fully-qualified path for input arguments
    resolvedInputList = resolveInput(fileList, validExtension);

    % Get a cell array with the fully expanded file names to analyze.
    fileList = getFileList(resolvedInputList, includeSubfolders, validExtension);

end
