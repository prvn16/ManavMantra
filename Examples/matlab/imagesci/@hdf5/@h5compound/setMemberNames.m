function setMemberNames(hObj, varargin)
%SETMEMBERNAMES  Set the names of the compound object's members.
%   hdf5.setMemberNames is not recommended.  Use H5T instead.
%
%   See also H5T.

%   Copyright 1984-2013 The MathWorks, Inc.

if (~iscellstr(varargin))
    error(message('MATLAB:imagesci:deprecatedHDF5:badNameTypes'))
end

for p = 1:(nargin - 1)
    msg = getString(message('MATLAB:imagesci:deprecatedHDF5:adding',varargin{p}));
    disp(msg);
    hObj.addMember(varargin{p});
end
