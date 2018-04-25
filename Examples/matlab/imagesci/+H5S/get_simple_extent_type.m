function output = get_simple_extent_type(space_id)
%H5S.get_simple_extent_type  Return dataspace class.
%   space_type = H5S.get_simple_extent_type(space_id) returns the dataspace
%   class of the dataspace specified by space_id.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/integer');
%       space_id = H5D.get_space(dset_id);
%       space_type = H5S.get_simple_extent_type(space_id);
%       switch(space_type)
%           case H5ML.get_constant_value('H5S_SCALAR')
%               fprintf('scalar\n');
%           case H5ML.get_constant_value('H5S_SIMPLE')
%               fprintf('simple\n');
%           case H5ML.get_constant_value('H5S_NULL')
%               fprintf('none\n');
%       end
%
%   See also H5S, H5S.create, H5D.get_space, H5ML.get_constant_value.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Sget_simple_extent_type', space_id);            
