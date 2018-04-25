function data = h5postprocessenums(datatype,space,raw_data)
% Enumerated data is numeric, but each value is attached to a tag string,
% the 'Value'.  The output will be a cell array where each numeric value is
% replaced with the tag.

%   Copyright 2010-2013 The MathWorks, Inc.

[ndims,h5_dims] = H5S.get_simple_extent_dims(space);
dims = fliplr(h5_dims);

if ndims == 0
    % Null dataspace, just return the empty set.
    data = [];
    return;
elseif ndims == 1
    % The dataspace is one-dimensional.  Force the output to be a column.
    data = cell(dims(1),1);
else
    data = cell(dims);
end
nmemb = H5T.get_nmembers(datatype);

for j = 1:nmemb
    Name = H5T.get_member_name(datatype,j-1);
    enum_value = H5T.get_member_value(datatype,j-1);
    idx = find(raw_data == enum_value);
    
    %%% Can this be done more efficiently?
    for k = 1:numel(idx)
        data{idx(k)} = Name;
    end
end
