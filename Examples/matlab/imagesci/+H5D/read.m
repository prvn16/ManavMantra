function buf = read(varargin)
%H5D.read  Return data from HDF5 dataset.
%   data = H5D.read(dataset_id) reads the entire dataset specified by 
%   dataset_id.
%     
%   data = H5D.read(dataset_id,mem_type_id,mem_space_id,file_space_id,dxpl)
%   reads the dataset specified by dataset_id.  mem_type_id specifies the
%   memory datatype and should usually be 'H5ML_DEFAULT' to allow MATLAB to
%   determine the appropriate value.   mem_space_id describes how the data
%   is to be arranged in memory and should usually be 'H5S_ALL'.
%   file_space_id describes how the data is to be selected from the file.
%   It may also be given as 'H5S_ALL', but this will result in the entire
%   dataset being read into memory.  dxpl is the dataset transfer property
%   list identifier and should usually be 'H5P_DEFAULT'.
%
%   Note:  The HDF5 library uses C-style ordering for multidimensional 
%   arrays, while MATLAB uses FORTRAN-style ordering.  Please consult 
%   "Using the MATLAB Low-Level HDF5 Functions" in the MATLAB documentation 
%   for more information.
%
%   Example:  Read an entire dataset.
%       fid = H5F.open('example.h5'); 
%       dset_id = H5D.open(fid,'/g1/g1.1/dset1.1.1');
%       data = H5D.read(dset_id);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   Example:  Read the 2x3 hyperslab starting in the 4th row and 5th column
%   of the example dataset.
%       plist = 'H5P_DEFAULT';
%       fid = H5F.open('example.h5'); 
%       dset_id = H5D.open(fid,'/g1/g1.1/dset1.1.1');
%       dims = fliplr([2 3]);
%       mem_space_id = H5S.create_simple(2,dims,[]);
%       file_space_id = H5D.get_space(dset_id);
%       offset = fliplr([3 4]);
%       block = fliplr([2 3]);
%       H5S.select_hyperslab(file_space_id,'H5S_SELECT_SET',offset,[],[],block);
%       data = H5D.read(dset_id,'H5ML_DEFAULT',mem_space_id,file_space_id,plist);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5D, H5D.open, H5D.write, H5S.create_simple.

%   Copyright 2006-2013 The MathWorks, Inc.

if nargin < 2
    varargin = [varargin {'H5ML_DEFAULT','H5S_ALL','H5S_ALL','H5P_DEFAULT'}];
end

buf = H5ML.hdf5lib2('H5Dread',varargin{:});
