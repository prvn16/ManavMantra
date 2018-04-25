function enableHdfsLogging()

%   Copyright 2017 The MathWorks, Inc.

% Ensure the appropriate libraries are loaded.
matlab.io.datastore.internal.hadoopLoader();

allLevel = java.util.logging.Level.ALL;

handler = java.util.logging.ConsoleHandler;
handler.setLevel(allLevel);

logger = com.mathworks.storage.hdfs.Log.LOGGER;
logger.setLevel(allLevel);
logger.addHandler(handler);