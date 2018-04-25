function [versionString, majorVersionNumber] = discoverHadoopVersion(hadoopInstallFolder)
% discoverHadoopVersion attempts to discover the hadoop version given an installation path 
% using the available sources of information.

%   Copyright 2014-2016 The MathWorks, Inc.

mlock;

    % From v2 files
    files = dir(fullfile(hadoopInstallFolder, 'share', 'hadoop', 'common', 'hadoop-common*.jar'));
    if ~isempty(files)
        for ii = 1:numel(files)
            name = files(ii).name;
            versionString = regexp(name, '^hadoop-common-(\d\.\d\.\d)\.jar$', 'tokens', 'once');
            if ~isempty(versionString)
                versionString = versionString{1};
                majorVersionNumber = iExtractMajorVersionNumber(versionString);
                return;
            end
        end
    end

    % From v1 files
    files = dir(fullfile(hadoopInstallFolder, 'hadoop-core*.jar'));
    if ~isempty(files)
        for ii = 1:numel(files)
            name = files(1).name;
            versionString = regexp(name, '^hadoop-core-(\d\.\d\.\d)\.jar$', 'tokens', 'once');
            if ~isempty(versionString)
                versionString = versionString{1};
                majorVersionNumber  = iExtractMajorVersionNumber(versionString);
                return;
            end
        end
    end

    % From 'hadoop version' system call
    [status, versionMsg] = matlab.io.datastore.internal.callHadoop(hadoopInstallFolder, 'version');
    if status == 0
        versionString = regexp(versionMsg, 'Hadoop\s+(\d\.\d\.\d)', 'tokens', 'once');
        if ~isempty(versionString)
            versionString = versionString{1};
            majorVersionNumber  = iExtractMajorVersionNumber(versionString);
            return;
        end
    end

    error(message('MATLAB:datastoreio:hadooploader:indeterminateHadoopVer'));

end

function majorVersionNumber = iExtractMajorVersionNumber(versionString)
majorVersionNumber = str2double(regexp(versionString, '^\d', 'match', 'once'));
if majorVersionNumber == 1
    error(message('MATLAB:datastoreio:hadooploader:hadoopVersion1', versionString));
end
end
