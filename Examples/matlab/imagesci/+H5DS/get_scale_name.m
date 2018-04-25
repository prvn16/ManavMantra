function name = get_scale_name(dimscale_id)
%H5DS.get_scale_name  Retrieve name of dimension scale.
%   name = H5DS.get_scale_name(dimscale_id) retrieves the name of the
%   dimension scale dimscale_id.
%
%   Example:
%       fid = H5F.open('example.h5');
%       lat_dset_id = H5D.open(fid,'/g4/lat');
%       scale_name = H5DS.get_scale_name(lat_dset_id);
%       H5D.close(lat_dset_id);
%       H5F.close(fid);
%
%   See also H5DS, H5DS.set_scale.

%   Copyright 2009-2013 The MathWorks, Inc.

name = H5ML.hdf5lib2('H5DSget_scale_name', dimscale_id);            
