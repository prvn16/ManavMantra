function value = all_filters_avail(plist_id)
%H5P.all_filters_avail Determine availability of all filters.
%   value = H5P.all_filters_avail(dcpl_id) returns a positive value if all
%   of the filters set in the dataset creation property list dcpl_id are
%   currently available, and zero if they are not.  A negative value
%   indicates failure.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/float');
%       dcpl = H5D.get_create_plist(dset_id);
%       if H5P.all_filters_avail(dcpl)
%           fprintf('all filters available\n');
%       else
%           fprintf('all filters not available\n');
%       end
%       H5P.close(dcpl);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5P, H5P.set_filter.

%   Copyright 2006-2013 The MathWorks, Inc.

value = H5ML.hdf5lib2('H5Pall_filters_avail', plist_id);            
