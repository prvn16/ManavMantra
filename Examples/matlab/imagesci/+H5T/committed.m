function output = committed(type_id)
%H5T.committed  Determines if datatype is committed.
%   output = H5T.committed(type_id) returns a positive value to indicate
%   that the datatype has been committed, and zero to indicate that it has
%   not. A negative value indicates failure.
%
%   Example:
%       type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       is_committed = H5T.committed(type_id);
%
%   See also H5T, H5T.commit.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tcommitted', type_id);       
