function addMember(hObj, memberName, data)
%ADDMEMBER  Add a new member to a compound object.
%   h5compound.addMember is not recommended.  Use H5T instead. 
%
%   See also H5T.

%   Copyright 1984-2013 The MathWorks, Inc.

validateattributes(memberName,{'char'},{'row','nonempty'},'','MEMBERNAME');
if nargin == 2
	data = [];
end

if (any(strcmp(hObj.MemberNames, memberName)))
    error(message('MATLAB:imagesci:deprecatedHDF5:existingName', memberName));
end

hObj.MemberNames{end + 1} = memberName;
hObj.setMember(memberName, data);
