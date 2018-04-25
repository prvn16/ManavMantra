function bool = get_create_intermediate_group(lcpl_id)
%H5P.get_create_intermediate_group  Determine creation of intermediate groups.
%   bool = H5P.get_create_intermediate_group(lcpl_id)
%   determines whether the link creation property list lcpl_id is set 
%   to enable creating missing intermediate groups.
%
%   Example:
%       lcpl = H5P.create('H5P_LINK_CREATE');
%       if H5P.get_create_intermediate_group(lcpl)
%           fprintf('set to enable creating intermediate groups\n');
%       else
%           fprintf('not set to enable creating intermediate groups\n');
%       end
%       
%   See also H5P, H5P.set_create_intermediate_group.

%   Copyright 2009-2013 The MathWorks, Inc.

bool = H5ML.hdf5lib2('H5Pget_create_intermediate_group', lcpl_id);            
