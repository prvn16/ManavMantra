function cellstr = getString(hObj)
%GETSTRING   Returns the hdf5.h5enum data as the enumeration's
%   hdf5.h5enum.getString is not recommended.  Use h5read instead.
%
%   See also H5READ.

%   Copyright 1984-2013 The MathWorks, Inc.

origSize = size(hObj.Data);
cellstr = cell(origSize);

for i = 1:numel(hObj.Data)

    % This looks up a data value to find the corresponding string
    % key in the HDF5 enumeration.    
    cellstr{i} = hObj.EnumNames{find(hObj.Data(i) == hObj.EnumValues)};
end

% Sanity check that cellstr is indeed a cellstr
if (~iscellstr(cellstr))
    error(message('MATLAB:imagesci:deprecatedHDF5:badEnumData'));
end

