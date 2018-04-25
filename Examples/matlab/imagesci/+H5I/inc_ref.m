function ref_count = inc_ref(obj_id)
%H5I.inc_ref  Increment reference count of specified object.
%   ref_count = H5I.inc_ref(obj_id) increments the reference count of the
%   object specified by obj_id and returns the new count.
%
%   See also H5I, H5I.dec_ref, H5I.get_ref.

%   Copyright 2006-2013 The MathWorks, Inc.

ref_count = H5ML.hdf5lib2('H5Iinc_ref', obj_id);            
