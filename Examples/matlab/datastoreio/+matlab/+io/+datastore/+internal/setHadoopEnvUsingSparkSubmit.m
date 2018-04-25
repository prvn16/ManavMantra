function result = setHadoopEnvUsingSparkSubmit()
%
% setHadoopEnvironmentUsingSparkSubmit is called to use spark-submit to determine
% and set environment variables HADOOP_HOME, HADOOP_PREFIX and
% HADOOP_CONF_DIR.
%
% It would primarily be called in a hortonworks or cloudera cluster
% which have spark-submit in /usr/bin and the spark-submit machinery
% sets all of the required spark and hadoop environment variables.
%
% result = setHadoopEnvironmentUsingSparkSubmit
%
    function result = createSetEnv( envLine)
        
        envArgs = split(envLine);
        result = sprintf('setenv( ''%s'', ''%s'');', envArgs{1}, envArgs{2});
    end
if ~strcmp(computer(),'GLNXA64')
    result = false;
    return;
end
%
% Determine if spark-submit is on path.
%
[exitCode, output] = system('bash -c "hash spark-submit"');
if exitCode
    result = false;
    return;
end
%
% Launch spark-submit, when on Hortonworks or Cloudera,
% its machinery sets all the interesting environment variables
% which are gathered in the SparkEnvironment class.
%
hadoopenvsparksubmitJar = ['"' , fullfile( toolboxdir('matlab'),'datastoreio','jar','hadoopenvsparksubmit.jar'), '"'];
[exitCode, envLines] = system(['spark-submit --class com.mathworks.hadoopenvsparksubmit.HadoopEnvironment --master local ', hadoopenvsparksubmitJar]);
if exitCode
    result = false;
    return;
end
%
% SparkEnvironment output contains lines where each line
% is an environment variable followed by its value.
% It's only interested in HADOOP_HOME, HADOOP_PREFIX and
% HADOOP_CONF_DIR.
%
lines = splitlines(envLines(1:end-1));
%
% Insure last line is 'ok'.
%
lastLine = lines{end};
if ~strcmp(lastLine,'ok')
    result = false;
    return;
end
%
% Create MATLAB setenv commands and execute them.
%
lines = lines(1:end-1);
setCmds = cellfun( @(x) createSetEnv( x), lines, 'UniformOutput', false);
eval([setCmds{:}]);
result = true;
end
