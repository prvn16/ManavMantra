function set_attr_phase_change(ocpl_id,max_compact,min_dense)
%H5P.set_attr_phase_change  Set attribute storage phase change thresholds.
%   H5P.set_attr_phase_change(ocpl_id,max_compact,min_dense) sets 
%   attribute storage phase change thresholds for the group or dataset
%   with creation order property list ocpl_id.
%
%   max_compact is the maximum number of attributes to be stored in 
%   compact storage (default is 8).
% 
%   min_dense is the minimum number of attributes to be stored in 
%   dense storage (default is 6).
%
%   See also H5P, H5P.get_attr_phase_change.

%   Copyright 2009-2014 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_attr_phase_change', ocpl_id,max_compact,min_dense);            
