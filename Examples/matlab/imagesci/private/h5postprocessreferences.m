function dereferencedData = h5postprocessreferences(datasetId,dataspace,refData)
% Reference data is post processed by grabbing what's on the other side of
% the reference, so long as it is a dataset or a dataset region.

%   Copyright 2010-2013 The MathWorks, Inc.


dxpl = 'H5P_DEFAULT';

sz = size(refData);


if sz(1) == 8
    object_reference = true;
else
    object_reference = false;
end

[ndims,h5_dims] = H5S.get_simple_extent_dims(dataspace);
dims = fliplr(h5_dims);

switch(ndims)
    case 0
        dereferencedData = cell(1);
    case 1
        dereferencedData = cell(dims(1),1);
    otherwise
        dereferencedData = cell(dims);
end

% The leading dimension reflects the MATLAB length of a single reference.
for j = 1:numel(dereferencedData)
    
    % See if they are valid.
    if ~any(refData(:,j))
        error(message('MATLAB:imagesci:h5postprocessreferences:invalidReference'));
    end
    if object_reference
        
        % Object reference, hopefully a dataset.
        objId = H5R.dereference(datasetId,'H5R_OBJECT',refData(:,j));
        objType = H5R.get_obj_type (datasetId,'H5R_OBJECT', refData(:,j));
        
        if objType == H5ML.get_constant_value('H5G_DATASET')
            dspace = H5D.get_space(objId);
            [~,dims] =  H5S.get_simple_extent_dims(dspace);
            if isempty(dims)
                % dataspace is NULL, no elements
                dereferencedData{j} = [];
            else
                dereferencedData{j} = H5D.read(objId,'H5ML_DEFAULT','H5S_ALL','H5S_ALL',dxpl);
            end
            H5S.close(dspace);
        end
        
    else
        
        % region reference
        objId = H5R.dereference(datasetId,'H5R_DATASET_REGION',refData(:,j));
        space = H5R.get_region(datasetId,'H5R_DATASET_REGION',refData(:,j));
        
        npoints = H5S.get_select_npoints (space);
        memspace = H5S.create_simple (1,npoints,[]);
        dereferencedData{j} = H5D.read(objId,'H5ML_DEFAULT',memspace,space,dxpl);
        
    end
    dereferencedData{j} = squeeze(dereferencedData{j});
    
end


return
