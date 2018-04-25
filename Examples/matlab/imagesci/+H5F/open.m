function file_id = open(filename,flags,fapl)
%H5F.open  Open HDF5 file.
%   file_id = H5F.open(filename) opens the file specified by 
%   filename for read-only access and returns the file identifier, file_id.
%
%   file_id = H5F.open(name,flags,fapl_id) opens the file specified by 
%   name, returning the file identifier, file_id. flags specifies file 
%   access flags and can be specified by one of the following strings
%   or their numeric equivalents:
%  
%       'H5F_ACC_RDWR'   - read-write mode
%       'H5F_ACC_RDONLY' - read-only mode
%  
%   The file access property list,fapl_id, may be specified as
%   'H5P_DEFAULT', in which case the default I/O settings are used.
%  
%   Example:   Open a file in read-only mode with default file access
%   properties.
%       fid = H5F.open('example.h5');
%       H5F.close(fid);
%
%   Example:  Open a file in read-write mode.
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.h5');
%       copyfile(srcFile,'myfile.h5');
%       fileattrib('myfile.h5','+w');
%       fid = H5F.open('myfile.h5','H5F_ACC_RDWR','H5P_DEFAULT');
%       H5F.close(fid);
%
%  See also H5F, H5F.close, H5ML.get_constant_value.

%   Copyright 2006-2013 The MathWorks, Inc.

% Get the full path name.
fid = fopen(filename,'r');
if fid ~= -1
    % It may be ok for FOPEN to fail if the file is to be opened with
    % a non-default driver such as the family driver.
    filename = fopen(fid);
    fclose(fid);
end

% Set default values if necessary.
if nargin == 1
    flags = 'H5F_ACC_RDONLY';
    fapl = 'H5P_DEFAULT';
end

file_id = H5ML.hdf5lib2('H5Fopen', filename, flags, fapl);            
file_id = H5ML.id(file_id,'H5Fclose');
