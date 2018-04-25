function [max_compact,min_dense] = get_attr_phase_change(ocpl_id)
%H5P.get_attr_phase_change  Retrieve attribute phase change thresholds.
%   [max_compact,min_dense] = H5P.get_attr_phase_change(ocpl_id) 
%   retrieves attribute phase change thresholds for the dataset or 
%   group with creation property list ocpl_id.
%
%   max_compact is the maximum number of attributes to be stored in 
%   compact storage (default is 8).
% 
%   min_dense is the minimum number of attributes to be stored in 
%   dense storage (default is 6).
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/integer');
%       dcpl = H5D.get_create_plist(dset_id);
%       [max_compact,min_dense] = H5P.get_attr_phase_change(dcpl);
%       H5P.close(dcpl);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5P, H5P.set_attr_phase_change.

%   Copyright 2009-2013 The MathWorks, Inc.

[max_compact, min_dense] = H5ML.hdf5lib2('H5Pget_attr_phase_change', ocpl_id);            

