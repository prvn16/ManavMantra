function write(varargin)
%H5D.write  Write data to HDF5 dataset.
%   H5D.write(dataset_id, mem_type_id, mem_space_id, file_space_id, plist_id,buf) 
%   writes the dataset specified by dataset_id from the application 
%   memory buffer buf into the file. plist_id specifies the data transfer 
%   properties. mem_type_id identifies the memory datatype of the dataset. 
%   mem_space_id and file_space_id define the part of the dataset to write. 
%   The memory datatype should usually be 'H5ML_DEFAULT', which specifies
%   that MATLAB should determine the appropriate memory datatype.
%
%   Note:  The HDF5 library uses C-style ordering for multidimensional 
%   arrays, while MATLAB uses FORTRAN-style ordering.  Please consult 
%   "Using the MATLAB Low-Level HDF5 Functions" in the MATLAB documentation 
%   for more information.
%
%   Example:  
%       % Write to the entire 36-by-19 /g4/world example dataset.
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.h5');
%       copyfile(srcFile,'myfile.h5');
%       fileattrib('myfile.h5','+w');
%       plist = 'H5P_DEFAULT';
%       fid = H5F.open('myfile.h5','H5F_ACC_RDWR',plist);
%       dset_id = H5D.open(fid,'/g4/world');
%       dims = [36 19];
%       data = rand(dims);
%       H5D.write(dset_id,'H5ML_DEFAULT','H5S_ALL','H5S_ALL',plist,data);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   Example:  
%       % Write to the entire two-element /g3/VLstring dataset.  
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.h5');
%       copyfile(srcFile,'myfile.h5');
%       fileattrib('myfile.h5','+w');
%       h5disp('myfile.h5','/g3/VLstring');
%       plist = 'H5P_DEFAULT';
%       fid = H5F.open('myfile.h5','H5F_ACC_RDWR',plist);
%       dset_id = H5D.open(fid,'/g3/VLstring');
%       data = {'dogs'; 'dogs and cats'};
%       H5D.write(dset_id,'H5ML_DEFAULT','H5S_ALL','H5S_ALL',plist,data);
%       H5D.close(dset_id);
%       H5F.close(fid);
%       data_out = h5read('myfile.h5','/g3/VLstring');
%
%   Example:  
%       % Write a 10-by-5 block of data to the location starting at row 
%       % index 15 and column index 5 of the same dataset.  Recall that
%       % indexing is zero-based.
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.h5');
%       copyfile(srcFile,'myfile.h5');
%       fileattrib('myfile.h5','+w');
%       plist = 'H5P_DEFAULT';
%       fid = H5F.open('myfile.h5','H5F_ACC_RDWR',plist);
%       dset_id = H5D.open(fid,'/g4/world');
%       start = [15 5];
%       h5_start = fliplr(start);
%       block = [10 5];
%       h5_block = fliplr(block);
%       mem_space_id = H5S.create_simple(2,h5_block,[]);
%       file_space_id = H5D.get_space(dset_id);
%       H5S.select_hyperslab(file_space_id,'H5S_SELECT_SET',h5_start,[],[],h5_block);
%       data = rand(block);
%       H5D.write(dset_id,'H5ML_DEFAULT',mem_space_id,file_space_id,plist,data);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5D, H5D.read.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Dwrite', varargin{:});            
