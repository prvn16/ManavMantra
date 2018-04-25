function metadata = dicom_prep_metadata(IOD_UID, metadata, X, map, txfr, useMetadataBitDepths, dictionary)
%DICOM_PREP_METADATA  Set the necessary metadata values for this IOD.
%   METADATA = DICOM_PREP_METADATA(UID, METADATA, X, MAP, TXFR) sets all
%   of the type 1 and type 2 metadata derivable from the image (e.g. bit
%   depths) or that must be unique (e.g. UIDs).  This function also
%   builds the image pixel data.

%   Copyright 1993-2014 The MathWorks, Inc.

switch (IOD_UID)
case '1.2.840.10008.5.1.4.1.1.2'
    metadata(1).(dicom_name_lookup('0008', '0060', dictionary)) = 'CT';

    metadata = dicom_prep_ImagePixel(metadata, X, map, txfr, useMetadataBitDepths, dictionary);
    metadata = dicom_prep_FrameOfReference(metadata, dictionary);
    metadata = dicom_prep_SOPCommon(metadata, IOD_UID, dictionary);
    metadata = dicom_prep_FileMetadata(metadata, IOD_UID, txfr, dictionary);
    metadata = dicom_prep_GeneralStudy(metadata, dictionary);
    metadata = dicom_prep_GeneralSeries(metadata, dictionary);
    metadata = dicom_prep_GeneralImage(metadata, dictionary);
    
case '1.2.840.10008.5.1.4.1.1.4'
    metadata(1).(dicom_name_lookup('0008', '0060', dictionary)) = 'MR';

    metadata = dicom_prep_ImagePixel(metadata, X, map, txfr, useMetadataBitDepths, dictionary);
    metadata = dicom_prep_FrameOfReference(metadata, dictionary);
    metadata = dicom_prep_SOPCommon(metadata, IOD_UID, dictionary);
    metadata = dicom_prep_FileMetadata(metadata, IOD_UID, txfr, dictionary);
    metadata = dicom_prep_GeneralStudy(metadata, dictionary);
    metadata = dicom_prep_GeneralSeries(metadata, dictionary);
    metadata = dicom_prep_GeneralImage(metadata, dictionary);
    
case '1.2.840.10008.5.1.4.1.1.4.1'
    metadata(1).(dicom_name_lookup('0008', '0060', dictionary)) = 'MR';

    metadata = dicom_prep_ImagePixel(metadata, X, map, txfr, useMetadataBitDepths, dictionary);
    metadata = dicom_prep_FrameOfReference(metadata, dictionary);
    metadata = dicom_prep_SOPCommon(metadata, IOD_UID, dictionary);
    metadata = dicom_prep_FileMetadata(metadata, IOD_UID, txfr, dictionary);
    metadata = dicom_prep_GeneralStudy(metadata, dictionary);
    metadata = dicom_prep_GeneralSeries(metadata, dictionary);
    metadata = dicom_prep_GeneralImage(metadata, dictionary);
    metadata = dicom_prep_MRMultiFrame(metadata, X, txfr, dictionary);
    
case '1.2.840.10008.5.1.4.1.1.7'
    name = dicom_name_lookup('0008', '0060', dictionary);
    if (~isfield(metadata, name))
        metadata(1).(name) = 'OT';
    end
    
    metadata = dicom_prep_ImagePixel(metadata, X, map, txfr, useMetadataBitDepths, dictionary);
    metadata = dicom_prep_FrameOfReference(metadata, dictionary);
    metadata = dicom_prep_SOPCommon(metadata, IOD_UID, dictionary);
    metadata = dicom_prep_FileMetadata(metadata, IOD_UID, txfr, dictionary);
    metadata = dicom_prep_GeneralStudy(metadata, dictionary);
    metadata = dicom_prep_GeneralSeries(metadata, dictionary);
    metadata = dicom_prep_GeneralImage(metadata, dictionary);
    metadata = dicom_prep_SCImageEquipment(metadata, dictionary);
    
