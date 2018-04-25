function ref_count = get_ref(obj_id)
%H5I.get_ref  Return reference count of specified object.
%   refcount = H5I.get_ref(obj_id) returns the reference count of the 
%   object specified by obj_id.
%
%   See also H5I, H5I.dec_ref, H5I.inc_ref.

%   Copyright 2006-2013 The MathWorks, Inc.

ref_count = H5ML.hdf5lib2('H5Iget_ref', obj_id);            
