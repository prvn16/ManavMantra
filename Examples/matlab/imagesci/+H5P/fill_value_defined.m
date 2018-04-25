function status = fill_value_defined(plist_id)
%H5P.fill_value_defined  Determine if fill value is defined.
%   fvstatus = H5P.fill_value_defined(plist_id) determines whether a fill
%   value is defined in the dataset creation property list plist_id.
%   fvstatus can have any of the following values:
%   H5D_FILL_VALUE_UNDEFINED, H5D_FILL_VALUE_DEFAULT, or
%   H5D_FILL_VALUE_USER_DEFINED.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/float');
%       dcpl = H5D.get_create_plist(dset_id);
%       fvstatus = H5P.fill_value_defined(dcpl);
%       switch(fvstatus)
%           case H5ML.get_constant_value('H5D_FILL_VALUE_UNDEFINED')
%               fprintf('fill value undefined\n');
%           case H5ML.get_constant_value('H5D_FILL_VALUE_DEFAULT')
%               fprintf('fill value set to default\n');
%           case H5ML.get_constant_value('H5D_FILL_VALUE_USER_DEFINED')
%               fprintf('fill value is user defined\n');
%       end
%
%   See also H5P, H5P.get_fill_value, H5P.set_fill_value.

%   Copyright 2006-2013 The MathWorks, Inc.

status = H5ML.hdf5lib2('H5Pfill_value_defined', plist_id);            
