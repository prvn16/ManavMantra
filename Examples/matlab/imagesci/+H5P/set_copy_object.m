function set_copy_object(ocp_plist_id, copy_options)
%H5P.set_copy_object  Set properties to be used when objects are copied.  
%   H5P.set_copy_object(ocp_plist_id, copy_options) sets the properties in
%   the object copy property list ocp_plist_id that will be invoked when a
%   new copy is made of an existing object. ocp_plist_id is the object copy
%   property list and specifies the properties governing the copying of the
%   object.  
%
%   Several flags, described below, are available for inclusion in the
%   object copy property list: 
% 
%     H5O_COPY_SHALLOW_HIERARCHY_FLAG  Copy only immediate members of a
%                                      group. Default behavior, without
%                                      flag: Recursively copy all objects
%                                      below the group.   
%     H5O_COPY_EXPAND_SOFT_LINK_FLAG   Expand soft links into new objects.
%                                      Default behavior, without flag: Keep
%                                      soft links as they are.   
%     H5O_COPY_EXPAND_EXT_LINK_FLAG    Expand external link into new
%                                      objects. Default behavior, without
%                                      flag: Keep external links as they
%                                      are.
%     H5O_COPY_EXPAND_REFERENCE_FLAG   Copy objects that are pointed to by
%                                      references. Default behavior,
%                                      without flag: Update only the values
%                                      of object references.   
%     H5O_COPY_WITHOUT_ATTR_FLAG       Copy object without copying
%                                      attributes. Default behavior,
%                                      without flag: Copy object along with
%                                      all its attributes. 
%
%   Example:
%     ocp_plist_id = H5P.create ('H5P_OBJECT_COPY');
%     option1 = H5ML.get_constant_value('H5O_COPY_EXPAND_SOFT_LINK_FLAG');
%     option2 = H5ML.get_constant_value('H5O_COPY_EXPAND_REFERENCE_FLAG');
%     copy_options = bitor(option1,option2);
%     H5P.set_copy_object(ocp_plist_id, copy_options); 
%
%   See also H5P.

%   Copyright 2009-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_copy_object', ocp_plist_id, copy_options);            
