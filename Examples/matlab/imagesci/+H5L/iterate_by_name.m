function [status, idx_out, opdata_out] = iterate_by_name(loc_id,group_name,index_type,order,idx_in,iter_func,opdata_in,lapl_id)
%H5L.iterate_by_name  Iterate through links in group specified by name.
%   [status idx_out opdata_out] = H5L.iterate_by_name(loc_id,group_name,index_type,order,idx_in,iter_func,opdata_in,lapl_id) 
%   iterates through the links in a group to perform a common function 
%   whose function handle is iter_func. The starting point of the iteration  
%   is pairing of a specified by the location id and a relative group name.
%   H5L.iterate_by_name does not recursively follow links into subgroups of  
%   the specified group. A link access property list, lapl_id, may affect  
%   the outcome depending upon the type of link being traversed.
%
%   index_type and order establish the iteration.  index_type specifies
%   the index to be used. If the links have not been indexed by the index
%   type, they will first be sorted by that index then the iteration will
%   begin. If the links have been so indexed, the sorting step will be
%   unnecessary, so the iteration may begin more quickly. Valid values
%   include the following:
%
%      'H5_INDEX_NAME'      Alpha-numeric index on name 
%      'H5_INDEX_CRT_ORDER' Index on creation order   
%
%   order specifies the order in which objects are to be inspected along
%   the index specified in index_type. Valid values include the following:
%
%      'H5_ITER_INC'    Increasing order 
%      'H5_ITER_DEC'    Decreasing order 
%      'H5_ITER_NATIVE' Fastest available order   
%
%   idx_in specifies the starting point of the iteration. idx_out returns 
%   the point at which iteration was stopped. This allows an interrupted 
%   iteration to be resumed.
%
%   The callback function iter_func must have the following signature: 
%
%      function [status opdata_out] = iter_func(group_id,name,opdata_in)
%
%   opdata_in is a user-defined value or structure and is passed to the 
%   first step of the iteration in the iter_func opdata_in parameter. The 
%   opdata_out of an iteration step forms the opdata_in for the next 
%   iteration step. The final opdata_out at the end of the iteration is
%   then returned to the caller as opdata_out.
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
%   See also H5L.

%   Copyright 2009-2013 The MathWorks, Inc.

validateattributes(iter_func,{'function_handle'},{'scalar'},'H5L.iterate_by_name','iter_func');

f = functions(iter_func);
if isempty(f.file)
    error(message('MATLAB:imagesci:H5:badIterateFunction'));
end
if (nargin(iter_func) ~= 3) || (nargout(iter_func) ~= 2)
    error(message('MATLAB:imagesci:H5:invalidIterationFunctionSignature'));  
end

[status, idx_out, opdata_out] = H5ML.hdf5lib2('H5Literate_by_name', ...
    loc_id,group_name,index_type,order,idx_in,iter_func,opdata_in,lapl_id);            


