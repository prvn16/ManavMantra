function [fileName, offset, size] = getHadoopInfoFromSplit(splitInfo)
%GETHADOOPINFOFROMSPLIT Use Hadoop path api to get Hadoop file information.
%   [FILENAME, OFFSET, SIZE] = getHadoopInfoFromSplit(SPLITINFO) returns a
%   file name, offset and size of the split that needs to be read from the
%   file in hdfs.
%   SPLITINFO is a FileSplit object of class
%   org.apache.hadoop.mapreduce.lib.input.FileSplit
%   or org.apache.hadoop.mapred.FileSplit or an interface for
%      - getPath()
%      - getStart()
%      - getLength()
%   The output of this can be passed to the template method initFromFileSplit
%   of HadoopFileBasedSupport mixin or to initializeDatastore of HadoopFileBased
%   as a struct with field names FileName, Offset and Size.
%
%   See also matlab.io.datastore.mixin.HadoopFileBasedSupport,
%            matlab.io.datastore.HadoopFileBased.

%   Copyright 2017 The MathWorks, Inc.

    pth = splitInfo.getPath();
    if isa(pth, 'java.lang.String')
        fileName = char(org.apache.hadoop.fs.Path(pth).toUri());
    else % already a Path
        fileName = char(pth.toUri());
    end
    offset = double(splitInfo.getStart());
    size = double(splitInfo.getLength());
end
