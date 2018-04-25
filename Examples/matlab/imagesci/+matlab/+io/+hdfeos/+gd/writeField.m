function writeField(gridID,fieldName,varargin)
%writeField Write data to a grid field.
%   writeField(gridID,FIELDNAME,DATA) writes all the data to a grid 
%   field.   The field is identified by FIELDNAME and the grid is
%   identified by gridID.
%
%   gd.writeField(gridID,FIELDNAME,START,DATA) writes a contiguous
%   hyperslab to the grid field.  START specifies the zero-based starting
%   index.
%
%   gd.writeField(gridID,FIELDNAME,START,STRIDE,DATA) writes a
%   strided hyperslab of data to a grid datafield.  STRIDE specifies the
%   inter-element spacing along each dimension.  The number of elements to
%   write along each dimension is inferred from the size of DATA.
%
%   This function corresponds to the GDwritefield function in the HDF-EOS
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   START and STRIDE parameters are reversed with respect to the C library 
%   API.
%   
%   Example:  Write all the data to a grid field.
%       import matlab.io.hdfeos.*
%       srcFile = fullfile(matlabroot,'toolbox','matlab','imagesci','grid.hdf');
%       copyfile(srcFile,'myfile.hdf');
%       fileattrib('myfile.hdf','+w');
%       gfid = gd.open('myfile.hdf','rdwr');
%       gridID = gd.attach(gfid,'PolarGrid');
%       data = zeros(100,100,'uint16');
%       gd.writeField(gridID,'ice_temp',data);
%       gd.detach(gridID);
%       gd.close(gfid);
%
%    See also gd, gd.readField.

%   Copyright 2010-2013 The MathWorks, Inc.

narginchk(3,5);

% Get the field size.  Remember to reverse it due to majority issue.
dims = matlab.io.hdfeos.gd.fieldInfo(gridID,fieldName);
compCode = matlab.io.hdfeos.gd.compInfo(gridID,fieldName);

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

% Did the user pass a slice where the last hyperslab extent is understood
% to be one?
if numel(count) == (numel(dims)-1)
    count = [count 1];
end

% If a 1D data set, make sure that count has just one element.
if numel(dims) == 1
    idx = count==1;
    count(idx) = [];
end

if all(count ~= dims) && ~strcmp(compCode,'none')
    % Must be tiled in order for the write operation to succeed.
    tiledims = matlab.io.hdfeos.gd.tileInfo(gridID,fieldName);
    if isempty(tiledims)
        error(message('MATLAB:imagesci:hdfeos:partialWriteToCompressedField', fieldName));
    end
end

% Flip the indices because of row-col-major-ordering.
start = fliplr(start);
stride = fliplr(stride);
count = fliplr(count);
status = hdf('GD','writefield',gridID,fieldName,start,stride,count,data);
hdfeos_gd_error(status,'GDwritefield');
