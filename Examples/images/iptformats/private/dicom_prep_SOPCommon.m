function metadata = dicom_prep_SOPCommon(metadata, IOD_UID, dictionary)
%DICOM_PREP_DICOM_PREP_SOPCOMMON  Fill necessary values for Frame of Reference.
%
%   See PS 3.3 Sec. C.12.1

%   Copyright 1993-2010 The MathWorks, Inc.
%   

metadata.(dicom_name_lookup('0008', '0016', dictionary)) = IOD_UID;
metadata.(dicom_name_lookup('0008', '0018', dictionary)) = dicomuid;
