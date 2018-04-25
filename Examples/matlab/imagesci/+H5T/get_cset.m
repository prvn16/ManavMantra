function cset = get_cset(type_id)
%H5T.get_cset  Return character set of string datatype.
%   cset = H5T.get_cset(type_id) returns the character set type of the 
%   datatype specified by type_id.
%
%   Example:
%      fid = H5F.open('example.h5');
%      dset_id = H5D.open(fid,'/g3/string');
%      type_id = H5D.get_type(dset_id);
%      cset = H5T.get_cset(type_id);
%      switch(cset)
%         case H5ML.get_constant_value('H5T_CSET_ASCII')
%             fprintf('ASCII\n');
%         case H5ML.get_constant_value('H5T_CSET_UTF8')
%             fprintf('UTF-8\n');
%      end
%
%   See also H5T, H5T.set_cset.

%   Copyright 2006-2013 The MathWorks, Inc.

cset = H5ML.hdf5lib2('H5Tget_cset',type_id); 
