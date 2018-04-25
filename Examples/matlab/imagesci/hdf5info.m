function info = hdf5info(filename, varargin)
%HDF5INFO Get information about an HDF5 file.
%   HDF5INFO is not recommended.  Use H5INFO instead.
%   
%   FILEINFO = HDF5INFO(FILENAME) returns a structure whose fields contain
%   information about the contents of an HDF5 file.  FILENAME is a
%   string that specifies the name of the HDF file. 
% 
%   FILEINFO = HDF5INFO(..., 'ReadAttributes', BOOL) allows the user to
%   specify whether or not to read in the values of the attributes in
%   the HDF5 file.  The default value for BOOL is true.
%
%   [...] = HDF5INFO(..., 'V71Dimensions', BOOL) specifies whether to
%   report the dimensions of datasets and attributes as given in earlier
%   versions of HDF5INFO (MATLAB 7.1 [R14SP3] and earlier).  If BOOL is
%   true, the first two dimensions are swapped to imply a change in
%   majority.  This behavior may not correctly reflect the intent of the
%   data, but it is consistent with HDF5READ when it is also given the
%   'V71Dimensions' parameter.  When BOOL is false (the default), the
%   data dimensions correctly reflect the data ordering as it is written
%   in the file.  Each dimension in the output variable matches the same
%   dimension in the file.
%   
%   Please read the file hdf5copyright.txt for more information.
%
%   Example:
%
%       info = hdf5info('example.h5');
%
%   See also H5READ, H5WRITE, H5INFO, HDF5.

%   Copyright 1984-2013 The MathWorks, Inc.

p = inputParser;
p.addRequired('filename',@ischar);
p.addParamValue('ReadAttributes',true,@islogical);
p.addParamValue('V71Dimensions',false,@islogical);
p.parse(filename,varargin{:});

read_attribute_values = p.Results.ReadAttributes;
V71Dimensions = p.Results.V71Dimensions;


% Get full filename.
fid = fopen(filename);

if (fid == -1)
  
    % Look for filename with extensions.
    fid = fopen([filename '.h5']);
    
    if (fid == -1)
        fid = fopen([filename '.h5']);
    end
    
end

if (fid == -1)
    error(message('MATLAB:imagesci:validate:fileOpen', filename))
else
    filename = fopen(fid);
    fclose(fid);
end

% Get file info and mode in which the file was opened.

d = dir(filename);

% Set the positions of the fields.
info.Filename = d.name;
info.LibVersion = '';
info.Offset = [];
info.FileSize = d.bytes;
info.GroupHierarchy = struct([]);

% Get the version of the library that wrote out the file, the offset, 
% and the group hierarchy!
[info.Offset, info.GroupHierarchy, majnum, minnum, relnum] = ...
    hdf5infoc(filename, read_attribute_values, V71Dimensions);

info.LibVersion = [num2str(majnum) '.' num2str(minnum) '.' num2str(relnum)];
