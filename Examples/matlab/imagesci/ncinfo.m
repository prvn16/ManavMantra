function info = ncinfo(ncFile, location)
%NCINFO  Return information about a NetCDF source.
%
%    FINFO = NCINFO(FILENAME) returns information about the entire NetCDF
%    file FILENAME as a structure FINFO.
%
%    FINFO = NCINFO(OPENDAP_URL) returns information about the OPeNDAP
%    NetCDF data source.
%
%    FINFO contains the following fields:
%
%      Filename:   NetCDF file name or the OPeNDAP URL.
%      Name:       '/', indicating the full file (root level).
%      Dimensions: An array of structures with these fields:
%                   Name:            Dimension name.
%                   Length:          Current length of the dimension.
%                   Unlimited:       Boolean flag, true for unlimited
%                                    dimensions
%      Variables:  An array of structures with these fields:
%                   Name:            Variable name.
%                   Dimensions:      Associated dimensions.
%                   Size:            Current variable size.
%                   Datatype:        MATLAB datatype.
%                   Attributes:      Associated variable attributes.
%                   ChunkSize:       Chunk size, if defined. [] otherwise.
%                   FillValue:       Fill value of the variable.
%                   DeflateLevel:    Deflate filter level if enabled.
%                   Shuffle:         Shuffle filter enabled flag.
%      Attributes: An array of global attributes with these fields:
%                   Name:            Attribute name.
%                   Value:           Attribute value.
%      Groups:     An array of groups present in the file. [] for
%                  non netcdf4 format files. If groups are present, its
%                  structure follows the layout of FINFO.
%      Format:     The format of the NetCDF file.
%
%    VINFO = NCINFO(SOURCE,VARNAME) returns information about the variable
%    VARNAME in the NetCDF source, SOURCE, which can either be a filename
%    or an OPeNDAP URL. VINFO is a structure as described by the
%    'Variables' field above.
%
%    GINFO = NCINFO(SOURCE,GROUPNAME) returns information about the group
%    GROUPNAME, from the netcdf4 source. GINFO has the same structure as
%    FINFO. The 'Name' field is populated with the group name. Only
%    dimensions defined in GROUPNAME are returned in the 'Dimensions' field
%    of GINFO.
%
%
%           Note: Use NCDISP for visual inspection of a NetCDF source.
%
%
%    Example: Search for dimensions starting with the string 'x' in file.
%       finfo    = ncinfo('example.nc');
%       disp(finfo);
%       dimNames = {finfo.Dimensions.Name};
%       dimMatch = strncmpi(dimNames,'x',1);
%       disp(finfo.Dimensions(dimMatch));
%
%    Example: Obtain the size of a variable and check if it has any
%    unlimited dimensions.
%       vinfo       = ncinfo('example.nc','peaks');
%       varSize     = vinfo.Size;
%       disp(vinfo);
%       hasUnLimDim = any([vinfo.Dimensions.Unlimited]);
%
%    Example: Find all unlimited dimensions defined in a group.
%       ginfo     = ncinfo('example.nc','/grid2/');
%       unlimDims = [ginfo.Dimensions.Unlimited];
%       disp(ginfo.Dimensions(unlimDims));
%
%
%    See also ncdisp, ncread, ncwrite, ncwriteschema, netcdf.

%   Copyright 2010-2013 The MathWorks, Inc.

if(nargin==1)
    location = '/';
end

ncObj   = internal.matlab.imagesci.nc(ncFile);
cleanUp = onCleanup(@()ncObj.close());

info    = ncObj.info(location);
