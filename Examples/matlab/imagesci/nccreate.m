function nccreate(ncFile, varName, varargin)
%NCCREATE Create variable in NetCDF file.
%
%    NCCREATE(FILENAME, VARNAME) Create a scalar double variable called
%    VARNAME in the NetCDF file FILENAME. If FILENAME does not exist, a
%    netcdf4_classic format file is created. 
%    Use the 'Dimensions' parameter to create a non-scalar variable.
%
%    NCCREATE supports the following optional parameters:
%
%    'Dimensions' DIMENSIONS is a cell array specifying NetCDF dimensions
%                 for the variable. The cell array lists the dimension name
%                 as a string followed by its numerical length: {DNAME1,
%                 DLENGTH1, DNAME2, DLENGTH2, ...}. If a dimension already
%                 exists, the corresponding length is optional. The
%                 dimension is created at the same location as the
%                 variable. A different location can be specified (netcdf4
%                 format only) using a fully qualified dimension name.
%
%                 Use Inf to specify an unlimited dimension.
%  
%                 Note: All formats other than netcdf4 format files can
%                 have only one unlimited dimension per file and it has to
%                 be the last in the list specified. A netcdf4 format file
%                 can have any number of unlimited dimensions in any order.
%                 Note: A single dimension variable is always treated as a
%                 column vector.
%
%    'Datatype'   TYPE. The datatype of the NetCDF variable. 
%
%                    Use this           to create NetCDF variable of type
%                    'double'               NC_DOUBLE
%                    'single'               NC_FLOAT
%                    'int64'                NC_INT64*
%                    'uint64'               NC_UINT64*
%                    'int32'                NC_INT
%                    'uint32'               NC_UINT*
%                    'int16'                NC_SHORT
%                    'uint16'               NC_USHORT*
%                    'int8'                 NC_BYTE
%                    'uint8'                NC_UBYTE*
%                    'char'                 NC_CHAR
%                 * These datatypes are only available with netcdf4 format.
%
%    'Format'     FORMATSTR. When creating a new file NCFILENAME, FORMATSTR
%                 specifies the type of NetCDF file to create. Valid values
%                 are:
%                       'classic'           NetCDF 3.
%                       '64bit'             NetCDF 3 with 64-bit offsets.
%                       'netcdf4_classic'   NetCDF 4 classic model.
%                       'netcdf4'           NetCDF 4 model. Use this to 
%                                           enable group hierarchy.
%                 The default is 'netcdf4_classic'. If VARNAME contains a
%                 group, FORMATSTR is set to 'netcdf4'.
%
%
%    Optional creation parameters (netcdf4 or netcdf4_classic format only):
%
%    'FillValue'    FILLVALUE, A scalar specifying the fill value for
%                   unwritten data. If omitted, a default value is chosen
%                   by the NetCDF library. To disable fill values, set
%                   FILLVALUE to 'disable'.
%
%    'ChunkSize'    [NUM_ROWS, NUM_COLS, ..., NUM_NDIMS], specifies the
%                   chunk size along each dimension. If omitted, a default
%                   chunk size is chosen by the NetCDF library.
%
%    'DeflateLevel' LEVEL, A numeric value specifying the compression
%                   setting for the deflate filter. LEVEL should be between
%                   0 (least) and 9 (most). Deflate compression is disabled
%                   by default.
%
%    'Shuffle'      SHUFFLEFLAG, A boolean flag to turn on the Shuffle
%                   filter. The default is false.
%
%
%    Example: Create a new 2D variable in a classic format file. Write data
%    to this variable.
%        nccreate('myncclassic.nc','peaks',...
%                                  'Dimensions',{'r' 200 'c' 200},...
%                                  'Format','classic');
%        ncwrite('myncclassic.nc','peaks', peaks(200));
%        ncdisp('myncclassic.nc');
%
%
%    See also ncdisp, ncwrite, ncinfo, ncwriteschema, netcdf. 


%   Copyright 2010-2016 The MathWorks, Inc.

% Obtain the full path to the file before calling "exist" so that "exist" 
% only returns true if there is an existing file at the intended write
% location
[pathstr, filename, ext] = fileparts(ncFile);
if isempty(pathstr)
    pathstr = pwd;
end
ncFile = fullfile(pathstr, [filename, ext]);

if ~exist(ncFile,'file')
    formatStr = 'netcdf4_classic';
    % Check if the variable name has a group in it
    groupName = internal.matlab.imagesci.nc.parsePath(varName);
    if ~strcmpi(groupName,'/')
        %if it does, make the default format NETCDF4
        formatStr = 'netcdf4';
    end
    fileCreatedByNC = true;
else
    formatStr = '';
    fileCreatedByNC = false;
end

% Remove format from the PV list.
formatPVMatch = strcmpi(varargin,'format');
if any(formatPVMatch)
    formatInd = find(formatPVMatch);
    if formatInd == length(varargin)
        error(message('MATLAB:imagesci:netcdf:noformatValue'));
    end
    %Override with given format string.
    formatStr    = varargin{formatInd+1};
    
    varargin(formatInd+1) = [];
    varargin(formatInd)   = [];
end

ncObj   = internal.matlab.imagesci.nc(ncFile,'a', formatStr);
cleanUp = onCleanup(@()ncObj.close());

% Can not create a variable if it already exists.
if ncObj.isVariable(varName)
    error(message('MATLAB:imagesci:netcdf:variableExists', varName));
end

% Try to create a variable, if it fails, delete the file if we
% auto-created it.
try
    ncObj.createVariable(varName, varargin{:})
catch ALL
    if fileCreatedByNC
        clear cleanUp;
        delete(ncFile);
    end
    rethrow(ALL);
end

