function output = dereference(dataset, ref_type, ref)
%H5R.dereference  Open object specified by reference.
%   output = H5R.dereference(dataset, ref_type, ref) returns an identifier
%   to the object specified by ref in the dataset specified by dataset.
%
%   Example:  
%       plist = 'H5P_DEFAULT';
%       space = 'H5S_ALL';
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/reference');
%       ref_data = H5D.read(dset_id,'H5T_STD_REF_OBJ',space,space,plist);
%       deref_dset_id = H5R.dereference(dset_id,'H5R_OBJECT',ref_data(:,1));
%       H5D.close(dset_id);
%       H5D.close(deref_dset_id);
%       H5F.close(fid);
%
%   See also H5R, H5R.create, H5I.get_name.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Rdereference', dataset, ref_type, ref);
output = H5ML.id(output, 'H5Oclose');
end
