function write(location, ta)
%WRITE  Write tall data to an output location.
%   WRITE(LOCATION,TA) calculates the values in the tall array TA and
%   writes them to files in the folder LOCATION. The data is stored in an
%   efficient binary format suitable for reading back using
%   DATASTORE(LOCATION).
%
%   Example:
%      % Create tall array and write it to an output folder
%      tt = tall(rand(5000,1));
%      location = 'hdfs://myHadoopCluster/some/output/folder';
%      write(location, tt);
%
%      % Recreate the tall array from the written files
%      ds = datastore(location);
%      tt1 = tall(ds);
%
%   See also: TALL, DATASTORE.

%   Copyright 2016-2017 The MathWorks, Inc.

% Check that first input is an existing folder
try
    [location, isHdfs] = matlab.bigdata.internal.util.validateLocation(location);
catch e
    % Remove stack trace
    throw(e)
end

executor = getExecutor(hGetValueImpl(ta));
if ~isHdfs && executor.requiresSequenceFileFormat()
    location = matlab.io.datastore.internal.localPathToIRI(location);
    location = location{1};
    isHdfs = true;
end

% No need to check if ta is tall; this write will not be invoked otherwise.

disp(getString(message('MATLAB:bigdata:array:WritingInfo', class(ta), location)));

writeFunction = matlab.bigdata.internal.io.WriteFunction.createWriteToBinaryFunction(location, isHdfs);

% Remove empty chunks and coalesce small chunks.
taAdaptor = ta.Adaptor;
ta = tall(resizechunks(hGetValueImpl(ta)));
ta.Adaptor = taAdaptor;

tEmpty = partitionfun(matlab.bigdata.internal.FunctionHandle(writeFunction), ta);
gather(tEmpty);
end
