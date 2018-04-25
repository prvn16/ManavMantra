function file_id = create(varargin)
%H5F.create  Create HDF5 file.
%   file_id = H5F.create(filename) creates the file specified by filename
%   with default library properties if the file does not already exist.
%
%   file_id = H5F.create(name,flags,fcpl_id,fapl_id) creates the file
%   specified by name. flags specifies whether to truncate the file, if it 
%   already exists, or to fail if the file already exists.   flags can be
%   specified by one of the following strings or the numeric equivalent.
%
%       'H5F_ACC_TRUNC' - overwrite any existing file by the same name
%       'H5F_ACC_EXCL'  - do not overwrite an existing file
%
%   fcpl_id is the file creation property list identifier. fapl_id is
%   the file access property list identifier.  A value of 'H5P_DEFAULT' for
%   either property list indicates that the library should use default
%   values for the appropriate property list.
%
%   Example:  Create an HDF5 file called 'myfile.h5'.
%       fid = H5F.create('myfile.h5');
%       H5F.close(fid);
%
%   Example:  Create an HDF5 file called 'myfile.h5', overwriting any 
%   existing file by the same name.  Default file access and file creation 
%   properties shall apply.
%       fcpl = H5P.create('H5P_FILE_CREATE');
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',fcpl,fapl);
%       H5F.close(fid);
%
%   See also:  H5F, H5F.close, H5P.create, H5ML.get_constant_value.

%   Copyright 2006-2013 The MathWorks, Inc.

% supply defaults if necessary.
if nargin < 2
    varargin = [varargin {'H5F_ACC_EXCL','H5P_DEFAULT','H5P_DEFAULT'}];
end

file_id = H5ML.hdf5lib2('H5Fcreate', varargin{:});
file_id = H5ML.id(file_id,'H5Fclose');
