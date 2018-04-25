function size = vlen_get_buf_size(varargin)
%H5D.vlen_get_buf_size  Determine variable length storage requirements.
%   size = H5D.vlen_get_buf_size(dataset_id, type_id, space_id) determines 
%   the number of bytes required to store the VL data from the dataset, 
%   using the space_id for the selection in the dataset on disk and the 
%   type_id for the memory representation of the VL data in memory.
%
%   See also H5D.

%   Copyright 2006-2013 The MathWorks, Inc.

size = H5ML.hdf5lib2('H5Dvlen_get_buf_size', varargin{:});            
