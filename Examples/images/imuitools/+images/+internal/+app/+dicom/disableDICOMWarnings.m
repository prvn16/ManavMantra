function disableDICOMWarnings

% Copyright 2017 The MathWorks, Inc.

warning('off', 'images:dicom_decode_rle_segment:passedInputEnd')
warning('off', 'images:DICOMFile:duplicateAttributes')
warning('off', 'images:dicominfo:attrWithSameName')
warning('off', 'images:dicominfo:fileVRDoesNotMatchDictionary')
warning('off', 'images:dicominfo:unsupportedOverlay')
warning('off', 'images:dicomparse:oddLength')
warning('off', 'images:dicomparse:shortImport')
warning('off', 'images:dicomparse:suspiciousFile')
warning('off', 'images:dicomparse:vrHeuristic')
warning('off', 'images:dicomread:badNumberOfFrames')
warning('off', 'images:dicomread:multiframeOverlay')
warning('off', 'images:dicomread:overlaySizeMismatch')
warning('off', 'images:dicomread:repeatedAttribute')
warning('off', 'images:dicomread:tooMuchData')
warning('off', 'MATLAB:imagesci:jpg:libraryMessage')

end