case {'1.2.840.10008.5.1.4.1.1.7.1'
      '1.2.840.10008.5.1.4.1.1.7.2'
      '1.2.840.10008.5.1.4.1.1.7.3'
      '1.2.840.10008.5.1.4.1.1.7.4'}
    name = dicom_name_lookup('0008', '0060', dictionary);
    if (~isfield(metadata, name))
        metadata(1).(name) = 'OT';
    end
    
    metadata = dicom_prep_ImagePixel(metadata, X, map, txfr, useMetadataBitDepths, dictionary);
    metadata = dicom_prep_FrameOfReference(metadata, dictionary);
    metadata = dicom_prep_SOPCommon(metadata, IOD_UID, dictionary);
    metadata = dicom_prep_FileMetadata(metadata, IOD_UID, txfr, dictionary);
    metadata = dicom_prep_GeneralStudy(metadata, dictionary);
    metadata = dicom_prep_GeneralSeries(metadata, dictionary);
    metadata = dicom_prep_GeneralImage(metadata, dictionary);
    metadata = dicom_prep_SCImageEquipment(metadata, dictionary);
    
    % This needs to come last.
    metadata = dicom_prep_SCMultiFrame(metadata, X, dictionary);

    checkSC(IOD_UID, metadata, X, dictionary);
    
otherwise
    
    % Unsupported SOP Class in verification mode.  Display a message.
    if (usejava('Desktop') && desktop('-inuse'))
        docRef = '<a href="matlab:doc(''dicomwrite'')">help dicomwrite</a>';
    else
        docRef = 'help dicomwrite';
    end
                     
    error(message('images:dicom_prep_metadata:unsupportedClass', ...
                  IOD_UID, docRef))
    
end



function checkSC(IOD_UID, metadata, X, dictionary)
%checkSC  Make sure that the metadata matches what it should.

photometricInterp = metadata.(dicom_name_lookup('0028','0004', dictionary));

switch (IOD_UID)
case '1.2.840.10008.5.1.4.1.1.7.1'
  
    if (metadata.(dicom_name_lookup('0028', '0100', dictionary)) ~= 1)
        error(message('images:dicom_prep_metadata:bitDepthForLogicalSC', IOD_UID, 1))
     
    elseif (size(X,3) ~= 1)
        error(message('images:dicom_prep_metadata:numSamplesForLogicalSC', IOD_UID))
        
    elseif (~isequal(photometricInterp, 'MONOCHROME2'))
        error(message('images:dicom_prep_metadata:photoInterpForLogicalSC', IOD_UID))
        
    end
    
case '1.2.840.10008.5.1.4.1.1.7.2'
  
    if (metadata.(dicom_name_lookup('0028', '0100', dictionary)) ~= 8)
        error(message('images:dicom_prep_metadata:bitDepthFor8bitSC', IOD_UID, 8))
     
    elseif (size(X,3) ~= 1)
        error(message('images:dicom_prep_metadata:numSamplesFor8bitSC', IOD_UID))
        
    elseif (~isequal(photometricInterp, 'MONOCHROME2'))
        error(message('images:dicom_prep_metadata:photoInterpFor8bitSC', IOD_UID))
        
    end
    
case '1.2.840.10008.5.1.4.1.1.7.3'
  
    if (metadata.(dicom_name_lookup('0028', '0100', dictionary)) ~= 16)
        error(message('images:dicom_prep_metadata:bitDepthFor16bitSC', IOD_UID, 16))
     
    elseif (size(X,3) ~= 1)
        error(message('images:dicom_prep_metadata:numSamplesFor16bitSC', IOD_UID))
    
    elseif (~isequal(photometricInterp, 'MONOCHROME2'))
        error(message('images:dicom_prep_metadata:photoInterpFor16bitSC', IOD_UID))
        
    end
    
case '1.2.840.10008.5.1.4.1.1.7.4'
  
    if (metadata.(dicom_name_lookup('0028', '0100', dictionary)) ~= 8)
      
        error(message('images:dicom_prep_metadata:bitDepthForColorSC', IOD_UID, 8))
     
    elseif (size(X,3) ~= 3)
      
        error(message('images:dicom_prep_metadata:numSamplesForColorSC', IOD_UID))
    
    elseif (~isequal(photometricInterp, 'RGB') && ...
            ~isequal(photometricInterp, 'YBR_FULL_422'))
      
        error(message('images:dicom_prep_metadata:photoInterpForColorSC', IOD_UID))
        
    end
    
end
 
