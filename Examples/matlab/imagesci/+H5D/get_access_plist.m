function plist_id = get_access_plist(dataset_id)
%H5D.get_access_plist  Return copy of dataset access property list.
%   plist_id = H5D.get_access_plist(dataset_id) returns a copy of the
%   dataset access property list used to open the specified dataset. 
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g1/g1.1/dset1.1.1');
%       dapl = H5D.get_access_plist(dset_id);
%       H5P.close(dapl);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5D, H5D.get_create_plist, H5P.close.

%   Copyright 2009-2013 The MathWorks, Inc.

plist_id = H5ML.hdf5lib2('H5Dget_access_plist', dataset_id);            
plist_id = H5ML.id(plist_id,'H5Pclose');
