function writeField(swathID,fieldName,varargin)
%writeField Write data to swath field.
%   writeField(SWATHID,FIELDNAME,DATA) writes an entire swath data field.
%
%   writeField(SWATHID,FIELDNAME,START,DATA) writes a contiguous
%   hyperslab to a swath field.  START specifies the index of the first
%   element to write.  The number of elements along each dimension is
%   inferred from either the size of DATA or from the swath field itself.
%
%   writeField(SWATHID,FIELDNAME,START,STRIDE,DATA) writes a strided
%   hyperslab to a swath field.  STRIDE specifies the inter-element spacing
%   along each dimension.
%
%   This function corresponds to the SWwritefield function in the HDF-EOS
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   START and STRIDE parameters are reversed with respect to the C library 
%   API.
%
%   Example:  Write data to a geolocation field 'Longitude'.
%       lon = [-50:49];
%       data = repmat(lon(:),1,100);
%       data = single(data);
%       import matlab.io.hdfeos.*
%       srcFile = fullfile(matlabroot,'toolbox','matlab','imagesci','swath.hdf');
%       copyfile(srcFile,'myfile.hdf');
%       fileattrib('myfile.hdf','+w');
%       swfid = sw.open('myfile.hdf','rdwr');
%       swathID = sw.attach(swfid,'Example Swath');
%       sw.writeField(swathID,'Longitude',data);
%       sw.detach(swathID);
%       sw.close(swfid);
%
%    See also sw, sw.readField.

%   Copyright 2010-2013 The MathWorks, Inc.

narginchk(3,5);

% Get the field size.  Remember to reverse it due to majority issue.
dims = matlab.io.hdfeos.sw.fieldInfo(swathID,fieldName);


switch(nargin)
    case 3
        start = zeros(1,numel(dims));
        stride = ones(1,numel(dims));
        data = varargin{1};
    case 4
        start = varargin{1};
        stride = ones(1,numel(dims));
        data = varargin{2};
    case 5
        start = varargin{1};
        stride = varargin{2};
        data = varargin{3};
end

count = size(data);

% Did the user pass a slice where the last hyperslab extents are understood
% to be one?
if numel(count) < numel(dims)
    dimdiff = numel(dims) - numel(count);
    count = [count ones(1,dimdiff)];
end

if (numel(dims) == 1) 
    % We have a 1D data set, so find where count == 1 and remove that
    % element.
    idx = count==1;
    count(idx) = [];
end

% Must reverse the start, count, and stride arguments because of 
% matlab-vs-C indexing.
start = fliplr(start);
count = fliplr(count);
stride = fliplr(stride);

status = hdf('SW','writefield',swathID,fieldName,start,stride,count,data);
hdfeos_sw_error(status,'SWwritefield');
