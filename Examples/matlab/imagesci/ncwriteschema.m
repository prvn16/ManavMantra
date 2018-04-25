function ncwriteschema(ncFile, schemastruct)
%NCWRITESCHEMA Add NetCDF schema definitions to NetCDF file.
%
%    NCWRITESCHEMA(NCFILENAME, SCHEMA) creates or adds attributes,
%    dimensions, variable definitions and group structure defined in the
%    SCHEMA structure to the file NCFILENAME. Output of NCINFO can be used
%    as a SCHEMA structure. If NCFILENAME does not exist, a new
%    netcdf4_classic format file is created, unless overridden by a
%    'Format' field in SCHEMA. 
%
%    A SCHEMA can represent either a dimension, variable, a entire NetCDF
%    file or a netcdf4 group. An array of similar SCHEMA structure elements
%    can also be used. Details of each individual SCHEMA structures are
%    given below, fields marked with * are optional.
%
%      Dimension schema:
%             Name           Dimension name.
%             Length         Required length of the dimension. Can be Inf.
%             Unlimited*     Boolean flag indicating if the dimension is
%                            unlimited.
%             Format*        The NetCDF file format required.
%
%      Variable schema:
%             Name           Variable name. 
%             Dimensions     The variable's dimension schema. 
%             Datatype       MATLAB datatype string.
%             Attributes*    A structure array of variable attributes with
%                            Name and Value fields.
%             ChunkSize*     Required chunk size of the variable.
%             FillValue*     Required fill value.
%             DeflateLevel*  Required deflate compression level.
%             Shuffle*       Boolean flag to turn on Shuffle filter.
%             Format*        The NetCDF file format required.
%
%      Group/File schema: 
%             Name           Group name. Use '/' to indicate full file.
%             Dimensions*    Dimension schema.
%             Variables*     Variable schema.
%             Attributes*    Group/Global attribute structure array with
%                            Name and Value fields.
%             Format*        The NetCDF file format required.
%
%    NCWRITESCHEMA does not write variable data. Use NCWRITE to write data
%    to the created variables. Created unlimited dimensions will have an
%    initial size of 0 until data is written.
%
%    NCWRITESCHEMA cannot change the format of an existing file. It can not
%    redefine existing variables and dimensions in NCFILENAME. A warning
%    will be issued and further processing of the input SCHEMA will
%    continue.
%
%
%    Example: Create a classic format file with two dimension definitions.
%       mySchema.Name   = '/';
%       mySchema.Format = 'classic';
%       mySchema.Dimensions(1).Name   = 'time';
%       mySchema.Dimensions(1).Length = Inf;
%       mySchema.Dimensions(2).Name   = 'rows';
%       mySchema.Dimensions(2).Length = 10;
%       ncwriteschema('emptyFile.nc', mySchema);
%       ncdisp('emptyFile.nc');
%
%    Example: Create a netcdf4_classic format file to store a single
%    variable from an existing file.
%       myVarSchema = ncinfo('example.nc','peaks');
%       ncwriteschema('peaksFile.nc',myVarSchema);
%       peaksData   = ncread('example.nc','peaks');
%       ncwrite('peaksFile.nc','peaks',peaksData);
%       ncdisp('peaksFile.nc');
%
%    See also ncdisp, ncinfo, ncwrite, ncread, netcdf.

%   Copyright 2010-2013 The MathWorks, Inc.

validateattributes(schemastruct,{'struct'},{'nonempty'},2);

if(~isfield(schemastruct,'Format'))
    [schemastruct.Format] = deal('');
end

fileCreatedByNC = false;
if(~exist(ncFile,'file'))
    fileCreatedByNC = true;
end

ncObj   = internal.matlab.imagesci.nc(ncFile,'a',schemastruct(1).Format);
cleanUp = onCleanup(@()ncObj.close());

try 
    ncObj.writeSchema(schemastruct);
catch ALL
    if(fileCreatedByNC)
        clear cleanUp;
        delete(ncFile);
    end
    rethrow(ALL);
end

