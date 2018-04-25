function [status, idx_out, opdata_out] = iterate_scales(dset_id,dim,idx_in,iter_func,opdata_in)
%H5DS.iterate_scales  Iterate on scales attached to dataset dimension.
%   [status idx_out opdata_out] = H5DS.iterate_scales(dset_id,dim,idx_in,iter_func,opdata_in) 
%   iterates over the scales attached to dimension dim of the dataset 
%   dset_id to perform a common operation whose function handle is 
%   iter_func.
%
%   idx_in specifies the starting point of the iteration. idx_out returns 
%   the point at which iteration was stopped. This allows an interrupted 
%   iteration to be resumed. If idx_in is [], then the iterator starts at 
%   the first member.
%
%   The callback function iter_func must have the following signature: 
%
%       function [status opdata_out] = iter_func(dset_id,dim,dimscale_id,opdata_in)
%
%   opdata_in is a user-defined value or structure and is passed to the 
%   first step of the iteration in the iter_func opdata_in parameter. The 
%   opdata_out of an iteration step forms the opdata_in for the next 
%   iteration step. The final opdata_out at the end of the iteration is
%   then returned to the caller as opdata_out.
%   
%   dimscale_id specifies the current dimension scale dataset identifier and dim 
%   is the associated dimension.
%
%   status value returned by iter_func is interpreted as follows:
%
%      zero     - Continues with the iteration or returns zero status value
%                 to the caller if all members have been processed.   
%      positive - Stops the iteration and returns the positive status value
%                 to the caller.
%      negative - Stops the iteration and throws an error indicating
%                 failure.
%
%   See also H5DS.

%   Copyright 2009-2013 The MathWorks, Inc.

validateattributes(iter_func,{'function_handle'},{'scalar'},'H5DS.iterate_scales','ITER_FUNC');

f = functions(iter_func);
if isempty(f.file)
    error(message('MATLAB:imagesci:H5:badIterateFunction'));
end
if (nargin(iter_func) ~= 4) || (nargout(iter_func) ~= 2)
    error(message('MATLAB:imagesci:H5:invalidFunctionSignatureForIterateScales'));  
end
[status, idx_out, opdata_out] = H5ML.hdf5lib2('H5DSiterate_scales', dset_id, dim,idx_in,iter_func,opdata_in); 
           
