function walk(varargin)
%H5E.walk  Walk error stack.
%   H5E.walk(direction, func) walks the error stack for the current thread
%   and calls the specified function for each error along the way.
%   func is a function handle.  direction specifies how the error stack is
%   traversed and can be given by one of the following strings or the
%   numeric equivalent:
%
%       'H5E_WALK_UPWARD'
%       'H5E_WALK_DOWNWARD'
%
%   The specified function must have the following signature
%
%       status = func(n,error_struct)
%
%   where n is the indexed position of the error in the stack and 
%   error_struct is a structure with the following fields.  
%
%       maj_num    - major error number
%       min_num    - minor error number
%       func_name  - function in which the error occurred
%       file_name  - file in which the error occurred 
%       line       - line in file where error occurs 
%       desc       - optional supplied description  
%
%   This function corresponds to the H5Ewalk1 function in the HDF5 
%   library C API.
%
%   See also H5E, H5ML.get_constant_value.
   

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Ewalk', varargin{:});            
