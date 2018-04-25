function [hCamera, M1, hDataSpace, M2] = getSpatialTransforms(hObj)
%getSpatialTransforms Find spatial transformation information for an object
%
%  [hCamera, AboveMatrix, hDataSpace, BelowMatrix] =
%  getSpatialTransforms(hObj) returns the Camera handle, the model matrix
%  for transforms above the dataspace, the DataSpace handle and the model
%  matrix for transforms below the dataspace for the given object.

%  Copyright 2012-2016 The MathWorks, Inc.

M1 = eye(4);
M2 = eye(4);
CurrentlyBelowDS = true;
hDataSpace = [];
hCamera = [];
hContext = hObj;


% Start from the given object and walk up the tree, accumulating the model
% matrices and finding the camera and dataspace. We stop when we have found
% a camera, or run out of parents.
while ~isempty(hObj) && isempty(hCamera)
    if isa(hObj, 'matlab.graphics.primitive.Transform')
        if CurrentlyBelowDS
            % Accumulate transforms into the below-dataspace matrix
            M2 = hObj.Matrix * M2;
        else
            % Accumulate into the above=dataspace matrix;
            M1 = hObj.Matrix * M1;     
        end
    elseif isempty(hDataSpace) && isa(hObj, 'matlab.graphics.axis.dataspace.DataSpace')
        hDataSpace = hObj;
        CurrentlyBelowDS = false;
    elseif isa(hObj, 'matlab.graphics.axis.camera.Camera')
        hCamera = hObj;
    elseif isa(hObj, 'matlab.graphics.axis.AbstractAxes')
        if isempty(hDataSpace)
            hDataSpace = hObj.ActiveDataSpace;
        end
        if isempty(hCamera)
            hCamera = hObj.Camera;
        end
        CurrentlyBelowDS = false;
        
        % Get the right dataspace for the axis child. When the axes has
        % more that one datapace return the one that the child (hContext) is
        % associated with.
        if ~isa(hContext,'matlab.graphics.axis.AbstractAxes')
             newDataSpace = matlab.graphics.internal.plottools.getDataSpaceForChild(hContext);
             if ~isempty(newDataSpace)
                hDataSpace = newDataSpace;
             end
        end       
        if isa(hObj,'matlab.graphics.axis.PolarAxes')
            M2 = hObj.AngleUnitsTransform.Matrix * M2;
        end
    end
    if isprop(hObj,'NodeParent')
        hObj = hObj.NodeParent;
    else 
        %figure does not have a NodeParent property, so fall back to Parent        
        hObj = hObj.Parent;
    end
end
if ~isempty(hDataSpace)
    % Make sure the DataSpace properties and transforms are synchronized with 
    % the master rulers.
    updateTransforms(hDataSpace);
end
