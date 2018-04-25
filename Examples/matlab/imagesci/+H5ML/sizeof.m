function size = sizeof(arg)
%H5ML.sizeof Return the size (in bytes) of a variable as stored on disk.
%
%   H5ML.sizeof is not recommended.  Use H5T instead.
%
%   This function is used to determine the size (in bytes) of a structure
%   or other (simple) variable.  It is designed to correspond to the C
%   sizeof() operator as it is used during the creation of HDF5 datatypes,
%   especially the HDF5 COMPOUND type.
%
%   Function parameters:
%     size: the size (in bytes) of the variable as it would be stored on
%       disk
%     arg: the variable for which the size is being sought.
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

%   Copyright 2006-2013 The MathWorks, Inc.

warning(message('MATLAB:imagesci:H5:sizeofDeprecated'));

switch (class(arg))
    case {'int8' 'uint8' 'char'}
        size = 1;
    case {'int16' 'uint16'}
        size = 2;
    case {'int32' 'uint32' 'single'}
        size = 4;
    case {'int64' 'uint64' 'double'}
        size = 8;
    case {'struct'}
        size = 0;
        fields = fieldnames(arg);
        for i=1:length(fields)
            size = size+ H5ML.sizeof(arg.(fields{i}));
        end
    otherwise
        error(message('MATLAB:imagesci:H5:badtype',class(arg)));
end
