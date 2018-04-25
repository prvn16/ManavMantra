function ncwrite(ncFile, varName, varData, start, stride)
%NCWRITE Write data to NetCDF file.
%
%    NCWRITE(FILENAME, VARNAME, VARDATA) write numerical or char data in
%    VARDATA to an existing variable VARNAME in the NetCDF file FILENAME.
%    VARDATA is written starting at the beginning of the variable and
%    unlimited dimensions are automatically extended if needed.
%
%    If FILENAME or VARNAME do not exist, use NCCREATE first.
%
%    NCWRITE(FILENAME, VARNAME, VARDATA, START)
%    NCWRITE(FILENAME, VARNAME, VARDATA, START, STRIDE) writes VARDATA to
%    an existing variable VARNAME in file FILENAME beginning at the
%    location given by START. For an N-dimensional variable START is a
%    vector of 1-based indices of length N specifying the starting
%    location. The optional argument STRIDE, also of length N,  specifies
%    the inter-element spacing. STRIDE defaults to a vector of ones. Use
%    this syntax to append data to an existing variable or write partial
%    data.
%
%    If VARNAME already exists, NCWRITE expects the datatype of VARDATA to
%    match the NetCDF variable datatype. If VARNAME has a fill value,
%    'scale_factor' or 'add_offset' attribute, NCWRITE expects data in
%    double format and will cast VARDATA to the NetCDF data type after
%    applying the following attribute conventions in sequence:
%      1. The value of 'add_offset' attribute is subtracted from VARDATA
%      2. VARDATA is divided by the value of 'scale_factor' attribute.
%      3. NaNs in VARDATA are replaced by the value of the '_FillValue'
%         attribute. If this attribute does not exist, NCWRITE will try to
%         use the fill value for this variable as reported by the library.
%
%
%    Example: Create a new netcdf4_classic file, write a scalar variable
%    with no dimensions. Add the creation time as a global attribute.
%        nccreate('myfile.nc','pi');
%        ncwrite('myfile.nc','pi',3.1);
%        ncwriteatt('myfile.nc','/','creation_time',datestr(now));
%        % overwrite existing data
%        ncwrite('myfile.nc','pi',3.1416);
%        ncdisp('myfile.nc');
%
%   Example: Create a netcdf4_classic file with a variable defined on an
%   unlimited dimension. Write data incrementally to the variable.
%        nccreate('myncfile.nc','vmark',...
%                 'Dimensions', {'time', inf, 'cols', 6},...
%                 'ChunkSize',  [3 3],...
%                 'DeflateLevel', 2);
%        ncwrite('myncfile.nc','vmark', eye(3),[1 1]);
%        varData = ncread('myncfile.nc','vmark');
%        disp(varData);
%        ncwrite('myncfile.nc','vmark',fliplr(eye(3)),[1 4]);
%        varData = ncread('myncfile.nc','vmark');
%        disp(varData);
%
%
%   See also ncread, ncwriteatt, ncdisp, ncinfo, nccreate, netcdf.

%   Copyright 2010-2013 The MathWorks, Inc.

% Use format of the existing file.
formatStr = '';

switch nargin
    case 3
        start  = [];
        stride = [];
    case 4
        stride = [];
end

ncObj   = internal.matlab.imagesci.nc(ncFile,'a',formatStr);
cleanUp = onCleanup(@()ncObj.close());

%Write data
ncObj.write(varName, varData, start, stride);
