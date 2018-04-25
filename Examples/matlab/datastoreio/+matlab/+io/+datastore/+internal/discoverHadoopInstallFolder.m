function [hadoopInstallFolder, envVarSet] = discoverHadoopInstallFolder()
% discoverHadoopInstallFolder Attempt to discover the Hadoop install folder.
%   To find Hadoop, the following environment variables are checked,
%   and the first environment variable found is used:
%      * MATLAB_HADOOP_INSTALL
%      * HADOOP_PREFIX
%      * HADOOP_HOME
%
%   [instFldr, varFound] = discoverHadoopInstallFolder();
%
%   Errors if an install folder could not be found.
%

%   Copyright 2014, The MathWorks, Inc.

    function found = testEnv(envVar)
        envVarSet = envVar;
        hadoopInstallFolder = getenv(envVarSet);
        found = ~isempty(hadoopInstallFolder);
    end

    hadoopInstallFolder = '';
    envVarSet = '';

    % this is a sureshot way to set the Hadoop install folder
    if testEnv('MATLAB_HADOOP_INSTALL'), return; end

    % we first check for v2 users using the preferred environment
    % variable HADOOP_PREFIX
    if testEnv('HADOOP_PREFIX'), return; end

    % v1 users may have HADOOP_HOME
    % we check this second, so that v2 users don't see
    % spurious warnings from Hadoop about the deprecation
    % of this environment variable
    if testEnv('HADOOP_HOME'), return; end

    if strcmp(computer(),'GLNXA64')
        if matlab.io.datastore.internal.setHadoopEnvUsingSparkSubmit()
            if testEnv('HADOOP_PREFIX'), return; end
            if testEnv('HADOOP_HOME'), return; end
        end
    end
    error(message('MATLAB:datastoreio:hadooploader:hadoopNotFound'));
end
