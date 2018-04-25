function [copy_options] = get_copy_object(ocp_plist_id)
%H5P.get_copy_object  Return properties to be used when object is copied.  
%   copy_options = H5P.get_copy_object(ocpl_id) retrieves the
%   properties currently specified in the object copy property list
%   ocpl_id, which will be invoked when a new copy is made of an
%   existing object.   
%
%   Example:
%       ocpl = H5P.create('H5P_OBJECT_COPY');
%       options = H5P.get_copy_object(ocpl);
%
%   See also H5P, H5P.set_copy_object.

%   Copyright 2009-2013 The MathWorks, Inc.

copy_options = H5ML.hdf5lib2('H5Pget_copy_object', ocp_plist_id);            
