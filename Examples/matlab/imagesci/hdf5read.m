function [data, attributes] = hdf5read(varargin)
%HDF5READ Reads data from HDF5 files.
%   HDF5READ is not recommended.  Use H5READ instead.
%
%   HDF5READ reads data from a data set in an HDF5 file.  If the
%   name of the data set is known, then HDF5READ will search the file
%   for the data.  Otherwise, use HDF5INFO to obtain a structure
%   describing the contents of the file. The fields of the structure
%   returned by HDF5INFO are structures describing the data sets 
%   contained in the file.  A structure describing a data set may be
%   extracted and passed directly to HDF5READ.  These options are 
%   described in detail below.
%
%   DATA = HDF5READ(FILENAME,DATASETNAME) returns in the variable DATA
%   all data from the file FILENAME for the data set named DATASETNAME.  
%   
%   DATA = HDF5READ(FILENAME,LOCATION,ATTRIBUTENAME) returns in the 
%   variable DATA all data from the file FILENAME for the attribute named 
%   ATTRIBUTENAME attached to the location provided in LOCATION. Location 
%   can be either a dataset or a group.
%
%   DATA = HDF5READ(HINFO) returns in the variable DATA all data from the
%   file for the particular data set described by HINFO.  HINFO is a
%   structure extracted from the output structure of HDF5INFO (see example).
%
%   [DATA, ATTR] = HDF5READ(..., 'ReadAttributes', BOOL) returns the
%   data information for the data set as well as the associated attribute
%   information contained within that data set.  By default, BOOL is
%   false.
%
%   [...] = HDF5READ(..., 'V71Dimensions', BOOL) specifies whether to
%   change the majority of datasets.  If BOOL is true, the first two
%   dimensions of the dataset are permuted.  This behavior may not
%   correctly reflect the intent of the data and may invalidate metadata,
%   but it is consistent with previous versions of HDF5READ (MATLAB 7.1
%   [R14SP3] and earlier).  When BOOL is false (the default), the data
%   dimensions correctly reflect the data ordering as it is written in
%   the file.  Each dimension in the output variable matches the same
%   dimension in the file. 
%   
%   HDF5READ performs best on numeric datasets.  It is strongly recommended
%   that you use the low-level HDF5 interface when reading string, compound, 
%   or variable length datasets.  To read a subset of a dataset, you must
%   use the low-level interface.
%  
%   Example:
%
%     % Read a dataset based on an HDF5INFO structure.
%     info = hdf5info('example.h5');
%     dset = hdf5read(info.GroupHierarchy.Groups(2).Datasets(1));
%
%   Please read the file hdf5copyright.txt for more information.
%
%   See also H5READ, H5READATT, HDF5, H5D.READ.

%   Copyright 1984-2013 The MathWorks, Inc.

narginchk(1,7);
if isstruct(varargin{1})
    settings = parse_hinfo(varargin{:});
elseif ischar(varargin{1}) 
    if rem(nargin,2) == 0
        % Even number of arguments means no attribute to parse
        settings = parse_with_dataset(varargin{:});
    else
        settings = parse_with_attribute(varargin{:});
    end
else
    error(message('MATLAB:imagesci:deprecatedHDF5:badFirstInput'));
end

% Verify existence of filename.
% Get full filename.
fid = fopen(settings.filename);

if (fid == -1)
  
    % Look for filename with extensions.
    fid = fopen([settings.filename '.h5']);
    
    if (fid == -1)
        fid = fopen([settings.filename '.h5']);
    end
    
end

if (fid == -1)
    error(message('MATLAB:imagesci:validate:fileOpen', settings.filename))
else
    settings.filename = fopen(fid);
    fclose(fid);
end

% Read the data
[data, attributes] = hdf5readc(settings.filename, ...
                               settings.datasetName, ...
                               settings.attributeName, ...
                               settings.readAttributes, ...
                               settings.V71Dimensions);


%--------------------------------------------------------------------------
function settings = parse_with_dataset(filename,location,varargin)

settings.readAttributes = false;
settings.datasetName = '';
settings.attributeName = '';
settings.filename = '';
settings.V71Dimensions = false;

p = inputParser;
p.addRequired('filename',@ischar);
p.addRequired('location',@ischar);
p.addParamValue('ReadAttributes',false,@islogical);
p.addParamValue('V71Dimensions',false,@islogical);
p.parse(filename,location,varargin{:});

settings.filename = filename;
settings.datasetName = p.Results.location;

settings.readAttributes = p.Results.ReadAttributes;
settings.V71Dimensions = p.Results.V71Dimensions;

%--------------------------------------------------------------------------
function settings = parse_with_attribute(filename,location,attribute,varargin)

settings.readAttributes = false;
settings.datasetName = '';
settings.attributeName = '';
settings.filename = '';
settings.V71Dimensions = false;

p = inputParser;
p.addRequired('filename',@ischar);
p.addRequired('location',@ischar);
p.addRequired('attribute',@ischar);
p.addParamValue('ReadAttributes',true,@islogical);
p.addParamValue('V71Dimensions',false,@islogical);
p.parse(filename,location,attribute,varargin{:});

settings.filename = filename;
settings.datasetName = p.Results.location;
settings.attributeName = p.Results.attribute;

settings.readAttributes = p.Results.ReadAttributes;
settings.V71Dimensions = p.Results.V71Dimensions;


%--------------------------------------------------------------------------
function settings = parse_hinfo(hinfo,varargin)

settings.readAttributes = false;
settings.datasetName = '';
settings.attributeName = '';
settings.filename = '';
settings.V71Dimensions = false;

p = inputParser;
p.addRequired('hinfo',@validate_hinfo_struct);
p.addParamValue('ReadAttributes',true,@islogical);
p.addParamValue('V71Dimensions',false,@islogical);
p.parse(hinfo,varargin{:});

hinfo = p.Results.hinfo;
    
settings.filename = hinfo.Filename;
if isfield(hinfo,'Location') % An attribute
    settings.datasetName = hinfo.Location;
    settings.attributeName = hinfo.Shortname;
else
    settings.datasetName = hinfo.Name;
end

settings.readAttributes = p.Results.ReadAttributes;
settings.V71Dimensions = p.Results.V71Dimensions;

%--------------------------------------------------------------------------
function tf = validate_hinfo_struct(hinfo)
tf = true;

if ~isfield(hinfo,'Filename')
	tf = false;
    return;
end

if isfield(hinfo,'Location') && isfield(hinfo,'Shortname') % An attribute
	return
elseif isfield(hinfo,'Name')
	return
else
	tf = false;
end



