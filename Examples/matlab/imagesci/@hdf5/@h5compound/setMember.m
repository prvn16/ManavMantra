function setMember(hObj, memberName, data)
%hdf5.h5compound.setMember  Update a member's data.
%   hdf5.h5compound is not recommended.  Use H5T instead.
%
%   Example:
%       hobj = hdf5.h5compound('a','b','c');
%       hobj.setMember('a',0);
%       hobj.setMember('b',uint32(1));
%       hobj.setMember('c',int32(2));
%       hdf5write('myfile.h5','ds1',hobj);
%
%   See also H5T.

% Copyright 2003-2013 The MathWorks, Inc.

idx = strcmp(hObj.MemberNames, memberName);

if (~any(idx))
    error(message('MATLAB:imagesci:deprecatedHDF5:badName'))
end

if ((~isnumeric(data)) && (~isa(data, 'hdf5.hdf5type')))
    error(message('MATLAB:imagesci:deprecatedHDF5:badType'))
elseif (numel(data) > 1)
    error(message('MATLAB:imagesci:deprecatedHDF5:badSize'))
end

hObj.Data{idx} = data;
