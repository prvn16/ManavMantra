function data  = hdfsdsread(hinfo,params)
%HDFSDSREAD read HDF Scientific Data Set
%
%   DATA = HDFSDSREAD(HINFO) returns in the variable DATA all data from the
%   file for the particular data set described by HINFO.  HINFO is A
%   structure extracted from the output structure of HDFINFO.
%   
%   DATA = HDFSDSREAD(HINFO,START,STRIDE,EDGE) reads data from a Scientific
%   Data Set.  START specifies the location in the data set to begin
%   reading. Each number in START must be smaller than its corresponding
%   dimension.  STRIDE is an array specifying the interval between the
%   values to be read.  EDGE is an array specifying the length of each
%   dimension to be read.  The sum of EDGE and START must not exceed the
%   size of the corresponding dimension.  The START, STRIDE and EDGE arrays
%   must be arrays the same size as the number of dimensions.  If START, 
%   STRIDE, or EDGE is empty then the default values are used.  START,
%   STRIDE and EDGE are one based.

%   Copyright 1984-2013 The MathWorks, Inc.


% Make sure that the start, stride, and count parameters are ok.
if isempty(params.Index) 
    % The user did not specify 'Index'.
    start = ones([1 hinfo.Rank]);
    stride = ones([1 hinfo.Rank]);
    edge = [];
else
    [start,stride,edge] = deal(params.Index{:});
end

% Did the user give [] for the start?  Default is the beginning.
if isempty(start)
    start = zeros([1 hinfo.Rank]);
else
    start = start-1;
end

% Did the user give [] for the stride?  If so, default is stride of 1.
if isempty(stride)
    stride = ones([1 hinfo.Rank]);
end




start = fliplr(start);
stride = fliplr(stride);
edge = fliplr(edge);

sdID = matlab.io.hdf4.sd.start(hinfo.Filename);

try

	sdsID = matlab.io.hdf4.sd.select(sdID,hinfo.Index);
    
    [~,dims] = matlab.io.hdf4.sd.getInfo(sdsID);    
    if isempty(edge)
        edge = floor((dims - start + stride - 1) ./ stride);
    end
    
    data = matlab.io.hdf4.sd.readData(sdsID,start,edge,stride);

	%Permute data to be the expected dimensions
	data = permute(data,ndims(data):-1:1);

catch me

	matlab.io.hdf4.sd.endAccess(sdsID);
	matlab.io.hdf4.sd.close(sdID);
	rethrow(me);

end

matlab.io.hdf4.sd.endAccess(sdsID);
matlab.io.hdf4.sd.close(sdID);
