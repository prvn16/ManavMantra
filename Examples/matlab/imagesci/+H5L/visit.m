function [status, opdata_out] = visit(group_id,index_type,order,iter_func,opdata_in)
%H5L.visit  Recursively iterate through links in group.
%   [status opdata_out] = H5L.visit(group_id,index_type,order,iter_func,opdata_in) 
%   recursively iterates through all links in and below a group, specified 
%   by group_id, to perform a common function whose function handle is
%   iter_func. 
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
%   Note that the index type passed in index_type is a best effort
%   setting. If the application passes in a value indicating iteration
%   in creation order and a group is encountered that was not tracked in
%   creation order, that group will be iterated over in alpha-numeric
%   order by name, or name order. (Name order is the native order used
%   by the HDF5 Library and is always available.)
%
%   order specifies the order in which objects are to be inspected along
%   the index specified in index_type. Valid values include the following:
%
%      'H5_ITER_INC'    Increasing order 
%      'H5_ITER_DEC'    Decreasing order 
%      'H5_ITER_NATIVE' Fastest available order   
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

validateattributes(iter_func,{'function_handle'},{'scalar'},'H5L.visit','iter_func');

f = functions(iter_func);
if isempty(f.file)
    error(message('MATLAB:imagesci:H5:notFunctionHandle'));
end
if (nargin(iter_func) ~= 3) || (nargout(iter_func) ~= 2)
    error(message('MATLAB:imagesci:H5:invalidIterationFunctionSignature'));  
end
[status, opdata_out] = H5ML.hdf5lib2('H5Lvisit',group_id,index_type,order,iter_func,opdata_in);
