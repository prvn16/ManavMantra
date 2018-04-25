function copy(varargin)
%H5L.copy  Copy link from source location to destination location.
%   H5L.copy(src_loc_id,src_name,dest_loc_id,dest_name,lcpl_id,lapl_id)
%   copies the link specified by src_name from the file or group specified
%   by src_loc_id to the destination dest_loc_id.  The new copy of the link
%   is created with the name dest_name. 
%
%   dest_loc_id must refer to either the current file or a group in the
%   current file. If dest_loc_id is the file identifier, the copy is placed
%   in the file's root group.  
% 
%   The new link is created with the creation and access property lists
%   specified by lcpl_id and lapl_id.  
%
%   Example:
%       plist_id = 'H5P_DEFAULT';
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',plist_id,plist_id);
%       g1 = H5G.create(fid,'g1',plist_id);
%       g2 = H5G.create(fid,'g2',plist_id);
%       g11 = H5G.create(g1,'g3',plist_id);
%       H5L.copy(g1,'g3',g2,'g4',plist_id,plist_id);
%
%   See also H5L.

%   Copyright 2009-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Lcopy', varargin{:});            
