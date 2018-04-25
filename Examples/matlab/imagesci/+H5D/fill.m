function buf = fill(varargin)
%H5D.fill  Fill buffer with fill value.
%
%   H5D.fill is not recommended.  Use MATLAB indexing instead.
%
%   output_buf = H5D.fill(fillvalue,fill_type_id,buf,buf_type_id,space_id) 
%   returns an array with elements specified by a dataspace selection, 
%   space_id, set to fillvalue.  fill_type_id specifies the datatype of the 
%   fill value.  buf is used to initialize output_buf.  buf_type_id 
%   specifies the datatype of the elements to be filled.  
%
%   See also H5D.

%   Copyright 2006-2013 The MathWorks, Inc.

buf = H5ML.hdf5lib2('H5Dfill', varargin{:});
