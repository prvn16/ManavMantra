function vardata = ncread(ncFile,varName,varargin)
%NCREAD Read variable data from a NetCDF source.
%
%    VARDATA = NCREAD(FILENAME,VARNAME) reads data from the variable
%    VARNAME in the NetCDF file FILENAME.
%
%    VARDATA = NCREAD(OPENDAP_URL,VARNAME) reads data from the variable
%    VARNAME from an OPeNDAP NetCDF data source.
%
%    VARDATA = NCREAD(SOURCE,VARNAME,START,COUNT) 
%    VARDATA = NCREAD(SOURCE,VARNAME,START,COUNT,STRIDE) reads data from
%    VARNAME beginning at the location given by START from SOURCE, which
%    can either be a filename or an OPeNDAP URL. For an N-dimensional
%    variable START is a vector of 1-based indices of length N specifying
%    the starting location. COUNT is also a vector of length N specifying
%    the number of elements to read along corresponding dimensions. If a
%    particular element of COUNT is Inf, data is read until the end of that
%    dimension. The optional argument STRIDE specifies the inter-element
%    spacing along each dimension. STRIDE defaults to a vector of ones.
%    
%    The MATLAB datatype of VARDATA will be the closest type to the
%    corresponding NetCDF datatype. VARDATA will be of type double, if at
%    least one of '_FillValue', 'scale_factor' and 'add_offset' variable
%    attribute is present. The following attribute conventions are applied
%    in sequence to VARDATA if the corresponding attribute exists for this
%    variable:
%
%       1. Values in VARDATA equal to the '_FillValue' attribute value are
%          replaced with NaNs. If '_FillValue' attribute does not exist,
%          NCREAD will query the library for the variable's fill value.
%       2. VARDATA is multiplied by the value of 'scale_factor' attribute.
%       3. The value of the 'add_offset' attribute is added to VARDATA.
%    
%
%    Example: Read and display the 'peaks' data in the example file.
%       ncdisp('example.nc','peaks');
%       peaksData  = ncread('example.nc','peaks');
%       peaksDesc  = ncreadatt('example.nc','peaks','description');
%       surf(double(peaksData));
%       title(peaksDesc);
%
%    Example: Subsample the 'peaks' data by a factor of 2.
%       subsetdata = ncread('example.nc','peaks',...
%                           [1 1], [Inf Inf], [2 2]);
%       surf(double(subsetdata));
%
%
%   See also ncdisp, ncreadatt, ncinfo, ncwrite, netcdf.

%   Copyright 2010-2016 The MathWorks, Inc.

% Open in default read mode.
ncObj   = internal.matlab.imagesci.nc(ncFile);
cleanUp = onCleanup(@()ncObj.close());

narginchk(2,5);

vardata = ncObj.read(varName, varargin{:});
