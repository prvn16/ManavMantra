function [output, idx_out] = iterate(id, idx_in, iter_func)
%H5P.iterate  Iterate over properties in property list.
%   [output idx_out] = H5P.iterate(id, idx_in, iter_func) executes the 
%   operation iter_func on each property in the property object specified 
%   in id. id can be a property list or a property class. idx_in specifies
%   the index of the next property to be processed. output is the value 
%   returned by the last call to iter_func. idx_out is the index of the 
%   last property processed.  iter_func is a function handle.
%
%   The iterator function must have the following signature
%
%       status = iter_func(id,prop_name)
%
%   id still identifies the property object passed into H5P.iterate, but 
%   name identifies the name of the current property.
%
%   See also H5P.

%   Copyright 2006-2013 The MathWorks, Inc.

if ~isa(iter_func,'function_handle')
	error(message('MATLAB:imagesci:H5:badIterateFunction'));
end

[output, idx_out] = H5ML.hdf5lib2('H5Piterate', id, idx_in, iter_func);            
