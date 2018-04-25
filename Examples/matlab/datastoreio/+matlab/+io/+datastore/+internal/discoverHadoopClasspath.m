function classpath = discoverHadoopClasspath(hadoopInstallFolder, versionString, majorVersionNumber)
% discoverHadoopClasspath attempts to discover the hadoop classpath given an installation path 
% using the available sources of information.

%   Copyright 2014-2015 The MathWorks, Inc.

    classpath = iDiscoverFromHadoopCommand(hadoopInstallFolder);
    if ~isempty(classpath)
        return;
    end
    
    if nargin >= 2
        classpath = iDiscoverFromHadoopInstall(hadoopInstallFolder, versionString, majorVersionNumber);
        if ~isempty(classpath)
            return;
        end
    end
    
    error(message('MATLAB:datastoreio:hadooploader:indeterminateHadoopClasspath'));

end

% Attempt to discover from the 'hadoop classpath' system call.
function classpath = iDiscoverFromHadoopCommand(hadoopInstallFolder)
    [status, classpathMsg] = matlab.io.datastore.internal.callHadoop(hadoopInstallFolder, 'classpath');
    if status ~= 0
        classpath = [];
        return;
    end

    classpathMsg = regexp(classpathMsg, '[^\n]*', 'match');
    classpath = strsplit(strjoin(classpathMsg, pathsep), pathsep)';
    classpath = iMatchWildcardFiles(classpath);
end

% Attempt to discover by using knowledge of vanilla Hadoop installation folder.
function jarFiles = iDiscoverFromHadoopInstall(hadoopInstallFolder, versionString, majorVersionNumber)

    if majorVersionNumber == 1
        jarFiles = {fullfile(hadoopInstallFolder, sprintf('hadoop-core-%s.jar', versionString))};
    else
        hadoopJarFolder = fullfile(hadoopInstallFolder, 'share', 'hadoop');
        % add hadoop JAR files, support Cloudera V4 and V5.
        % Cloudera appends hadoop JAR file with cloudera version such as hadoop-common-2.3.0-cdh5.0.1.jar
        jarFiles = iMatchJarFiles(fullfile(hadoopJarFolder, 'common'), sprintf('hadoop-common-%s*.jar', versionString), ...
            ['^hadoop-common-',versionString,'(-\w+(\.\d)+)?\.jar$']);
        jarFiles = [jarFiles; ...
            iMatchJarFiles(fullfile(hadoopJarFolder, 'hdfs'), sprintf('hadoop-hdfs-%s*.jar', versionString), ...
            ['^hadoop-hdfs-',versionString,'(-\w+(\.\d)+)?\.jar$']); ];
    end

    iThrowIfNonExistant(jarFiles);
    jarFiles = [jarFiles; iParseLibFolders(jarFiles)];
end

% Throw if any of the files that we expect do not exist.
function iThrowIfNonExistant(jars)
    for ii = 1:numel(jars)
        if ~exist(jars{ii}, 'file')
            error(message('MATLAB:datastoreio:hadooploader:jarFileNotFound',jars{ii}));
        end
    end
end

% Parse any lib folders found in the same directory as a target jar file.
% This will return a cell array containing both the input as well as all
% jar files found in corresponding lib folders.
function libJarFiles = iParseLibFolders(jars)

    libJarFiles = cell(size(jars));
    for ii = 1:numel(jars)
        libFolder = fullfile(fileparts(jars{ii}), 'lib');
        if ~exist(libFolder, 'dir')
            continue;
        end

        libJarFiles{ii} = iListJarFiles(libFolder);
    end

    libJarFiles = vertcat(libJarFiles{:});

    % We need to remove any dependency that is already on the static classpath.
    [~, libJarFilenames] = cellfun(@fileparts, libJarFiles, 'UniformOutput', false);

    existingClasspathEntries = javaclasspath('-all');
    [~, existingClasspathFilenames, existingClasspathExts] = cellfun(@fileparts, existingClasspathEntries, 'UniformOutput', false);
    existingClasspathFilenames = existingClasspathFilenames(strcmp(existingClasspathExts, '.jar'));

    [~,indices] = setdiff(libJarFilenames, existingClasspathFilenames);
    libJarFiles = libJarFiles(indices);

end

% List all jar files in a given lib folder.
function libJarFiles = iListJarFiles(libFolder)

    files = dir(fullfile(libFolder, '*.jar'));
    libJarFiles = arrayfun(@(x){fullfile(libFolder, x.name)}, files(:));

end

% Find the matched filename using regular expression from the input folder.
function matchedJarFiles = iMatchJarFiles(libFolder,filespec,matchregstr)
    files = dir(fullfile(libFolder,filespec));

    matchedJarFiles = cell(numel(files), 1);
    for ii = 1:numel(files)
        name = files(ii).name;
        n = regexp(name, matchregstr, 'match');
        if ~isempty(n)
            matchedJarFiles{ii} = {fullfile(libFolder,name)};
        end
    end
    matchedJarFiles = vertcat(matchedJarFiles{:});
end

% Convert any paths of the form *.jar to actual files.
function matchedClasspath = iMatchWildcardFiles(classpath)

    matchedClasspath = cell(size(classpath));
    for ii = 1:numel(classpath)
        classpathEntry = classpath{ii};
        [path, name, ext] = fileparts(classpathEntry);
        if strcmp(name, '*')
            if isempty(ext)
                entries = [dir(fullfile(path, '*.jar')), dir(fullfile(path, '*.JAR'))];
            else
                entries = dir(classpathEntry);
            end
            matchedClasspath{ii} = fullfile(path, unique({entries.name})');
        elseif exist(classpathEntry, 'dir') || (strcmpi(ext, '.jar') && exist(classpathEntry, 'file'))
            matchedClasspath{ii} = {classpathEntry};
        end
    end
    matchedClasspath = vertcat(matchedClasspath{:});
end
