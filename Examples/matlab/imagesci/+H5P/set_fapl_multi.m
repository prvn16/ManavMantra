function set_fapl_multi(fapl_id, varargin)
%H5P.set_fapl_multi  Set use of multi-file driver.
%   H5P.set_fapl_multi(FAPL_ID,RELAX) sets the file access property list
%   FAPL_ID to access HDF5 files created with the multi-driver with
%   default values provided by the HDF5 library.  RELAX is a boolean value
%   that allows read-only access to incomplete file sets when set to 1.
%
%   H5P.set_fapl_multi(FAPL_ID,MEMB_MAP,MEMB_FAPL,MEMB_NAME,MEMB_ADDR,RELAX)
%   sets the file access property list to use the multi-file driver.  
%   MEMB_MAP maps memory usage types to other memory usage types.  
%   MEMB_FAPL contains a property list for each memory usage type. 
%   MEMB_NAME is a name generator for names of member files.  MEMB_ADDR 
%   specifies the offsets within the virtual address space at which each 
%   type of data storage begins. 
%
%   See also H5P, H5P.get_fapl_multi.

%   Copyright 2006-2013 The MathWorks, Inc.


id = H5ML.unwrap_ids(fapl_id);

% check for default case.
if nargin == 2
   H5ML.hdf5lib2('H5Pset_fapl_multi', id, varargin{end});
   return
end

narginchk(6,6);

memb_map = varargin{1};
memb_fapl = varargin{2};
memb_name = varargin{3};
memb_addr = varargin{4};
relax = varargin{5};

validateattributes(memb_fapl,{'double','H5ML.id'},{},'','MEMB_FAPL');

% If not the default case, have to unwrap each of the IDs.
memb_fap = zeros(1,numel(memb_fapl));
for i = 1 : length(memb_fapl)
   memb_fap(i) = H5ML.unwrap_ids(memb_fapl(i));
end
H5ML.hdf5lib2('H5Pset_fapl_multi', id, memb_map, memb_fap, memb_name, memb_addr, relax);            

