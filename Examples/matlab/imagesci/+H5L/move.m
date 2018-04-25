function move(varargin)
%H5L.move  Rename link.
%   H5L.move(src_loc_id,src_name,dest_loc_id,dest_name,lcpl_id,lapl_id)
%   renames a link within an HDF5 file. The original link, src_name, is
%   removed from the group graph and the new link, dest_name, is inserted;
%   this change is accomplished as an atomic operation.
%             
%   src_loc_id and src_name identify the existing link. src_loc_id is
%   either a file or group identifier; src_name is the path to the link
%   and is interpreted relative to src_loc_id.
%                       
%   dest_loc_id and dest_name identify the new link. dest_loc_id is either
%   a file or group identifier; dest_name is the path to the link and is
%   interpreted relative to dest_loc_id.
%
%   lcpl_id and lapl_id are the link creation and link access property
%   lists, respectively, associated with the new link, dest_name.
%
%   Example:  Rename the '/g2' group to '/g2/g3'.
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.h5');
%       copyfile(srcFile,'myfile.h5');
%       fileattrib('myfile.h5','+w');
%       fid = H5F.open('myfile.h5','H5F_ACC_RDWR','H5P_DEFAULT');
%       g2id = H5G.open(fid,'g2');
%       H5L.move(fid,'g3',g2id,'g3','H5P_DEFAULT','H5P_DEFAULT');
%       H5G.close(g2id);
%       H5F.close(fid);
%
%   See also H5L, H5L.delete.

%   Copyright 2009-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Lmove', varargin{:});            
