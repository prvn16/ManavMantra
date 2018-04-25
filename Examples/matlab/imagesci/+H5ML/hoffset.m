function offset = hoffset(structure, fieldname)
%H5ML.hoffset Determine the offset of a field within a structure.
%
%   H5ML.hoffset is not recommended.  Use H5T instead.
%
%   This function is used to determine the offset (in bytes) of a structure
%   within a field.  It is used when constructing an HDF5 COMPOUND type.
%   It is designed to correspond to the HDF5 HOFFSET macro.  For more
%   details about the operation of the HOFFSET macro, please consult the
%   HDF5 documentation.
%
%   Function parameters:
%     offset: the bye offset of the field within the structure.
%     structure: the structure which contains the specified fieldname.
%     fieldname: the field for which the offset is determined.
%
%   This function is deprecated.  It can only be used in workflows that do
%   not include a field that is itself an HDF5 COMPOUND or of variable 
%   length.  To handle these cases, the offsets should be computed 
%   directly.  For example, in the case above, a file dataspace for such a
%   compound could be created with
%
%       dtype(1) = H5T.copy('H5T_NATIVE_INT');
%       dtype(2) = H5T.copy('H5T_NATIVE_DOUBLE');
%       dtype(3) = H5T.copy('H5T_NATIVE_FLOAT');
%
%       for j = 1:3, sz(j,1) = H5T.get_size(dtype(j)); end
%
%       % The first offset would always be zero and the size of the last 
%       % field does not matter.
%       offset(1) = 0;
%       offset(2:3) = cumsum(sz(1:2));
%
%       file_type = H5T.create('H5T_COMPOUND',sum(sz));
%
%       H5T.insert(file_type,'a', offset(1), dtype(1));
%       H5T.insert(file_type,'b', offset(2), dtype(2));
%       H5T.insert(file_type,'c', offset(3), dtype(3));
%
%   See also:  H5T.get_size
%    

%   Copyright 2006-2013 The MathWorks, Inc.

warning(message('MATLAB:imagesci:H5:hoffsetDeprecated'));

offset = 0;
fields = fieldnames(structure);
for i=1:length(fields)
    if strcmp(fieldname, fields{i})
        break
    end
    offset = offset + H5ML.sizeof(structure.(fields{i}));
end
