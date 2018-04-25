function copy(varargin)
%H5O.copy  Copy object from source location to destination location.
%   H5O.copy(src_loc_id,src_name,dst_loc_id,dst_name,ocpypl_id,lcpl_id)
%   copies the group, dataset or named datatype specified by src_name
%   from the file or group specified by src_loc_id to the destination
%   location dst_loc_id.
%          
%   The destination location, as specified in dst_loc_id, may be a group
%   in the current file or a location in a different file. If dst_loc_id is
%   a file identifier, the copy will be placed in that file's root group.
%
%   The new copy will be created with the name dst_name. dst_name must
%   not pre-exist in the destination location. If dst_name already exists
%   at the location dst_loc_id, the operation will fail.
%
%   The new copy of the object is created with the object creation property
%   and link creation property lists ocpypl_id and lcpl_id respectively.
%
%   Example:  Copy the group '/g3' and all its datasets to a new group
%   '/g3.5'.
%       srcFile = [matlabroot '/toolbox/matlab/demos/example.h5'];
%       copyfile(srcFile,'myfile.h5');
%       fileattrib('myfile.h5','+w');
%       ocpl = H5P.create('H5P_OBJECT_COPY');
%       lcpl = H5P.create('H5P_LINK_CREATE');
%       H5P.set_create_intermediate_group(lcpl,true);
%       fid = H5F.open('myfile.h5','H5F_ACC_RDWR','H5P_DEFAULT');
%       gid = H5G.open(fid,'/');
%       H5O.copy(gid,'g3',gid,'g3.5',ocpl,lcpl);
%       H5G.close(gid);
%       H5P.close(ocpl);
%       H5P.close(lcpl);
%       H5F.close(fid);
%         
%   See also H5O.

%   Copyright 2009-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Ocopy', varargin{:});            
