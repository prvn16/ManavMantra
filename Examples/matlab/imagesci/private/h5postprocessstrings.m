function value = h5postprocessstrings(datatype, space, raw_value)
% Strings are read as multidimensional char arrays where the leading
% dimension's length is the HDF5 string length.  Process it such
% that the data becomes a cell array whose dimensions match the
% dataspace.

%   Copyright 2010-2013 The MathWorks, Inc.



if H5T.is_variable_str(datatype)
    
    % The string should already be in cell array form.  We're done.
    value = raw_value;
    
else

    space_type = H5S.get_simple_extent_type(space);
    switch(space_type)
        case H5ML.get_constant_value('H5S_SCALAR')
            % Scalar string, turn it into a readable char array.
            value = raw_value';
            
        case H5ML.get_constant_value('H5S_NULL')
            value = '';
            
        case H5ML.get_constant_value('H5S_SIMPLE')
            [ndims,h5_dims] = H5S.get_simple_extent_dims(space);
            dims = fliplr(h5_dims);
            
            % We have an N-dimensional string.  Turn it into a cell array of
            % rank N.
            if ndims == 1
                % Vector output will always be returned as a single column.
                value = cell(dims(1),1);
            else
                value = cell(dims);
            end
            
            % Each entry should be human-readable, hence the transpose
            % operation.
            for j = 1:numel(value)
                value{j} = raw_value(:,j)';
            end
    end
end



