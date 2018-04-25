function output = exists(loc_id,name,lapl_id)
%H5L.exists  Determine if link exists.
%   bool = H5L.exists(loc_id,name,lapl_id) checks if a link specified by
%   the pairing of an object id and name exists within a group. lapl_id is
%   a link access property list identifier.
%
%   Example:
%       fid = H5F.open('example.h5');
%       gid = H5G.open(fid,'/g1/g1.2/g1.2.1');
%       if H5L.exists(gid,'slink','H5P_DEFAULT')
%           fprintf('link exists\n');
%       else
%           fprintf('link does not exist\n');
%       end
%
%   See also H5L.

%   Copyright 2009-2013 The MathWorks, Inc.


output = H5ML.hdf5lib2('H5Lexists', loc_id, name, lapl_id);            

