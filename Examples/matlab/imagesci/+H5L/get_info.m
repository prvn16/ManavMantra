function linkStruct = get_info(location_id,link_name,lapl_id)
%H5L.get_info  Return information about link.
%   linkStruct = H5L.get_info(location_id,link_name,lapl_id) returns
%   information about a link.
%
%   A file or group identifier, location_id, specifies the location of the
%   link. link_name, interpreted relative to link_id, specifies the link
%   being queried.
%
%   Example:
%       fid = H5F.open('example.h5');
%       info = H5L.get_info(fid,'g3','H5P_DEFAULT');
%       H5F.close(fid);
%
%   See also H5L.

%   Copyright 2009-2013 The MathWorks, Inc.

validateattributes(link_name,{'char'},{'row'});
location_name = H5I.get_name(location_id);
if ~strcmp(location_name,'/')
    % It is not the root group.  Do not allow a leading slash in the
    % link_name. 
    if link_name(1) == '/'
        error(message('MATLAB:imagesci:H5:notRelativeLinkName'));
    end
end

linkStruct = H5ML.hdf5lib2('H5Lget_info', location_id, link_name, lapl_id);            

