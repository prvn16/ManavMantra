function output = detect_class(varargin)
%H5T.detect_class  Determine of datatype contains specific class.
%   output = H5T.detect_class(type_id, class_id) returns a positive value
%   if the datatype specified in type_id contains any datatypes of the
%   datatype class specified in class_id, or zero to indicate that it does
%   not. A negative value indicates failure.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/vlen');
%       type_id = H5D.get_type(dset_id);
%       has_double = H5T.detect_class(type_id,'H5T_FLOAT');
%
%   See also H5T, H5D.get_type.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tdetect_class', varargin{:});            
