function varargout = iterate(varargin)
%H5A.iterate  Iterates through attributes connected to object.
%   [status,idx_stop,cdata_out] = H5A.iterate(obj_id,idx_type,order,idx_start,iter_func,cdata_in)
%   executes the specified function iter_func for each attribute connected 
%   to an object.  obj_id identifies the object to which attributes are 
%   attached.  idx_type is the type of index and valid values include the
%   following: 
%
%      'H5_INDEX_NAME'      - an alpha-numeric index by attribute name
%      'H5_INDEX_CRT_ORDER' - an index by creation order
%
%   order specifies the index traversal order. Valid values include the
%   following: 
%
%      'H5_ITER_INC'    - iteration is from beginning to end
%      'H5_ITER_DEC'    - iteration is from end to beginning
%      'H5_ITER_NATIVE' - iteration is in the fastest available order
%
%   idx_start specifies the starting point of the iteration. idx_stop
%   returns the point at which iteration was stopped. This allows an
%   interrupted iteration to be resumed.
%
%   The callback function iter_func must have the following signature: 
%
%       [status,cdata_out] = iter_func(obj_id,attr_name,info,cdata_in)
%
%   cdata_in is a user-defined value or structure and is passed to the 
%   first step of the iteration in the iter_func cdata_in parameter. The 
%   cdata_out of an iteration step forms the cdata_in for the next 
%   iteration step. The final cdata_out at the end of the iteration is
%   then returned to the caller as cdata_out. This form of H5A.iterate 
%   corresponds to the H5Aiterate2 function in the HDF5 C API.
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
%   H5A.iterate(loc_id, attr_idx, iterator_func) executes the specified 
%   function for each attribute of the group, dataset, or named datatype 
%   specified by loc_id. attr_idx specifies where the iteration begins.
%   iterator_func must be a function handle.
%
%   The iterator function must have the following signature:
%
%       status = iterator_func(loc_id,attr_name)
%
%   loc_id still specifies the group, dataset, or named datatype passed 
%   into H5A.iterate, and attr_name specifies the current attribute.  
%   This form of H5A.iterate corresponds to H5Aiterate1 function in the 
%   HDF5 C API.
%
%   See also H5A.

%   Copyright 2006-2013 The MathWorks, Inc.

nargoutchk(0,3);

switch ( nargin )
	case 3
		H5ML.hdf5lib2('H5Aiterate', varargin{:});
	case 6
		if ~isa(varargin{5}, 'function_handle')
		    error(message('MATLAB:imagesci:H5:notFunctionHandle'));
		end
		f = functions(varargin{5});
		if isempty(f.file)
		    error(message('MATLAB:imagesci:H5:badIterateFunction'));
		end

		[status,n,cdata_out] = H5ML.hdf5lib2('H5Aiterate', varargin{:});

		varargout = cell(1,nargout);
		if nargout > 0
			varargout{1} = status;
		end
		if nargout > 1
			varargout{2} = n;
		end
		if nargout > 2
			varargout{3} = cdata_out;
		end
	otherwise
		error(message('MATLAB:imagesci:validate:wrongNumberOfInputs'));
end		
