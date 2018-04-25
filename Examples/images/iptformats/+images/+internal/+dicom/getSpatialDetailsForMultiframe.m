function spatialDetails = getSpatialDetailsForMultiframe(metadataObj)

% Copyright 2016-2017 The MathWorks, Inc.

if isstruct(metadataObj)
    if isfield(metadataObj, 'PerFrameFunctionalGroupsSequence')
        metadataSequence = metadataObj.PerFrameFunctionalGroupsSequence;
    else
        spatialDetails = images.internal.dicom.makeDefaultSpatialDetails();
        return
    end
else
    metadataSequence = metadataObj.getAttributeByName('PerFrameFunctionalGroupsSequence');
end

if ~isempty(metadataSequence)
    itemNames = fieldnames(metadataSequence);
    numFrames = numel(itemNames);
    
    spatialDetails.PatientPositions = zeros(numFrames, 3);
    spatialDetails.PixelSpacings = zeros(numFrames, 2);
    spatialDetails.PatientOrientations = zeros(2, 3, numFrames);
    
    for idx = 1:numFrames
        thisItem = itemNames{idx};
        oneFrameDetails = metadataSequence.(thisItem);
        try
            position = oneFrameDetails.PlanePositionSequence.Item_1.ImagePositionPatient;
            spatialDetails.PatientPositions(idx, :) = position;
            
            spacing = oneFrameDetails.PixelMeasuresSequence.Item_1.PixelSpacing;
            spatialDetails.PixelSpacings(idx, :) = spacing;
            
            orientation = oneFrameDetails.PlaneOrientationSequence.Item_1.ImageOrientationPatient;
            spatialDetails.PatientOrientations(:, :, idx) = reshape(orientation, [3 2])';
        catch
            spatialDetails = images.internal.dicom.makeDefaultSpatialDetails();
            break
        end
    end
else
    spatialDetails = images.internal.dicom.makeDefaultSpatialDetails();
end

end
