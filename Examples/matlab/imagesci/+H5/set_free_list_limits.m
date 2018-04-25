function set_free_list_limits(varargin)
%H5.set_free_list_limits  Set size limits on free lists.
%   H5.set_free_list_limits(reg_global_lim, reg_list_lim, arr_global_lim, 
%                           arr_list_lim, blk_global_lim, blk_list_lim ) 
%   sets size limits on all types of free lists.
%
%   See also H5.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5set_free_list_limits', varargin{:});
