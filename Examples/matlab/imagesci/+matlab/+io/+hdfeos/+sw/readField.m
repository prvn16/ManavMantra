function data = readField(swathID,fieldName,start,count,stride)
%readField Read data from a swath field.
%   DATA = readField(SWATHID,FIELDNAME) reads an entire swath field.
%
%   DATA = readField(SWATHID,FIELDNAME,START,COUNT) reads a contiguous
%   hyperslab of data from the swath field FIELDNAME.  START specifies the
%   zero-based index of the first element to be read.  COUNT specifies the
%   number of elements along each dimension to read.
%
%   DATA = readField(SWATHID,FIELDNAME,START,COUNT,STRIDE) reads a 
%   strided hyperslab of data from the swath field FIELDNAME.  STRIDE
%   specifies the inter-element spacing along each dimension.
%
%   This function corresponds to the SWreadfield function in the HDF-EOS
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   START, COUNT, and STRIDE parameters are reversed with respect to the C 
%   library API.
%
%   Example: 
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       data = sw.readField(swathID,'Longitude');
%       sw.detach(swathID);
%       sw.close(swfid);
%
%    See also sw, sw.writeField.

%   Copyright 2010-2015 The MathWorks, Inc.

switch ( nargin )
	case 2
		start = [];
		count = [];
		stride = [];
	case 4
		stride = [];
end

% Must reverse the start, count, and stride arguments because of 
% matlab-vs-C indexing.
start = fliplr(start);
count = fliplr(count);
stride = fliplr(stride);

[data,status] = hdf('SW','readfield',swathID,fieldName,start,stride,count);
hdfeos_sw_error(status,'SWreadfield');
