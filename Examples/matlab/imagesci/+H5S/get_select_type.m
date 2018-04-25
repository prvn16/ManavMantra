function output = get_select_type(space_id)
%H5S.get_select_type  Return type of dataspace selection.
%   sel_type = H5S.get_select_type(space_id) returns the dataspace
%   selection type.  Valid return values correspond to the following 
%   enumerated constants:
% 
%       H5S_SEL_NONE 
%       H5S_SEL_POINTS 
%       H5S_SEL_HYPERSLABS
%       H5S_SEL_ALL
%
%   Example:       
%       dims = [100 200];
%       h5_dims = fliplr(dims);
%       space_id = H5S.create_simple(2,h5_dims,h5_dims);
%       start = fliplr([10 20]); block = fliplr([20 30]);
%       H5S.select_hyperslab(space_id,'H5S_SELECT_SET',start,[],[],block);
%       sel_type = H5S.get_select_type(space_id);
%       switch(sel_type)
%           case H5ML.get_constant_value('H5S_SEL_NONE')
%               fprintf('no selection\n');
%           case H5ML.get_constant_value('H5S_SEL_POINTS');
%               fprintf('point selection\n');
%           case H5ML.get_constant_value('H5S_SEL_HYPERSLABS');
%               fprintf('hyperslab selection\n');
%       end
%
%   See also H5S, H5S.select_elements, H5S.select_hyperslab, 
%   H5ML.get_constant_value.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Sget_select_type', space_id);            
