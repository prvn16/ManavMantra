function module_details = dicom_modules(module_name)
%DICOM_MODULES  Repository of DICOM module attributes and details.
%   DETAILS = DICOM_MODULES(NAME) returns a structure array of details
%   about the module NAME.  DETAILS is a structure with fields
%
%   - Name      The module's name.
%   - SpecPart  Where this module is defined in the DICOM spec.
%   - Attrs     The attributes that define a module.  A cell array with
%               the following meanings attributed to the columns:
%
%     (1) Depth in the module.  Nonzero indicates a sequence.
%     (2) Group
%     (3) Element
%     (4) Attribute type (see PS 3.3 Sec. 5.4)
%     (5) VR mapping
%     (6) Enumerated values.  If this is present, an attribute's value
%         must be one or more of the items in the cell array (or empty if
%         type 2 or 2C).
%     (7) LISP-like condition if type 1C or 2C.
%  
%   See also DICOM_IODS, dicom-dict.txt.

%   Copyright 1993-2010 The MathWorks, Inc.
%   

switch (module_name)
case 'FileMetadata'
    module_details = build_FileMetadata;
case 'Patient'
    module_details = build_Patient;
case 'GeneralStudy'
    module_details = build_GeneralStudy;
case 'PatientStudy'
    module_details = build_PatientStudy;
case 'GeneralSeries'
    module_details = build_GeneralSeries;
case 'FrameOfReference'
    module_details = build_FrameOfReference;
case 'GeneralEquipment'
    module_details = build_GeneralEquipment;
case 'GeneralImage'
    module_details = build_GeneralImage;
case 'ImagePlane'
    module_details = build_ImagePlane;
case 'ImagePixel'
    module_details = build_ImagePixel;
case 'ContrastBolus'
    module_details = build_ContrastBolus;
case 'MRImage'
    module_details = build_MRImage;
case 'CTImage'
    module_details = build_CTImage;
case 'OverlayPlane'
    module_details = build_OverlayPlane;
case 'VOILUT'
    module_details = build_VOILUT;
case 'SOPCommon'
    module_details = build_SOPCommon;
case 'SCImageEquipment'
    module_details = build_SCImageEquipment;
case 'SCImage'
    module_details = build_SCImage;
case 'USFrameOfReference'
    module_details = build_USFrameOfReference;
case 'PaletteColorLookupTable'
    module_details = build_PaletteColorLookupTable;
case 'USRegionCalibration'
    module_details = build_USRegionCalibration;
case 'USImage'
    module_details = build_USImage;
case 'Cine'
    module_details = build_Cine;
case 'MultiFrame'
    module_details = build_MultiFrame;
case 'ModalityLUT'
    module_details = build_ModalityLUT;
case 'FramePointers'
    module_details = build_FramePointers;
case 'Mask'
    module_details = build_Mask;
case 'DisplayShutter'
    module_details = build_DisplayShutter;
case 'Device'
    module_details = build_Device;
case 'Therapy'
    module_details = build_Therapy;
case 'XRayImage'
    module_details = build_XRayImage;
case 'XRayAcquisition'
    module_details = build_XRayAcquisition;
case 'XRayCollimator'
    module_details = build_XRayCollimator;
case 'XRayTable'
    module_details = build_XRayTable;
case 'XAPositioner'
    module_details = build_XAPositioner;
case 'MultiFrameOverlay'
    module_details = build_MultiFrameOverlay;
case 'Curve'
    module_details = build_Curve;
case 'SCMultiFrameImage'
    module_details = build_SCMultiFrameImage;
case 'SCMultiFrameVector'
    module_details = build_SCMultiFrameVector;
case 'MRSeries'
    module_details = build_MRSeries;
case 'Synchronization'
    module_details = build_Synchronization;
case 'EnhancedGeneralEquipment'
    module_details = build_EnhancedGeneralEquipment;
case 'ClinicalTrialSeries'
    module_details = build_ClinicalTrialSeries;
case 'ClinicalTrialStudy'
    module_details = build_ClinicalTrialStudy;
case 'ClinicalTrialSubject'
    module_details = build_ClinicalTrialSubject;
case 'EnhancedContrastBolus'
    module_details = build_EnhancedContrastBolus;
case 'MultiFrameDimension'
    module_details = build_MultiFrameDimension;
case 'CardiacSynchronization'
    module_details = build_CardiacSynchronization;
case 'RespiratorySynchronization'
    module_details = build_RespiratorySynchronization;
case 'BulkMotionSynchronization'
    module_details = build_BulkMotionSynchronization;
case 'SupplementalPaletteColorLUT'
    module_details = build_SupplementalPaletteColorLUT;
case 'AcquisitionContext'
    module_details = build_AcquisitionContext;
case 'MultiFrameFunctionalGroups'
    module_details = build_MultiFrameFunctionalGroups;
case 'Specimen'
    module_details = build_Specimen;
case 'MRPulseSequence'
    module_details = build_MRPulseSequence;
case 'EnhancedMRImage'
    module_details = build_EnhancedMRImage;
case ''
    module_details = build_;
otherwise
    module_details = [];
end



function details = build_FileMetadata

details.Name = 'FileMetadata';
details.SpecPart = 'PS 3.10 Sec. 7.1';
details.Attrs = {
        0, '0002', '0001', '1',  {}, {uint8([0 1])}, {}
        0, '0002', '0002', '1',  {}, {}, {}
        0, '0002', '0003', '1',  {}, {}, {}
        0, '0002', '0010', '1',  {}, {}, {}
        0, '0002', '0012', '1',  {}, {}, {}
        0, '0002', '0013', '3',  {}, {}, {}
        0, '0002', '0016', '3',  {}, {}, {}
        0, '0002', '0100', '3',  {}, {}, {}
        0, '0002', '0102', '1C', {}, {}, {'present', '(0002,0100)'}
        };


function details = build_Patient

details.Name = 'Patient';
details.SpecPart = 'PS 3.3 Sec. C.7.1.1';
details.Attrs = {
        0, '0010', '0010', '2',  {}, {}, {}
        0, '0010', '0020', '2',  {}, {}, {}
        0, '0010', '0030', '2',  {}, {}, {}
        0, '0010', '0040', '2',  {}, {'M' 'F' '0'}, {}
        0, '0008', '1120', '3',  {}, {}, {}
        1, '0008', '1150', '1C', {}, {}, {'present', '(0008,1120)'}
        1, '0008', '1155', '1C', {}, {}, {'present', '(0008,1120)'}
        0, '0010', '0032', '3',  {}, {}, {}
        0, '0010', '1000', '3',  {}, {}, {}
        0, '0010', '1001', '3',  {}, {}, {}
        0, '0010', '2160', '3',  {}, {}, {}
        0, '0010', '4000', '3',  {}, {}, {}
        };
       

function details = build_GeneralStudy

details.Name = 'GeneralStudy';
details.SpecPart = 'PS 3.3 Sec. C.7.2.1';
details.Attrs = {
        0, '0020', '000D', '1',  {}, {}, {}
        0, '0008', '0020', '2',  {}, {}, {}
        0, '0008', '0030', '2',  {}, {}, {}
        0, '0008', '0090', '2',  {}, {}, {}
        0, '0020', '0010', '2',  {}, {}, {}
        0, '0008', '0050', '2',  {}, {}, {}
        0, '0008', '1030', '3',  {}, {}, {}
        0, '0008', '1048', '3',  {}, {}, {}
        0, '0008', '1060', '3',  {}, {}, {}
        0, '0008', '1110', '3',  {}, {}, {}
        1, '0008', '1150', '1C', {}, {}, {'present', '(0008,1110)'}
        1, '0008', '1155', '1C', {}, {}, {'present', '(0008,1110)'}
        0, '0008', '1032', '3',  {}, {}, {}
        1, 'code', 'sequ', 'X',  {}, {}, {}  % This is a placeholder.    
%        0, % Code sequence macro "No baseline context."
        };


function details = build_PatientStudy

details.Name = 'PatientStudy';
details.SpecPart = 'PS 3.3 Sec. C.7.2.2';
details.Attrs = {
        0, '0008', '1080', '3',  {}, {}, {}
        0, '0010', '1010', '3',  {}, {}, {}
        0, '0010', '1020', '3',  {}, {}, {}
        0, '0010', '1030', '3',  {}, {}, {}
        0, '0010', '2180', '3',  {}, {}, {}
        0, '0010', '21B0', '3',  {}, {}, {}
        };


function details = build_GeneralSeries

details.Name = 'GeneralSeries';
details.SpecPart = 'PS 3.3 Sec. C.7.3.1';
details.Attrs = {
        0, '0008', '0060', '1',  {}, modalityTerms, {}
        0, '0020', '000E', '1',  {}, {}, {}
        0, '0020', '0011', '2',  {}, {}, {}
        0, '0020', '0060', '2C', {}, {'L', 'R'}, {'and', ...
                 {'not', {'present', '(0020,0062)'}}, ...
                 {'present', '(0020,0060)'}}
        0, '0008', '0021', '3',  {}, {}, {}
        0, '0008', '0031', '3',  {}, {}, {}
        0, '0008', '1050', '3',  {}, {}, {}
        0, '0018', '1030', '3',  {}, {}, {}
        0, '0008', '103E', '3',  {}, {}, {}
        0, '0008', '1070', '3',  {}, {}, {}
        0, '0008', '1111', '3',  {}, {}, {}
        1, '0008', '1150', '1C', {}, {}, {'present', '(0008,1111)'}
        1, '0008', '1155', '1C', {}, {}, {'present', '(0008,1111)'}
        0, '0018', '0015', '3',  {}, bodyPartTerms, {}
        0, '0018', '5100', '2C', {}, patientPositionTerms, {'or', ...
                 {'equal', '(0008,0016)', '1.2.840.10008.5.1.4.1.1.4'} ...
                 {'equal', '(0008,0016)', '1.2.840.10008.5.1.4.1.1.2'}}
        0, '0028', '0108', '3',  {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, {}
        0, '0028', '0109', '3',  {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, {}
        0, '0040', '0275', '3',  {}, {}, {}
        1, '0040', '1001', '1C', {}, {}, {'present', '(0040,0275)'}
        1, '0040', '0009', '1C', {}, {}, {'present', '(0040,0275)'}
        1, '0040', '0007', '3',  {}, {}, {}
        1, '0040', '0008', '3',  {}, {}, {}
%        1, % Code sequence macro "No baseline context."
        0, '0040', '0253', '3',  {}, {}, {}
        0, '0040', '0244', '3',  {}, {}, {}
        0, '0040', '0245', '3',  {}, {}, {}
        0, '0040', '0254', '3',  {}, {}, {}
        0, '0040', '0260', '3',  {}, {}, {}
        1, 'code', 'sequ', 'X',  {}, {}, {}  % This is a placeholder.    
%        0, % Code sequence macro "No baseline context."
        };


function details = build_FrameOfReference

details.Name = 'FrameOfReference';
details.SpecPart = 'PS 3.3 Sec. C.7.4.1';
details.Attrs = {
        0, '0020', '0052', '1',  {}, {}, {}
        0, '0020', '1040', '2',  {}, {}, {}
        };


function details = build_GeneralEquipment

details.Name = 'GeneralEquipment';
details.SpecPart = 'PS 3.3 Sec. C.7.5.1';
details.Attrs = {
        0, '0008', '0070', '2',  {}, {}, {}
        0, '0008', '0080', '3',  {}, {}, {}
        0, '0008', '0081', '3',  {}, {}, {}
        0, '0008', '1010', '3',  {}, {}, {}
        0, '0008', '1040', '3',  {}, {}, {}
        0, '0008', '1090', '3',  {}, {}, {}
        0, '0018', '1000', '3',  {}, {}, {}
        0, '0018', '1020', '3',  {}, {}, {}
        0, '0018', '1050', '3',  {}, {}, {}
        0, '0018', '1200', '3',  {}, {}, {}
        0, '0018', '1201', '3',  {}, {}, {}
        0, '0028', '0120', '3',  {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, {}
        };


function details = build_GeneralImage

details.Name = 'GeneralImage';
details.SpecPart = 'PS 3.3 Sec. C.7.6.1';
details.Attrs = {
        0, '0020', '0013', '2',  {}, {}, {}
        0, '0020', '0020', '2C', {}, {}, {'or', {'not', {'present', '(0020,0037)'}} ...
                                            {'not', {'present', '(0020,0032)'}}}
        0, '0008', '0023', '2C', {}, {}, {'true'}
        0, '0008', '0033', '2C', {}, {}, {'true'}
        0, '0008', '0008', '3',  {}, {}, {}
        0, '0020', '0012', '3',  {}, {}, {}
        0, '0008', '0022', '3',  {}, {}, {}
        0, '0008', '0032', '3',  {}, {}, {}
        0, '0008', '002A', '3',  {}, {}, {}
        0, '0008', '1140', '3',  {}, {}, {}
        1, '0008', '1150', '1C', {}, {}, {'present', '(0008,1140)'}
        1, '0008', '1155', '1C', {}, {}, {'present', '(0008,1140)'}
        1, '0008', '1160', '3',  {}, {}, {}
        0, '0008', '2111', '3',  {}, {}, {}
        0, '0008', '2112', '3',  {}, {}, {}
        1, '0008', '1150', '1C', {}, {}, {'present', '(0008,2112)'}
        1, '0008', '1155', '1C', {}, {}, {'present', '(0008,2112)'}
        1, '0008', '1160', '3',  {}, {}, {}
        0, '0020', '1002', '3',  {}, {}, {}
        0, '0020', '4000', '3',  {}, {}, {}
        0, '0028', '0300', '3',  {}, {'YES' 'NO'}, {}
        0, '0028', '0301', '3',  {}, {'YES' 'NO'}, {}
        0, '0028', '2110', '3',  {}, {0 1}, {}
        0, '0028', '2112', '3',  {}, {}, {}
        };


function details = build_ImagePlane

details.Name = 'ImagePlane';
details.SpecPart = 'PS 3.3 Sec. C.7.6.2';
details.Attrs = {
        0, '0028', '0030', '1',  {}, {}, {}
        0, '0020', '0037', '1',  {}, {}, {}
        0, '0020', '0032', '1',  {}, {}, {}
        0, '0018', '0050', '2',  {}, {}, {}
        0, '0020', '1041', '3',  {}, {}, {}
        };


function details = build_ImagePixel

details.Name = 'ImagePixel';
details.SpecPart = 'PS 3.3 Sec. C.7.6.3';
details.Attrs = {
        0, '0028', '0002', '1',  {}, {}, {}
        0, '0028', '0004', '1',  {}, {}, {}
        0, '0028', '0010', '1',  {}, {}, {}
        0, '0028', '0011', '1',  {}, {}, {}
        0, '0028', '0100', '1',  {}, {}, {}
        0, '0028', '0101', '1',  {}, {}, {}
        0, '0028', '0102', '1',  {}, {}, {}
        0, '0028', '0103', '1',  {}, {0 1}, {}
        0, '7FE0', '0010', '1',  {}, {}, {}
        0, '0028', '0006', '1C', {}, {}, {'not', {'equal', '(0028,0002)', 1}}
        0, '0028', '0034', '1C', {}, {}, {'present', '(0028,0034)'}
        0, '0028', '0106', '3',  {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, {}
        0, '0028', '0107', '3',  {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, {}
        0, '0028', '1101', '1C', {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, ...
                 {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        0, '0028', '1102', '1C', {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, ...
                 {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        0, '0028', '1103', '1C', {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, ...
                 {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        0, '0028', '1201', '1C', {}, {}, {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        0, '0028', '1202', '1C', {}, {}, {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        0, '0028', '1203', '1C', {}, {}, {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        0, '0028', '2000', '3',  {}, {}, {}
        0, '0028', '0008', '1C', {}, {}, {'present', '(0028,0008)'}
        0, '0028', '0009', '1C', {}, {}, {'present', '(0028,0009)'}
        0, '0028', '7FE0', '1C', {}, {}, {'present', '(0028,7FE0)'}
        0, '0028', '0121', '1C', {}, {}, {'present', '(0028,0121)'}
        };


function details = build_ContrastBolus

details.Name = 'ContrastBolus';
details.SpecPart = 'PS 3.3 Sec. C.7.6.4';
details.Attrs = {
        0, '0018', '0010', '2',  {}, {}, {}
        0, '0018', '0012', '3',  {}, {}, {}
        1, 'code', 'sequ', 'X',  {}, {}, {}  % This is a placeholder.    
%        1, % Code sequence macro "Baseline context id is 12"
        0, '0018', '1040', '3',  {}, {}, {}
        0, '0018', '0014', '3',  {}, {}, {}
%        1, % Code sequence macro "Baseline context id is 11"
        1, '0018', '002A', '3',  {}, {}, {}
%        2, % Code sequence macro "No baseline context."
        0, '0018', '1041', '3',  {}, {}, {}
        0, '0018', '1042', '3',  {}, {}, {}
        0, '0018', '1043', '3',  {}, {}, {}
        0, '0018', '1044', '3',  {}, {}, {}
        0, '0018', '1046', '3',  {}, {}, {}
        0, '0018', '1047', '3',  {}, {}, {}
        0, '0018', '1048', '3',  {}, {'IODINE'
                                  'GADOLINIUM'
                                  'CARBON DIOXIDE'
                                  'BARIUM'}, {}
        0, '0018', '1049', '3',  {}, {}, {}
        };


function details = build_MRImage

details.Name = 'MRImage';
details.SpecPart = 'PS 3.3 Sec. C.8.3.1';
details.Attrs = {
        0, '0008', '0008', '1',  {}, {}, {}
        0, '0028', '0002', '1',  {}, {1}, {}
        0, '0028', '0004', '1',  {}, {'MONOCHROME1' 'MONOCHROME2'}, {}
        0, '0028', '0100', '1',  {}, {16}, {}
        0, '0018', '0020', '1',  {}, {'SE' 'IR' 'GR' 'EP' 'RM'}, {}
        0, '0018', '0021', '1',  {}, {'SK' 'MTC' 'SS' 'TRSS' 'SP' ...
                                  'MP' 'OSP' 'NONE'}, {}
        0, '0018', '0022', '1',  {}, {'PER' 'RG' 'CG' 'PPG' 'FC' ...
                                  'PFF' 'PFP' 'SP' 'FS' 'CT'}, {}
        0, '0018', '0023', '1',  {}, {'2D' '3D'}, {}
        0, '0018', '0080', '2C', {}, {}, {'not', ...
                                          {'and', ...
                                           {'equal', '(0018,0020)', 'EP'}, ...
                                           {'equal', '(0018,0021)', 'SK'}}}
        0, '0018', '0081', '2',  {}, {}, {}
        0, '0018', '0091', '2',  {}, {}, {}
        0, '0018', '0082', '2C', {}, {}, {'or', ...
                                          {'equal', '(0018,0020)', 'IR'}, ...
                                          {'present', '(0018,0082)'}}
        0, '0018', '1060', '2C', {}, {}, {'or', ...
                                          {'present', '(0018,1060)'}, ...
                                          {'or', ...
                                           {'equal', '(0018,0022)', 'RG'}, ...
                                           {'equal', '(0018,0022)', 'CG'}, ...
                                           {'equal', '(0018,0022)', 'CT'}, ...
                                           {'equal', '(0018,0022)', 'PPG'}}}
        0, '0018', '0024', '3',  {}, {}, {}
        0, '0018', '0025', '3',  {}, {'Y' 'N'}, {}
        0, '0018', '0083', '3',  {}, {}, {}
        0, '0018', '0084', '3',  {}, {}, {}
        0, '0018', '0085', '3',  {}, {}, {}
        0, '0018', '0086', '3',  {}, {}, {}
        0, '0018', '0087', '3',  {}, {}, {}
        0, '0018', '0088', '3',  {}, {}, {}
        0, '0018', '0089', '3',  {}, {}, {}
        0, '0018', '0093', '3',  {}, {}, {}
        0, '0018', '0094', '3',  {}, {}, {}
        0, '0018', '0095', '3',  {}, {}, {}
        0, '0018', '1062', '3',  {}, {}, {}
        0, '0018', '1080', '3',  {}, {'Y' 'N'}, {}
        0, '0018', '1081', '3',  {}, {}, {}
        0, '0018', '1082', '3',  {}, {}, {}
        0, '0018', '1083', '3',  {}, {}, {}
        0, '0018', '1084', '3',  {}, {}, {}
        0, '0018', '1085', '3',  {}, {}, {}
        0, '0018', '1086', '3',  {}, {}, {}
        0, '0018', '1088', '3',  {}, {}, {}
        0, '0018', '1090', '3',  {}, {}, {}
        0, '0018', '1094', '3',  {}, {}, {}
        0, '0018', '1100', '3',  {}, {}, {}
        0, '0018', '1250', '3',  {}, {}, {}
        0, '0018', '1251', '3',  {}, {}, {}
        0, '0018', '1310', '3',  {}, {}, {}
        0, '0018', '1312', '3',  {}, {}, {}
        0, '0018', '1314', '3',  {}, {}, {}
        0, '0018', '1316', '3',  {}, {}, {}
        0, '0018', '1315', '3',  {}, {'Y' 'N'}, {}
        0, '0018', '1318', '3',  {}, {}, {}
        0, '0020', '0100', '3',  {}, {}, {}
        0, '0020', '0105', '3',  {}, {}, {}
        0, '0020', '0110', '3',  {}, {}, {}
        };



function details = build_OverlayPlane

details.Name = 'OverlayPlane';
details.SpecPart = 'PS 3.3 Sec. C.9.2';
details.Attrs = {
        0, '60XX', '0010', '1',  {}, {}, {}
        0, '60XX', '0011', '1',  {}, {}, {}
        0, '60XX', '0040', '1',  {}, {'G' 'R'}, {}
        0, '60XX', '0050', '1',  {}, {}, {}
        0, '60XX', '0100', '1',  {}, {1}, {}
        0, '60XX', '0102', '1',  {}, {0}, {}
        0, '60XX', '3000', '1C', {}, {}, {'equal', '(60XX,0100)', 1}
        0, '60XX', '0022', '3',  {}, {}, {}
        0, '60XX', '0045', '3',  {}, {'USER' 'AUTOMATED'}, {}
        0, '60XX', '1500', '3',  {}, {}, {}
        0, '60XX', '1301', '3',  {}, {}, {}
        0, '60XX', '1302', '3',  {}, {}, {}
        0, '60XX', '1303', '3',  {}, {}, {}
        };


function details = build_VOILUT

details.Name = 'VOILUT';
details.SpecPart = 'PS 3.3 Sec. C.11.2';
details.Attrs = {
        0, '0028', '3010', '3',  {}, {}, {}
        1, '0028', '3002', '1C', {}, {}, {'present', '(0028,3010)'}
        1, '0028', '3003', '3',  {}, {}, {}
        1, '0028', '3006', '1C', {}, {}, {'present', '(0028,3010)'}
        0, '0028', '1050', '3',  {}, {}, {}
        0, '0028', '1051', '1C', {}, {}, {'present', '(0028,1050)'}
        };


function details = build_SOPCommon

details.Name = 'SOPCommon';
details.SpecPart = 'PS 3.3 Sec. C.12.1';
details.Attrs = {
        0, '0008', '0016', '1',  {}, {}, {}
        0, '0008', '0018', '1',  {}, {}, {}
        0, '0008', '0005', '1C', {}, {}, {'present', '(0008,0005)'}
        0, '0008', '0012', '3',  {}, {}, {}
        0, '0008', '0013', '3',  {}, {}, {}
        0, '0008', '0014', '3',  {}, {}, {}
        0, '0008', '0201', '3',  {}, {}, {}
        0, '0020', '0013', '3',  {}, {}, {}
        0, '0100', '0410', '3',  {}, {'NS' 'OR' 'AO' 'AC'}, {}
        0, '0100', '0420', '3',  {}, {}, {}
        0, '0100', '0424', '3',  {}, {}, {}
        0, '0100', '0426', '3',  {}, {}, {}
        };


function details = build_CTImage

details.Name = 'CTImage';
details.SpecPart = 'PS 3.3 Sec. C.8.2.1';
details.Attrs = {
        0, '0008', '0008', '1',  {}, {}, {}
        0, '0028', '0002', '1',  {}, {1}, {}
        0, '0028', '0004', '1',  {}, {'MONOCHROME1' 'MONOCHROME2'}, {}
        0, '0028', '0100', '1',  {}, {16}, {}
        0, '0028', '0101', '1',  {}, {16}, {}
        0, '0028', '0102', '1',  {}, {15}, {}
        0, '0028', '1052', '1',  {}, {}, {}
        0, '0028', '1053', '1',  {}, {}, {}
        0, '0018', '0060', '2',  {}, {}, {}
        0, '0020', '0012', '2',  {}, {}, {}
        0, '0018', '0022', '3',  {}, {}, {}
        0, '0018', '0090', '3',  {}, {}, {}
        0, '0018', '1100', '3',  {}, {}, {}
        0, '0018', '1110', '3',  {}, {}, {}
        0, '0018', '1111', '3',  {}, {}, {}
        0, '0018', '1120', '3',  {}, {}, {}
        0, '0018', '1130', '3',  {}, {}, {}
        0, '0018', '1140', '3',  {}, {'CW', 'CC'}, {}
        0, '0018', '1150', '3',  {}, {}, {}
        0, '0018', '1151', '3',  {}, {}, {}
        0, '0018', '1152', '3',  {}, {}, {}
        0, '0018', '1153', '3',  {}, {}, {}
        0, '0018', '1160', '3',  {}, {}, {}
        0, '0018', '1170', '3',  {}, {}, {}
        0, '0018', '1190', '3',  {}, {}, {}
        0, '0018', '1210', '3',  {}, {}, {}
        };



function details = build_SCImageEquipment

details.Name = 'SCImageEquipment';
details.SpecPart = 'PS 3.3 Sec. C.8.6.1';
details.Attrs = {
        0, '0008', '0064', '1',  {}, conversionTerms, {}
        0, '0008', '0060', '3',  {}, modalityTerms, {}
        0, '0018', '1010', '3',  {}, {}, {}
        0, '0018', '1016', '3',  {}, {}, {}
        0, '0018', '1018', '3',  {}, {}, {}
        0, '0018', '1019', '3',  {}, {}, {}
        0, '0018', '1022', '3',  {}, {}, {}
        0, '0018', '1023', '3',  {}, {}, {}
        };



function details = build_SCImage

details.Name = 'SCImage';
details.SpecPart = 'PS 3.3 Sec. C.8.6.2';
details.Attrs = {
        0, '0018', '1012', '3',  {}, {}, {}
        0, '0018', '1014', '3',  {}, {}, {}
        };


function details = build_USFrameOfReference

details.Name = 'USFrameOfReference';
details.SpecPart = 'PS 3.3 Sec. C.8.5.4';
details.Attrs = {
        0, '0018', '6018', '1',  {}, {}, {}
        0, '0018', '601A', '1',  {}, {}, {}
        0, '0018', '601C', '1',  {}, {}, {}
        0, '0018', '601E', '1',  {}, {}, {}
        0, '0018', '6024', '1',  {}, {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, ...
                    11, 12}, {}
        0, '0018', '6026', '1',  {}, {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, ...
                    11, 12}, {}
        0, '0018', '602C', '1',  {}, {}, {}
        0, '0018', '602E', '1',  {}, {}, {}
        0, '0018', '6020', '3',  {}, {}, {}
        0, '0018', '6022', '3',  {}, {}, {}
        0, '0018', '6028', '3',  {}, {}, {}
        0, '0018', '602A', '3',  {}, {}, {}
        };



function details = build_PaletteColorLookupTable

details.Name = 'PaletteColorLookupTable';
details.SpecPart = 'PS 3.3 Sec. C.7.9';
details.Attrs = {
        0, '0028', '1101', '1C', {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, ...
                 {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        0, '0028', '1102', '1C', {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, ...
                 {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        0, '0028', '1103', '1C', {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, ...
                 {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        0, '0028', '1199', '3',  {}, {}, {}
        0, '0028', '1201', '1C', {}, {}, {'and', ...
                 {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}, ...
                 {'not', {'present', '(0028,1221)'}}}
        0, '0028', '1202', '1C', {}, {}, {'and', ...
                 {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}, ...
                 {'not', {'present', '(0028,1221)'}}}
        0, '0028', '1203', '1C', {}, {}, {'and', ...
                 {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}, ...
                 {'not', {'present', '(0028,1221)'}}}
        0, '0028', '1221', '1C', {}, {}, {'and', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'}, ...
                    {'present', '(0028,1221)'}}
        0, '0028', '1222', '1C', {}, {}, {'and', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'}, ...
                    {'present', '(0028,1222)'}}
        0, '0028', '1223', '1C', {}, {}, {'and', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'}, ...
                    {'present', '(0028,1223)'}}
        };



function details = build_USRegionCalibration

details.Name = 'USRegionCalibration';
details.SpecPart = 'PS 3.3 Sec. C.8.5.5';
details.Attrs = {
        0, '0018', '6011', '1',  {}, {}, {}
        1, '0018', '6018', '1',  {}, {}, {}
        1, '0018', '601A', '1',  {}, {}, {}
        1, '0018', '601C', '1',  {}, {}, {}
        1, '0018', '601E', '1',  {}, {}, {}
        1, '0018', '6024', '1',  {}, {0 1 2 3 4 5 6 7 8 9 10 11 12}, {}
        1, '0018', '6026', '1',  {}, {0 1 2 3 4 5 6 7 8 9 10 11 12}, {}
        1, '0018', '602C', '1',  {}, {}, {}
        1, '0018', '602E', '1',  {}, {}, {}
        1, '0018', '6020', '3',  {}, {}, {}
        1, '0018', '6022', '3',  {}, {}, {}
        1, '0018', '6028', '3',  {}, {}, {}
        1, '0018', '602A', '3',  {}, {}, {}
        1, '0018', '6012', '1',  {}, {0 1 2 3 4 5}, {}
        1, '0018', '6014', '1',  {}, {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 ...
                                      15 16 17 18}, {}
        1, '0018', '6016', '1',  {}, {}, {}
        1, '0018', '6044', '1C', {}, {0 1 2}, {'present', '(0018,6044)'}
        1, '0018', '6046', '1C', {}, {}, {'equal', '(0018,6044)', 0}
        1, '0018', '6048', '1C', {}, {}, {'equal', '(0018,6044)', 1}
        1, '0018', '604A', '1C', {}, {}, {'equal', '(0018,6044)', 1}
        1, '0018', '604C', '1C', {}, {0 1 2 3 4 5 6 7 8 9 10 11 12}, ...
                    {'present', '(0018,6044)'}
        1, '0018', '604E', '1C', {}, {0 1 2 3 4 5 6 7 8 9}, ...
                    {'present', '(0018,6044)'}
        1, '0018', '6050', '1C', {}, {}, {'or', ...
                    {'equal', '(0018,6044)', 0}, ...
                    {'equal', '(0018,6044)', 1}}
        1, '0018', '6052', '1C', {}, {}, {'or', ...
                    {'equal', '(0018,6044)', 0}, ...
                    {'equal', '(0018,6044)', 1}}
        1, '0018', '6054', '1C', {}, {}, {'or', ...
                    {'equal', '(0018,6044)', 0}, ...
                    {'equal', '(0018,6044)', 1}}
        1, '0018', '6056', '1C', {}, {}, {'equal', '(0018,6044)', 2}
        1, '0018', '6058', '1C', {}, {}, {'equal', '(0018,6044)', 2}
        1, '0018', '605A', '1C', {}, {}, {'equal', '(0018,6044)', 2}
        1, '0018', '6030', '3',  {}, {}, {}
        1, '0018', '6032', '3',  {}, {}, {}
        1, '0018', '6034', '3',  {}, {}, {}
        1, '0018', '6036', '3',  {}, {}, {}
        1, '0018', '6038', '3',  {}, {}, {}
        1, '0018', '603A', '3',  {}, {}, {}
        1, '0018', '603C', '3',  {}, {}, {}
        1, '0018', '603E', '3',  {}, {}, {}
        1, '0018', '6040', '3',  {}, {}, {}
        1, '0018', '6042', '3',  {}, {}, {}
        };

        
        
function details = build_USImage

details.Name = 'USImage';
details.SpecPart = 'PS 3.3 Sec. C.8.5.6';
details.Attrs = {
        0, '0028', '0002', '1',  {}, {1 3}, {}
        0, '0028', '0004', '1',  {}, {'MONOCHROME2' 'PALETTE COLOR' 'RGB' ...
                    'YBR_FULL' 'YBR_FULL_422' 'YBR_PARTIAL_422'}, {}
        0, '0028', '0100', '1',  {}, {8 16}, {}
        0, '0028', '0101', '1',  {}, {8 16}, {}
        0, '0028', '0102', '1',  {}, {7 15}, {}
        0, '0028', '0006', '1C', {}, {0 1}, {'not', ...
                    {'equal', '(0028,0002)', 1}}
        0, '0028', '0103', '1',  {}, {0}, {}
        0, '0028', '0009', '1C', {}, frameIncrementTerms, {'present', ...
                    '(0028,0008)'}
        0, '0008', '0008', '2',  {}, {}, {}
        0, '0028', '2110', '1C', {}, {0 1}, {'present', '(0028,2110)'}
        0, '0008', '2124', '2C', {}, {}, {'present', '(0008,2124)'}
        0, '0008', '212A', '2C', {}, {}, {'present', '(0008,212A)'}
        0, '0028', '0014', '3',  {}, {0 1}, {}
        0, '0008', '1130', '3',  {}, {}, {}
        1, '0008', '1150', '1C', {}, {}, {'present', '(0008,1130)'}
        1, '0008', '1155', '1C', {}, {}, {'present', '(0008,1130)'}
        0, '0008', '1145', '3',  {}, {}, {}
        1, '0008', '1150', '1C', {}, {}, {'present', '(0008,1145)'}
        1, '0008', '1155', '1C', {}, {}, {'present', '(0008,1145)'}
        0, '0008', '113A', '3',  {}, {}, {}
%        1, % SOP Instance Reference Macro
        1, '0040', 'A170', '1',  {}, {}, {}
%        2, % Code Sequence Macro, Defined Context ID is CID 7004
        0, '0008', '2120', '3',  {}, {}, {}
        0, '0040', '000A', '3',  {}, {}, {}
        1, 'code', 'sequ', 'X',  {}, {}, {}  % This is a placeholder.    
%        1, % Code Sequence Macro, Baseline Context ID is 12002
        0, '0008', '2122', '3',  {}, {}, {}
        0, '0008', '2127', '3',  {}, {}, {}
        0, '0008', '2128', '3',  {}, {}, {}
        0, '0008', '2129', '3',  {}, {}, {}
        0, '0008', '2130', '3',  {}, {}, {}
        0, '0008', '2132', '3',  {}, {}, {}
        0, '0008', '2218', '3',  {}, {}, {}
%        1, % Code Sequence Macro, Baseline Context ID is 1
        1, '0008', '2220', '3',  {}, {}, {}
%        2, % Code Sequence Macro, Baseline Context ID is 2
        0, '0008', '2228', '3',  {}, {}, {}
%        1, % Code Sequence Macro, Baseline Context ID is 1
        1, '0008', '2230', '3',  {}, {}, {}
%        2, % Code Sequence Macro, Baseline Context ID is 2
        0, '0008', '2240', '3',  {}, {}, {}
%        1, % Code Sequence Macro, Baseline Context ID is 4
        1, '0008', '2242', '3',  {}, {}, {}
%        2, % Code Sequence Macro, Baseline Context ID is 5
        0, '0008', '2244', '3',  {}, {}, {}
%        1, % Code Sequence Macro, Baseline Context ID is 6
        1, '0008', '2246', '3',  {}, {}, {}
%        2, % Code Sequence Macro, Baseline Context ID is 7
        0, '0008', '002A', '1C', {}, {}, {'or', ...
                    {'equal', '(0008,0060)', 'IVUS'}, ...
                    {'present', '(0008,002A)'}}
        0, '0018', '1060', '3',  {}, {}, {}
        0, '0018', '1062', '3',  {}, {}, {}
        0, '0018', '1080', '3',  {}, {'Y', 'N'}, {}
        0, '0018', '1081', '3',  {}, {}, {}
        0, '0018', '1082', '3',  {}, {}, {}
        0, '0018', '1088', '3',  {}, {}, {}
        0, '0018', '3100', '1C', {}, {'MOTOR_PULLBACK',
                                      'MANUAL_PULLBACK',
                                      'SELECTIVE',
                                      'GATED_PULLBACK'}, {'equal', ...
                    '(0008,0060)', 'IVUS'}
        0, '0018', '3101', '1C', {}, {}, {'equal', '(0018,3100)', 'MOTOR_PULLBACK'}
        0, '0018', '3102', '1C', {}, {}, {'equal', '(0018,3100)', 'GATED_PULLBACK'}
        0, '0018', '3103', '1C', {}, {}, {'or',  ...
                    {'equal', '(0018,3100)', 'GATED_PULLBACK'}, ...
                    {'equal', '(0018,3100)', 'MOTOR_PULLBACK'}}
        0, '0018', '3104', '1C', {}, {}, {'or',  ...
                    {'equal', '(0018,3100)', 'GATED_PULLBACK'}, ...
                    {'equal', '(0018,3100)', 'MOTOR_PULLBACK'}}
        0, '0018', '3105', '3',  {}, {}, {}
        0, '0018', '5000', '3',  {}, {}, {}
        0, '0018', '5010', '3',  {}, {}, {}
        0, '0018', '6031', '3',  {}, transducerTerms, {}
        0, '0018', '5012', '3',  {}, {}, {}
        0, '0018', '5020', '3',  {}, {}, {}
        0, '0018', '5022', '3',  {}, {}, {}
        0, '0018', '5024', '3',  {}, {}, {}
        0, '0018', '5026', '3',  {}, {}, {}
        0, '0018', '5027', '3',  {}, {}, {}
        0, '0018', '5028', '3',  {}, {}, {}
        0, '0018', '5029', '3',  {}, {}, {}
        0, '0018', '5050', '3',  {}, {}, {}
        0, '0018', '5210', '3',  {}, {}, {}
        0, '0018', '5212', '3',  {}, {}, {}
        0, '60xx', '0045', '3',  {}, {'ACTIVE 2D/BMODE IMAGE AREA'}, {}
        };

        
        
function details = build_Cine

details.Name = 'Cine';
details.SpecPart = 'PS 3.3 Sec. C.7.6.5';
details.Attrs = {
        0, '0018', '1244', '3',  {}, {0 1}, {}
        0, '0018', '1063', '1C', {}, {}, {'equal', '(0028,0009)', ...
                    uint16(sscanf('0018 1063', '%x')')}
        0, '0018', '1065', '1C', {}, {}, {'equal', '(0028,0009)', ...
                    uint16(sscanf('0018 1065', '%x')')}
        0, '0008', '2142', '3',  {}, {}, {}
        0, '0008', '2143', '3',  {}, {}, {}
        0, '0008', '2144', '3',  {}, {}, {}
        0, '0018', '0040', '3',  {}, {}, {}
        0, '0018', '1066', '3',  {}, {}, {}
        0, '0018', '1067', '3',  {}, {}, {}
        0, '0018', '0072', '3',  {}, {}, {}
        0, '0018', '1242', '3',  {}, {}, {}
        };
        
        
function details = build_MultiFrame

details.Name = 'MultiFrame';
details.SpecPart = 'PS 3.3 Sec. C.7.6.6';
details.Attrs = {
        0, '0028', '0008', '1',  {}, {}, {}
        0, '0028', '0009', '1',  {}, {}, {}
        };

        
        
function details = build_ModalityLUT

details.Name = 'ModalityLUT';
details.SpecPart = 'PS 3.3 Sec. C.11.1';
details.Attrs = {
        0, '0028', '3000', '1C', {}, {}, {'not', {'present', '(0028,1052)'}}
        1, '0028', '3002', '1C', {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, ...
                    {}, {'present', '(0028,3000)'}
        1, '0028', '3003', '3',  {}, {}, {}
        1, '0028', '3004', '1C', {}, {}, {'present', '(0028,3000)'}
        1, '0028', '3006', '1C', {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, ...
                    {}, {'present', '(0028,3000)'}
        0, '0028', '1052', '1C', {}, {}, {'not', {'present', '(0028,3000)'}}
        0, '0028', '1053', '1C', {}, {}, {'present', '(0028,1052)'}
        0, '0028', '1054', '1C', {}, {'OD', 'US', 'US'}, ...
                    {'present', '(0028,1052)'}
        };

        
        
function details = build_FramePointers

details.Name = 'FramePointers';
details.SpecPart = 'PS 3.3 Sec. C.7.6.9';
details.Attrs = {
        0, '0028', '6010', '3',  {}, {}, {}
        0, '0028', '6020', '3',  {}, {}, {}
        0, '0028', '6022', '3',  {}, {}, {}
        };

        
        
function details = build_Mask

details.Name = 'Mask';
details.SpecPart = 'PS 3.3 Sec. C.7.6.10';
details.Attrs = {
        0, '0028', '6100', '1',  {}, {}, {}
        1, '0028', '6101', '1',  {}, {'NONE', 'AVG_SUB', 'TID'}, {}
        1, '0028', '6102', '3',  {}, {}, {}
        1, '0028', '6110', '1C', {}, {}, {'equal', '(0028,6101)', 'AVG_SUB'}
        1, '0028', '6112', '3',  {}, {}, {}
        1, '0028', '6114', '3',  {}, {}, {}
        1, '0028', '6120', '2C', {}, {}, {'equal', '(0028,6101)', 'TID'}
        1, '0028', '6190', '3',  {}, {}, {}
        0, '0028', '1090', '2',  {}, {'SUB', 'NAT'}, {}
        };

        
        
function details = build_DisplayShutter

details.Name = 'DisplayShutter';
details.SpecPart = 'PS 3.3 Sec. C.7.6.11';
details.Attrs = {
        0, '0018', '1600', '1',  {}, {'RECTANGULAR', 'CIRCULAR', 'POLYGONAL'}, {}
        0, '0018', '1602', '1C', {}, {}, {'equal', '(0018,1600)', 'RECTANGULAR'}
        0, '0018', '1604', '1C', {}, {}, {'equal', '(0018,1600)', 'RECTANGULAR'}
        0, '0018', '1606', '1C', {}, {}, {'equal', '(0018,1600)', 'RECTANGULAR'}
        0, '0018', '1608', '1C', {}, {}, {'equal', '(0018,1600)', 'RECTANGULAR'}
        0, '0018', '1610', '1C', {}, {}, {'equal', '(0018,1600)', 'CIRCULAR'}
        0, '0018', '1612', '1C', {}, {}, {'equal', '(0018,1600)', 'CIRCULAR'}
        0, '0018', '1620', '1C', {}, {}, {'equal', '(0018,1600)', 'POLYGONAL'}
        0, '0018', '1622', '3',  {}, {}, {}
        };

        
        
function details = build_Device

details.Name = 'Device';
details.SpecPart = 'PS 3.3 Sec. C.7.6.12';
details.Attrs = {
        0, '0050', '0010', '3',  {}, {}, {}
%        1, % Code Sequence Macro, Baseline context ID is 8
        1, '0050', '0014', '3',  {}, {}, {}
        1, '0050', '0016', '3',  {}, {}, {}
        1, '0050', '0017', '2C', {}, {'FR', 'GA', 'IN', 'MM'}, ...
                    {'present', '(0050,0016)'}
        1, '0050', '0018', '3',  {}, {}, {}
        1, '0050', '0019', '3',  {}, {}, {}
        1, '0050', '0020', '3',  {}, {}, {}
        };

        
        
function details = build_Therapy

details.Name = 'Therapy';
details.SpecPart = 'PS 3.3 Sec. C.7.6.13';
details.Attrs = {
        0, '0018', '0036', '3',  {}, {}, {}
%        1, % Code Sequence Macro, Baseline context ID is 9
        1, '0018', '0038', '2',  {}, {'PRE', 'INTERMEDIATE', 'POST', 'NONE'}, {}
        1, '0018', '0029', '3',  {}, {}, {}
%        2, % Code Sequence Macro, Baseline context ID is 10
        1, '0018', '0035', '3',  {}, {}, {}
        1, '0018', '0027', '3',  {}, {}, {}
        1, '0054', '0302', '3',  {}, {}, {}
%        2, % Code Sequence Macro, Baseline context ID is 11
        1, '0018', '0039', '3',  {}, {}, {}
        };

        
        
function details = build_XRayImage

details.Name = 'XRayImage';
details.SpecPart = 'PS 3.3 Sec. C.8.7.1';
details.Attrs = {
        0, '0028', '0009', '1C', {}, frameIncrementTerms, {'present', ...
                    '(0028,0008)'}
        0, '0028', '2110', '1C', {}, {0 1}, {'present', '(0028,2110)'}
        0, '0008', '0008', '1',  {}, {}, {}
        0, '0028', '1040', '1',  {}, {'LIN', 'LOG', 'DISP'}, {}
        0, '0028', '0002', '1',  {}, {1}, {}
        0, '0028', '0004', '1',  {}, {'MONOCHROME2'}, {}
        0, '0028', '0100', '1',  {}, {8 16}, {}
        0, '0028', '0101', '1',  {}, {8 10 12 16}, {}
        0, '0028', '0102', '1',  {}, {7 9 11 15}, {}
        0, '0028', '0103', '1',  {}, {0}, {}
        0, '0018', '0022', '3',  {}, scanOptionsTerms, {}
        0, '0008', '2218', '3',  {}, {}, {}
%        1, % Code Sequence Macro, Baseline context ID is 1
        1, '0008', '2220', '3',  {}, {}, {}
%        2, % Code Sequence Macro, Baseline context ID is 2
        0, '0008', '2228', '3',  {}, {}, {}
%        1, % Code Sequence Macro, Baseline context ID is 1
        1, '0008', '2230', '3',  {}, {}, {}
%        2, % Code Sequence Macro, Baseline context ID is 2
        0, '0028', '6040', '3',  {}, {}, {}
        0, '0008', '1140', '1C', {}, {}, {'present', '(0008,1140)'}
        1, '0008', '1150', '1C', {}, {}, {'present', '(0008,1140)'}
        1, '0008', '1155', '1C', {}, {}, {'present', '(0008,1140)'}
        0, '0008', '2111', '3',  {}, {}, {}
        0, '0018', '1400', '3',  {}, {}, {}
        0, '0050', '0004', '3',  {}, {'YES', 'NO'}, {}
        };

        
        
function details = build_XRayAcquisition

details.Name = 'XRayAcquisition';
details.SpecPart = 'PS 3.3 Sec. C.8.7.2';
details.Attrs = {
        0, '0018', '0060', '2',  {}, {}, {}
        0, '0018', '1155', '1',  {}, {'SC', 'GR'}, {}
        0, '0018', '1151', '2C', {}, {}, {'not', {'present', '(0018,1152)'}}
        0, '0018', '1150', '2C', {}, {}, {'not', {'present', '(0018,1152)'}}
        0, '0018', '1152', '2C', {}, {}, {'not', {'and', ...
                    {'present', '(0018,1150)'}, ...
                    {'present', '(0018,1151)'}}}
        0, '0018', '1153', '3',  {}, {}, {}
        0, '0018', '1166', '3',  {}, {'IN', 'NONE'}, {}
        0, '0018', '1154', '3',  {}, {}, {}
        0, '0018', '115A', '3',  {}, {'CONTINUOUS', 'PULSED'}, {}
        0, '0018', '1161', '3',  {}, {}, {}
        0, '0018', '1162', '3',  {}, {}, {}
        0, '0018', '1147', '3',  {}, {'ROUND', 'RECTANGLE'}, {}
        0, '0018', '1149', '3',  {}, {}, {}
        0, '0018', '1164', '3',  {}, {}, {}
        0, '0018', '1190', '3',  {}, {}, {}
        0, '0018', '115E', '3',  {}, {}, {}
        };

        
        
function details = build_XRayCollimator

details.Name = 'XRayCollimator';
details.SpecPart = 'PS 3.3 Sec. C.8.7.3';
details.Attrs = {
        0, '0018', '1700', '1',  {}, {'RECTANGULAR', 'CIRCULAR', 'POLYGONAL'}, {}
        0, '0018', '1702', '1C', {}, {}, {'equal', '(0018,1600)', 'RECTANGULAR'}
        0, '0018', '1704', '1C', {}, {}, {'equal', '(0018,1600)', 'RECTANGULAR'}
        0, '0018', '1706', '1C', {}, {}, {'equal', '(0018,1600)', 'RECTANGULAR'}
        0, '0018', '1708', '1C', {}, {}, {'equal', '(0018,1600)', 'RECTANGULAR'}
        0, '0018', '1710', '1C', {}, {}, {'equal', '(0018,1600)', 'CIRCULAR'}
        0, '0018', '1712', '1C', {}, {}, {'equal', '(0018,1600)', 'CIRCULAR'}
        0, '0018', '1720', '1C', {}, {}, {'equal', '(0018,1600)', 'POLYGONAL'}
        };

        
        
function details = build_XRayTable

details.Name = 'XRayTable';
details.SpecPart = 'PS 3.3 Sec. C.8.7.4';
details.Attrs = {
        0, '0018', '1134', '2',  {}, {'STATIC', 'DYNAMIC'}, {}
        0, '0018', '1135', '2C', {}, {}, {'equal', '(0018,1134)', 'DYNAMIC'}
        0, '0018', '1137', '2C', {}, {}, {'equal', '(0018,1134)', 'DYNAMIC'}
        0, '0018', '1136', '2C', {}, {}, {'equal', '(0018,1134)', 'DYNAMIC'}
        0, '0018', '1138', '3',  {}, {}, {}
        };

        
        
function details = build_XAPositioner

details.Name = 'XAPositioner';
details.SpecPart = 'PS 3.3 Sec. C.8.7.5';
details.Attrs = {
        0, '0018', '1111', '3',  {}, {}, {}
        0, '0018', '1110', '3',  {}, {}, {}
        0, '0018', '1114', '3',  {}, {}, {}
        0, '0018', '1500', '2C', {}, {'STATIC', 'DYNAMIC'}, {'and', ...
                    {'present', '(0028,0008)'}, ...
                    {'not', {'equal', '(0028,0008)', 1}}}
        0, '0018', '1510', '2',  {}, {}, {}
        0, '0018', '1511', '2',  {}, {}, {}
        0, '0018', '1520', '2C', {}, {}, {'equal', '(0018,1500)', 'DYNAMIC'}
        0, '0018', '1521', '2C', {}, {}, {'equal', '(0018,1500)', 'DYNAMIC'}
        0, '0018', '1530', '3',  {}, {}, {}
        0, '0018', '1531', '3',  {}, {}, {}
        };

        
        
function details = build_MultiFrameOverlay

details.Name = 'MultiFrameOverlay';
details.SpecPart = 'PS 3.3 Sec. C.9.3';
details.Attrs = {
        0, '60xx', '0015', '1',  {}, {}, {}
        0, '60xx', '0051', '3',  {}, {}, {}
        };

        
        
function details = build_Curve

details.Name = 'Curve';
details.SpecPart = 'PS 3.3 Sec. C.10.2';
details.Attrs = {
        0, '50xx', '0005', '1',  {}, {}, {}
        0, '50xx', '0010', '1',  {}, {}, {}
        0, '50xx', '0020', '1',  {}, curveTypeTerms, {}
        0, '50xx', '0103', '1',  {}, {0 1 2 3 4}, {}
        0, '50xx', '3000', '1',  curveVRlut, {}, {}
        0, '50xx', '0022', '3',  {}, {}, {}
        0, '50xx', '0030', '3',  {}, axisUnitsTerms, {}
        0, '50xx', '0040', '3',  {}, {}, {}
        0, '50xx', '0104', '3',  {}, {}, {}
        0, '50xx', '0105', '3',  {}, {}, {}
        0, '50xx', '0106', '3',  {}, {}, {}
        0, '50xx', '0110', '1C', {}, {}, {'present', '(50xx,0110)'}
        0, '50xx', '0112', '1C', curveVRlut, {}, {'present', '(50xx,0110)'}
        0, '50xx', '0114', '1C', curveVRlut, {}, {'present', '(50xx,0110)'}
        0, '50xx', '2500', '3',  {}, {}, {}
        0, '50xx', '2600', '3',  {}, {}, {}
        1, '0008', '1150', '1C', {}, {}, {'present', '(50xx,2600)'}
        1, '0008', '1155', '1C', {}, {}, {'present', '(50xx,2600)'}
        1, '50xx', '2610', '1C', {}, {}, {'present', '(50xx,2600)'}
        };



function details = build_SCMultiFrameImage

mono2gray = {'and', ...
             {'equal', '(0028,0004)', 'MONOCHROME2'}, ...
             {'not', {'equal', '(0028,0101)', 1}}};

details.Name = 'SC Multi-Frame Image';
details.SpecPart = 'PS 3.3 Sec. C.8.6.3';
details.Attrs = {
        0, '0028', '0301', '1',  {}, {}, {}
        0, '2050', '0020', '1C', {}, {'IDENTITY'}, mono2gray
        0, '2010', '015E', '3',  {}, {}, {}
        0, '2010', '0160', '3',  {}, {}, {}
        0, '0028', '1052', '1C', {}, {}, mono2gray
        0, '0028', '1053', '1C', {}, {}, mono2gray
        0, '0028', '1054', '1C', {}, {}, mono2gray
        0, '0028', '0009', '1C', {}, {}, {'present', '(0028,0008)'}
        0, '0018', '2010', '1C', {}, {}, {'or', ...
                    {'equal', '(0008,0064)', 'DF'}, ...
                    {'present', '(0008,0064)'}}
        0, '0018', '2020', '3',  {}, {}, {}
        0, '0018', '2030', '3',  {}, {}, {}
        };



function details = build_SCMultiFrameVector

details.Name = 'SC Multi-Frame Vector';
details.SpecPart = 'PS 3.3 Sec. C.8.6.4';
details.Attrs = {
        0, '0018', '1065', '1C', {}, {}, {'present', '(0018,1065)'}
        0, '0018', '2001', '1C', {}, {}, {'present', '(0018,2001)'}
        0, '0018', '2002', '1C', {}, {}, {'present', '(0018,2002)'}
        0, '0018', '2003', '1C', {}, {}, {'present', '(0018,2003)'}
        0, '0018', '2004', '1C', {}, {}, {'present', '(0018,2004)'}
        0, '0018', '2005', '1C', {}, {}, {'present', '(0018,2005)'}
        0, '0018', '2006', '1C', {}, {}, {'present', '(0018,2006)'}
        };



function details = build_ClinicalTrialStudy

details.Name = 'Clinical Trial Study';
details.SpecPart = 'PS 3.3 Sec. C.7.2.3';
details.Attrs = {
        0, '0012', '0050', '2',  {}, {}, {}
        0, '0012', '0051', '3',  {}, {}, {}
        0, '0012', '0083', '3',  {}, {}, {}
        1, '0012', '0084', '1C', {}, {}, {'or', ...
                        {'equal', '(0012,0085)', 'YES'}, ...
                        {'equal', '(0012,0085)', 'WITHDRAWN'}}
        1, '0012', '0020', '1C', {}, {}, {'equal', '(0012,0084)', 'NAMED_PROTOCOL'}
        1, '0012', '0085', '1',  {}, {}, {}
        };



function details = build_ClinicalTrialSubject

details.Name = 'Clinical Trial Subject';
details.SpecPart = 'PS 3.3 Sec. C.7.1.3';
details.Attrs = {
        0, '0012', '0010', '1',  {}, {}, {}
        0, '0012', '0020', '1',  {}, {}, {}
        0, '0012', '0021', '2',  {}, {}, {}
        0, '0012', '0030', '2',  {}, {}, {}
        0, '0012', '0031', '2',  {}, {}, {}
        0, '0012', '0040', '1C', {}, {}, {'or', ...
                        {'present', '(0012,0040)'}, ...
                        {'not', {'present', '(0012,0042)'}}}
        0, '0012', '0042', '1C', {}, {}, {'or', ...
                        {'present', '(0012,0042)'}, ...
                        {'not', {'present', '(0012,0040)'}}}
        0, '0012', '0081', '1C', {}, {}, {'present', '(0012,0082)'}
        0, '0012', '0082', '3',  {}, {}, {}
        };



function details = build_ClinicalTrialSeries

details.Name = 'Clinical Trial Series';
details.SpecPart = 'PS 3.3 Sec. C.7.3.2';
details.Attrs = {
        0, '0012', '0060', '2',  {}, {}, {}
        0, '0012', '0071', '3',  {}, {}, {}
        0, '0012', '0072', '3',  {}, {}, {}
        };



function details = build_MRSeries

details.Name = 'MR Series';
details.SpecPart = 'PS 3.3 Sec. C.8.13.6';
details.Attrs = {
        0, '0008', '0060', '1',  {}, {}, {}
        0, '0008', '1111', '1C', {}, {}, {'present', '(0008,1111)'}
        1, '0008', '1150', '1',  {}, {}, {}
        1, '0008', '1155', '1',  {}, {}, {}
        };



function details = build_Synchronization

details.Name = 'Synchronization';
details.SpecPart = 'PS 3.3 Sec. C.7.4.2';
details.Attrs = {
        0, '0020', '0200', '1',  {}, {}, {}
        0, '0018', '106A', '1',  {}, {}, {}
        0, '0018', '1061', '3',  {}, {}, {}
        0, '0018', '106C', '1C', {}, {}, {'present', '(0018,106C)'}
        0, '0018', '1800', '1',  {}, {}, {}
        0, '0018', '1801', '3',  {}, {}, {}
        0, '0018', '1802', '3',  {}, {}, {}
        0, '0018', '1803', '3',  {}, {}, {}
        };



function details = build_EnhancedGeneralEquipment

details.Name = 'Enhanced General Equipment';
details.SpecPart = 'PS 3.3 Sec. C.7.5.2';
details.Attrs = {
        0, '0008', '0070', '1',  {}, {}, {}
        0, '0008', '1090', '1',  {}, {}, {}
        0, '0018', '1000', '1',  {}, {}, {}
        0, '0018', '1020', '1',  {}, {}, {}
        };



function details = build_EnhancedContrastBolus

details.Name = 'Enhanced Contrast Bolus';
details.SpecPart = 'PS 3.3 Sec. C.7.6.4b';
details.Attrs = [
        {0, '0018', '0012', '1',  {}, {}, {}}
        createCodeSequenceMacro(1)
        {1, '0018', '9337', '1',  {}, {}, {}
         1, '0018', '0014', '1',  {}, {}, {}}
        createCodeSequenceMacro(2)
        {1, '0018', '9338', '1',  {}, {}, {}}
        createCodeSequenceMacro(2)
        {1, '0018', '1041', '2',  {}, {}, {}
         1, '0018', '1049', '2',  {}, {}, {}
         1, '0018', '9425', '3',  {}, {}, {}
         1, '0018', '9340', '3',  {}, {}, {}
         2, '0018', '1041', '2',  {}, {}, {}
         2, '0018', '1042', '3',  {}, {}, {}
         2, '0018', '1043', '3',  {}, {}, {}
         2, '0018', '1046', '3',  {}, {}, {}
         2, '0018', '1047', '3',  {}, {}, {}}
        ];



function details = build_MultiFrameDimension

details.Name = 'Multi-frame Dimension';
details.SpecPart = 'PS 3.3 Sec. C.7.6.17';
details.Attrs = {
        0, '0020', '9221', '1',  {}, {}, {}
        1, '0020', '9164', '1',  {}, {}, {}
        0, '0020', '9311', '3',  {}, {}, {}
        0, '0020', '9222', '1',  {}, {}, {}
        1, '0020', '9165', '1',  {}, {}, {}
        1, '0020', '9213', '1C', {}, {}, {'present', '(0020,9213)'}
        1, '0020', '9167', '1C', {}, {}, {'present', '(0020,9167)'}
        1, '0020', '9238', '1C', {}, {}, {'present', '(0020,9238)'}
        1, '0020', '9164', '1C', {}, {}, {'present', '(0020,9164)'}
        1, '0020', '9241', '3',  {}, {}, {}
        };



function details = build_CardiacSynchronization

details.Name = 'Cardiac Synchronization';
details.SpecPart = 'PS 3.3 Sec. C.7.6.18.1';
details.Attrs = {
        0, '0018', '9037', '1C', {}, {}, {'present', '(0018,9037)'}
        0, '0018', '9085', '1C', {}, {}, {'present', '(0018,9085)'}
        0, '0018', '9070', '1C', {}, {}, {'present', '(0018,9070)'}
        0, '0018', '9169', '1C', {}, {}, {'present', '(0018,9169)'}
        0, '0018', '1081', '2C', {}, {}, {'present', '(0018,1081)'}
        0, '0018', '1082', '2C', {}, {}, {'present', '(0018,1082)'}
        0, '0018', '1083', '2C', {}, {}, {'present', '(0018,1083)'}
        0, '0018', '1084', '2C', {}, {}, {'present', '(0018,1084)'}
        0, '0018', '1086', '3',  {}, {}, {}
        0, '0018', '1064', '1C', {}, {}, {'present', '(0018,1064)'}
        };



function details = build_RespiratorySynchronization

details.Name = 'Respiratory Synchronization';
details.SpecPart = 'PS 3.3 Sec. C.7.6.18.2';
details.Attrs = {
        0, '0018', '9170', '1C', {}, {}, {'present', '(0018,9170)'}
        0, '0018', '9171', '1C', {}, {}, {'present', '(0018,9171)'}
        0, '0020', '9256', '1C', {}, {}, {'present', '(0020,9256)'}
        0, '0020', '9250', '1C', {}, {}, {'present', '(0020,9250)'}
        };



function details = build_BulkMotionSynchronization

details.Name = 'Bulk Motion Synchronization';
details.SpecPart = 'PS 3.3 Sec. C.7.6.18.2';
details.Attrs = {
        0, '0018', '9172', '1C', {}, {}, {'present', '(0018,9172)'}
        0, '0018', '9173', '1C', {}, {}, {'present', '(0018,9173)'}
        };



function details = build_SupplementalPaletteColorLUT

details.Name = 'Supplemental Palette Color Lookup Table';
details.SpecPart = 'PS 3.3 Sec. C.7.6.19';
details.Attrs = {
        0, '0028', '1101', '1',  {}, {}, {}
        0, '0028', '1102', '1',  {}, {}, {}
        0, '0028', '1103', '1',  {}, {}, {}
        0, '0028', '1201', '1',  {}, {}, {}
        0, '0028', '1202', '1',  {}, {}, {}
        0, '0028', '1203', '1',  {}, {}, {}
        };



function details = build_AcquisitionContext

details.Name = 'Acquisition Context';
details.SpecPart = 'PS 3.3 Sec. C.7.6.14';
details.Attrs = [...
        {0, '0040', '0555', '2',  {}, {}, {}
         1, '0040', 'A040', '3',  {}, {}, {}
         1, '0040', 'A043', '1',  {}, {}, {}}
        createCodeSequenceMacro(2)
        {1, '0040', 'A136', '1C', {}, {}, {'present', '(0040,A136)'}
         1, '0040', 'A30A', '1C', {}, {}, {'present', '(0040,A30A)'}
         1, '0040', '08EA', '1C', {}, {}, {'present', '(0040,A30A)'}}
        createCodeSequenceMacro(2)
        {1, '0040', 'A121', '1C', {}, {}, {'present', '(0040,A121)'}
         1, '0040', 'A122', '1C', {}, {}, {'present', '(0040,A122)'}
         1, '0040', 'A123', '1C', {}, {}, {'present', '(0040,A123)'}
         1, '0040', 'A160', '1C', {}, {}, {'present', '(0040,A160)'}
         1, '0040', 'A168', '1C', {}, {}, {'present', '(0040,A168)'}}
        createCodeSequenceMacro(2)
        {0, '0040', '0556', '3',  {}, {}, {}}
        ];



function details = build_MultiFrameFunctionalGroups

details.Name = 'Multi-frame Functional Groups';
details.SpecPart = 'PS 3.3 Sec. C.7.6.16';
details.Attrs = [...
        {0, '5200', '9229', '2',  {}, {}, {}}
        createPixelMeasuresMacro(0)
        createFrameContentMacro(0)
        % Insert 0 or 1 functional group macros here.
        {0, '5200', '9230', '1',  {}, {}, {}
         % Insert "number of frames" functional group macros here.
         0, '0020', '0013', '1',  {}, {}, {}
         0, '0008', '0023', '1',  {}, {}, {}
         0, '0008', '0033', '1',  {}, {}, {}
         0, '0028', '0008', '1',  {}, {}, {}
         0, '0020', '9228', '1C', {}, {}, {'present', '(0020,9161)'}
         0, '0028', '6010', '3',  {}, {}, {}
         0, '0020', '9161', '1C', {}, {}, {'present', '(0020,9161)'}
         0, '0020', '0242', '1C', {}, {}, {'present', '(0020,9161)'}
         0, '0020', '9162', '1C', {}, {}, {'present', '(0020,9161)'}
         0, '0020', '9163', '3',  {}, {}, {}}
        ];



function details = build_Specimen

details.Name = 'Specimen';
details.SpecPart = 'PS 3.3 Sec. C.7.6.22';
details.Attrs = [
        {0, '0040', '0512', '1',  {}, {}, {}
         0, '0040', '0513', '2',  {}, {}, {}}
        createHL7v2HierarchicDesignator(1)
        {0, '0040', '0515', '3',  {}, {}, {}
         1, '0040', '0512', '1',  {}, {}, {}
         1, '0040', '0513', '2',  {}, {}, {}}
        createHL7v2HierarchicDesignator(2)
        {0, '0040', '0518', '2',  {}, {}, {}}
        createCodeSequenceMacro(1)
        {0, '0040', '051A', '3',  {}, {}, {}
         0, '0040', '0520', '3',  {}, {}, {}
         1, '0050', '0012', '1',  {}, {}, {}}
        createCodeSequenceMacro(2)
        {1, '0008', '0070', '3',  {}, {}, {}
         1, '0008', '1090', '3',  {}, {}, {}
         1, '0050', '001B', '3',  {}, {}, {}
         1, '0050', '001C', '3',  {}, {}, {}
         1, '0050', '0015', '3',  {}, {}, {}
         1, '0050', '001D', '3',  {}, {}, {}
         1, '0050', '0013', '3',  {}, {}, {}
         1, '0050', '001A', '3',  {}, {}, {}
         1, '0050', '001E', '3',  {}, {}, {}
         0, '0040', '0560', '1',  {}, {}, {}
         1, '0040', '0551', '1',  {}, {}, {}
         1, '0040', '0562', '2',  {}, {}, {}}
        createHL7v2HierarchicDesignator(2)
        {1, '0040', '0554', '1',  {}, {}, {}
         1, '0040', '059A', '3',  {}, {}, {}}
        createCodeSequenceMacro(2)
        {1, '0040', '0600', '3',  {}, {}, {}
         1, '0040', '0602', '3',  {}, {}, {}
         1, '0040', '0610', '2',  {}, {}, {}
         2, '0040', '0612', '1',  {}, {}, {}}
        createContentItemMacro(3)
        {1, '0008', '2228', '3',  {}, {}, {}}  % Primary Anatomic Structure Macro
        createCodeSequenceMacro(2)             % Primary Anatomic Structure Macro
        {2, '0008', '2230', '3',  {}, {}, {}}  % Primary Anatomic Structure Macro
        createCodeSequenceMacro(3)             % Primary Anatomic Structure Macro
        {1, '0040', '0620', '1C', {}, {}, {'present', '(0040,0620)'}}
        createContentItemMacro(2)
        ];



function details = build_MRPulseSequence

details.Name = 'MR Pulse Sequence';
details.SpecPart = 'PS 3.3 Sec. C.8.13.4';
details.Attrs = {
        0, '0018', '9005', '1C', {}, {}, {'present', '(0018,9005)'}
        0, '0018', '0023', '1C', {}, {}, {'present', '(0018,9023)'}
        0, '0018', '9008', '1C', {}, {}, {'present', '(0018,9028)'}
        0, '0018', '9011', '1C', {}, {}, {'present', '(0018,9011)'}
        0, '0018', '9012', '1C', {}, {}, {'present', '(0018,9012)'}
        0, '0018', '9014', '1C', {}, {}, {'present', '(0018,9014)'}
        0, '0018', '9015', '1C', {}, {}, {'present', '(0018,9015)'}
        0, '0018', '9017', '1C', {}, {}, {'present', '(0018,9017)'}
        0, '0018', '9018', '1C', {}, {}, {'present', '(0018,9018)'}
        0, '0018', '9024', '1C', {}, {}, {'present', '(0018,9024)'}
        0, '0018', '9025', '1C', {}, {}, {'present', '(0018,9025)'}
        0, '0018', '9029', '1C', {}, {}, {'present', '(0018,9029)'}
        0, '0018', '9032', '1C', {}, {}, {'present', '(0018,9032)'}
        0, '0018', '9034', '1C', {}, {}, {'present', '(0018,9034)'}
        0, '0018', '9033', '1C', {}, {}, {'present', '(0018,9033)'}
        0, '0018', '9094', '1C', {}, {}, {'present', '(0018,9094)'}
        0, '0018', '9093', '1C', {}, {}, {'present', '(0018,9093)'}
        };



function details = build_EnhancedMRImage

details.Name = 'Enhanced MR Image';
details.SpecPart = 'PS 3.3 Sec. C.8.13.1';
details.Attrs = [
        createMRImageAndSpectroscopyInstance(0)
        {0, '0008', '0008', '1',  {}, {}, {}}
        createMRImageDescription(0)
        {0, '0028', '0002', '1',  {}, {}, {}
         0, '0028', '0004', '1',  {}, {}, {}
         0, '0028', '0100', '1',  {}, {}, {}
         0, '0028', '0101', '1',  {}, {}, {}
         0, '0028', '0102', '1',  {}, {}, {}
         0, '0028', '0103', '1',  {}, {}, {}
         0, '0028', '0006', '1C', {}, {}, {'not', {'equal', '(0028,0002)', 1}}
         0, '0018', '0088', '3',  {}, {}, {}
         0, '0028', '0301', '1',  {}, {'NO'}, {}
         0, '0028', '2110', '1',  {}, {}, {}
         0, '0028', '2112', '1C', {}, {}, {'equal', '(0028,2110)', '01'}
         0, '0028', '2114', '1C', {}, {}, {'equal', '(0028,2110)', '01'}
         0, '2050', '0020', '1C', {}, {}, {'equal', '(0028,0004)', 'MONOCHROME2'}
         0, '0088', '0200', '3',  {}, {}, {}}
        createImagePixelMacro(1)
        ];



function macro = createImagePixelMacro(level)

macro = {
        level, '0028', '0002', '1',  {}, {}, {}
        level, '0028', '0004', '1',  {}, {}, {}
        level, '0028', '0010', '1',  {}, {}, {}
        level, '0028', '0011', '1',  {}, {}, {}
        level, '0028', '0100', '1',  {}, {}, {}
        level, '0028', '0101', '1',  {}, {}, {}
        level, '0028', '0102', '1',  {}, {}, {}
        level, '0028', '0103', '1',  {}, {0 1}, {}
        level, '7FE0', '0010', '1',  {}, {}, {}
        level, '0028', '0006', '1C', {}, {}, {'not', {'equal', '(0028,0002)', 1}}
        level, '0028', '0034', '1C', {}, {}, {'present', '(0028,0034)'}
        level, '0028', '0106', '3',  {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, {}
        level, '0028', '0107', '3',  {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, {}
        level, '0028', '1101', '1C', {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, ...
                 {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        level, '0028', '1102', '1C', {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, ...
                 {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        level, '0028', '1103', '1C', {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, ...
                 {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        level, '0028', '1201', '1C', {}, {}, {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        level, '0028', '1202', '1C', {}, {}, {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        level, '0028', '1203', '1C', {}, {}, {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        level, '0028', '2000', '3',  {}, {}, {}
        level, '0028', '0008', '1C', {}, {}, {'present', '(0028,0008)'}
        level, '0028', '0009', '1C', {}, {}, {'present', '(0028,0009)'}};

function macro = createMRImageAndSpectroscopyInstance(level)

% See PS 3.3 Table C.8-81.
macro = [...
        {level, '0020', '0012', '3',  {}, {}, {}
         level, '0008', '002A', '1C', {}, {}, {'present', '(0008,002A)'}
         level, '0018', '9073', '1C', {}, {}, {'present', '(0018,9073)'}
         level, '0008', '9121', '3',  {}, {}, {}}
        createHierarchicalSOPInstanceRefMacro(level+1)
        {level, '0008', '113A', '3',  {}, {}, {}}
        createHierarchicalSOPInstanceRefMacro(level+1)
        {level, '0008', '9092', '1C', {}, {}, {'present', '(0008,1140)'}}
        createHierarchicalSOPInstanceRefMacro(level+1)
        {level, '0008', '9154', '1C', {}, {}, {'present', '(0008,2112)'}}
        createHierarchicalSOPInstanceRefMacro(level+1)
        {level, '0008', '9237', '1C', {}, {}, {'present', '(0008,9237)'}}
        createHierarchicalSOPInstanceRefMacro(level+1)
        {level, '0018', '9004', '1',  {}, {}, {}
         level, '0018', '9100', '1C', {}, {}, {'present', '(0018,9100)'}
         level, '0018', '9064', '1C', {}, {}, {'present', '(0018,9064)'}
         level, '0018', '0087', '1C', {}, {}, {'present', '(0018,0087)'}
         level, '0018', '9174', '1',  {}, {}, {}
         level, '0018', '9175', '3',  {}, {}, {}
         level, '0020', '4000', '3',  {}, {}, {}}
        ];



function macro = createCodeSequenceMacro(level)

contextGroupCondition = {'and', ...
                    {'present', '(0008,010B)'}, ...
                    {'equals', '(0008,010B)', 'Y'}};

CodeSequenceMacro = {...
    '0008', '0100', '1',  {}, {}, {}
    '0008', '0102', '1',  {}, {}, {}
    '0008', '0103', '1C', {}, {}, {'present', '(0008,0103)'}
    '0008', '0104', '1',  {}, {}, {}
    '0008', '010F', '3',  {}, {}, {}
    '0008', '0117', '3',  {}, {}, {}
    '0008', '0105', '1C', {}, {}, {'present', '(0008,010F)'}
    '0008', '0106', '1C', {}, {}, {'present', '(0008,010F)'}
    '0008', '010B', '3',  {}, {}, {}
    '0008', '0107', '1C', {}, {}, contextGroupCondition
    '0008', '010D', '1C', {}, {}, contextGroupCondition
    };

n = size(CodeSequenceMacro, 1);
macro = [repmat({level}, [n 1]), CodeSequenceMacro];



function macro = createHL7v2HierarchicDesignator(level)

designatorMacro = {...
    '0040', '0031', '1C', {}, {}, {'not', {'present', '(0040,0032)'}}
    '0040', '0032', '1C', {}, {}, {'not', {'present', '(0040,0031)'}}
    '0040', '0033', '1C', {}, {}, {'present', '(0040,0032)'}
    };

n = size(designatorMacro, 1);
macro = [repmat({level}, [n 1]), designatorMacro];



function macro = createContentItemMacro(level)

ContentItemMacro = [...
    {level, '0040', 'A040', '1',  {}, {}, {}
     level, '0040', 'A043', '1',  {}, {}, {}}
    createCodeSequenceMacro(level+1)
    {level, '0040', 'A120', '1C', {}, {}, {'equal', '(0040,A040)', 'DATETIME'}
     level, '0040', 'A121', '1C', {}, {}, {'equal', '(0040,A040)', 'DATE'}
     level, '0040', 'A122', '1C', {}, {}, {'equal', '(0040,A040)', 'TIME'}
     level, '0040', 'A123', '1C', {}, {}, {'equal', '(0040,A040)', 'PNAME'}
     level, '0040', 'A124', '1C', {}, {}, {'equal', '(0040,A040)', 'UIDREF'}
     level, '0040', 'A160', '1C', {}, {}, {'equal', '(0040,A040)', 'TEXT'}
     level, '0040', 'A168', '1C', {}, {}, {'equal', '(0040,A040)', 'CODE'}}
    createCodeSequenceMacro(level+1)
    {level, '0040', 'A30A', '1C', {}, {}, {'equal', '(0040,A040)', 'NUMERIC'}
     level, '0040', '08EA', '1C', {}, {}, {'equal', '(0040,A040)', 'NUMERIC'}}
    createCodeSequenceMacro(level+1)
    {level, '0040', '1199', '1C', {}, {}, {'or', ...
                    {'equal', '(0040,A040)', 'COMPOSITE'}, ...
                    {'equal', '(0040,A040)', 'IMAGE'}}
     level+1, '0008', '1150', '1',  {}, {}, {}
     level+1, '0008', '1155', '1',  {}, {}, {}
     level+1, '0008', '1160', '1C', {}, {}, {'present', '0008', '1160'}
     level+1, '0062', '000B', '1C', {}, {}, {'present', '0062', '000B'}}
    ];



function macro = createHierarchicalSOPInstanceRefMacro(level)

% See PS 3.3 Table C.17-3
macro = [...
    {level, '0020', '000D', '1',  {}, {}, {}
     level, '0008', '1115', '1',  {}, {}, {}}
    createHierarchicalSeriesRefMacro(level+1)
    ];



function macro = createHierarchicalSeriesRefMacro(level)

% See PS 3.3 Table C.17-3a
macro = [...
    {level, '0020', '000E', '1',  {}, {}, {}
     level, '0008', '0054', '3',  {}, {}, {}
     level, '0040', 'E011', '3',  {}, {}, {}
     level, '0088', '0130', '3',  {}, {}, {}
     level, '0088', '0140', '3',  {}, {}, {}
     level, '0008', '1199', '1',  {}, {}, {}}
    createSOPInstanceRefMacro(level+1)
    {level+1, '0040', 'A170', '3', {}, {}, {}}
    createCodeSequenceMacro(level+2)
    {level+1, '0400', '0402', '3', {}, {}, {}
     level+2, '0400', '0100', '1', {}, {}, {}
     level+2, '0400', '0120', '1', {}, {}, {}
     level+1, '0400', '0403', '3', {}, {}, {}
     level+2, '0400', '0010', '1', {}, {}, {}
     level+2, '0400', '0015', '1', {}, {}, {}
     level+2, '0400', '0020', '1', {}, {}, {}
     level+2, '0400', '0404', '1', {}, {}, {}}
    ];



function macro = createSOPInstanceRefMacro(level)

% See PS 3.3 Table 10-11
macro = {...
    level, '0008', '1150', '1', {}, {}, {}
    level, '0008', '1155', '1', {}, {}, {}
    };



function macro = createMRImageDescription(level)

% See PS 3.3 Table C.8-82
macro = {...
    level, '0008', '9208', '1', {}, {}, {}
    level, '0008', '9209', '1', {}, {}, {}
    };


function macro = createPixelMeasuresMacro(level)

% See PS 3.3 Sec. C.7.6.16.2.1
macro = {...
    level,   '0028', '9110', '1C', {}, {}, {'present', '(0028,9110)'}
    level+1, '0028', '0030', '1C', {}, {}, {'present', '(0028,0030)'}
    level+1, '0018', '0050', '1C', {}, {}, {'present', '(0018,0050)'}
    };


function macro = createFrameContentMacro(level)

% See PS 3.3 Sec. C.7.6.16.2.2
n = level+1;
macro = {...
    level, '0028', '9111', '1C', {}, {}, {'present', '(0028,9111)'}
    n,     '0020', '9156', '3',  {}, {}, {}
    n,     '0018', '9151', '1C', {}, {}, {'present', '(0018,9151)'}
    n,     '0018', '9074', '1C', {}, {}, {'present', '(0018,9074)'}
    n,     '0018', '9220', '1C', {}, {}, {'present', '(0018,9220)'}
    n,     '0018', '9236', '3',  {}, {}, {}
    n,     '0018', '9214', '3',  {}, {}, {}
    n,     '0020', '9157', '1C', {}, {}, {'present', '(0020,9157)'}
    n,     '0020', '9128', '1C', {}, {}, {'present', '(0020,9128)'}
    n,     '0020', '9056', '1C', {}, {}, {'present', '(0020,9056)'}
    n,     '0020', '9057', '1C', {}, {}, {'present', '(0020,9056)'}
    n,     '0020', '9158', '3',  {}, {}, {}
    n,     '0020', '9453', '3',  {}, {}, {}
    };


function macro = createPlanePositionPatientMacro(level)

% See PS 3.3 Sec. C.7.6.16.2.3
macro = {...
    level,   '0020', '9113', '1C', {}, {}, {'present', '(0020,9113)'}
    level+1, '0020', '0032', '1C', {}, {}, {'present', '(0020,0032)'}
    };



function terms = modalityTerms
%MODALITYDEFINEDTERMS   Modality defined terms
%
%   See PS 3.3 Sec. C.7.3.1.1.1

terms = {'CR', 'MR', 'US', 'BI', 'DD', 'ES', 'MA', 'PT', 'ST', 'XA', ...
         'RTIMAGE', 'RTSTRUCT', 'RTRECORD', 'DX', 'IO', 'GM', 'XC', 'AU', ...
         'EPS', 'SR', 'CT', 'NM', 'OT', 'CD', 'DG', 'LS', 'MS', 'RG', 'TG', ...
         'RF', 'RTDOSE', 'RTPLAN', 'HC', 'MG', 'PX', 'SM', 'PR', 'ECG', ...
         'HD'};



function terms = bodyPartTerms
%BODYPARTTERMS  Body part defined terms
%
%   See PS 3.3 Sec. C.7.3.1

terms = {'SKULL', 'CSPINE', 'TSPINE', 'LSPINE', 'SSPINE', 'COCCYX', 'CHEST', ...
         'CLAVICLE', 'BREAST', 'ABDOMEN', 'PELVIS', 'HIP', 'SHOULDER', ...
         'ELBOX', 'KNEE', 'ANKLE', 'HAND', 'FOOT', 'EXTREMITY', 'HEAD', ...
         'HEART', 'NECK', 'LEG', 'ARM', 'JAW'};



function terms = patientPositionTerms
%PATIENTPOSITIONTERMS  Patient position defined terms
%
%   See PS 3.3 Sec. C.7.3.1.1.2

terms = {'HFP', 'HFS', 'HFDR', 'HFDL', 'FFDR', 'FFDL', 'FFP', 'FFS'};



function terms = conversionTerms
%CONVERSIONTERMS  Secondary Capture conversion type defined terms
%
%   See PS 3.3 Sec. C.8.6.1

terms = {'DV', 'DI', 'DF', 'WSD', 'SD', 'SI', 'DRW', 'SYN'};



function terms = transducerTerms
%TRANSDUCERTERMS  Transducer type defined terms
%
%   See PS 3.3 Sec. C.8.5.6

terms = {'SECTOR_PHASED', 'SECTOR_MECH', 'SECTOR_ANNULAR', 'LINEAR', ...
         'CURVED LINEAR', 'SINGLE CRYSTAL', 'SPLIT XTAL CWD', 'IV_PHASED', ...
         'IV_ROT XTAL', 'IV_ROT MIRROR', 'ENDOCAV_PA', 'ENDOCAV_MECH', ...
         'ENDOCAV_CLA', 'ENDOCAV_AA', 'ENDOCAV_LINEAR', 'VECTOR_PHASED'};



function tmers = frameIncrementTerms
%FRAMEINCREMENTTERMS  Frame increment pointer defined values
%
%   See PS 3.3 Sec. C.8.5.6.1.4

terms = {uint16(sscanf('0018 1063', '%x')'), ...
         uint16(sscanf('0018 1065', '%x')')};



function terms = scanOptionsTerms
%SCANOPTIONSTERMS  Scan Options defined terms
%
%   See PS 3.3 Sec. C.8.7.1.1.4

terms = {'EKG', 'PHY', 'TOMO', 'CHASE', 'STEP', 'ROTA'};
        


function terms = curveTypeTerms
%CURVETYPETERMS  Type of Data for curves defined terms
%
%   See PS 3.3 Sec. C.10.2.1.1

terms = {'TAC', 'PROF', 'HIST', 'ROI', 'TABL', 'FILT', 'POLY', 'ECG', ...
         'PRESSURE', 'FLOW', 'PHYSIO', 'RESP'};



function terms = axisUnitsTerms
%AXISUNITSTERMS  Axis Units defined terms
%
%   See PS 3.3 Sec. C.10.2.1.3

terms = {'SEC', 'CNTS', 'MM', 'PIXL', 'NONE', 'BPM', 'CM', 'CMS', 'CM2', ...
         'CM2S', 'CM3', 'CM3S', 'CMS2', 'DB', 'DBS', 'DEG', 'GM', 'GMM2', ...
         'HZ', 'IN', 'KG', 'LMIN', 'LMINM2', 'M2', 'MS2', 'MLM2', 'MILS', ...
         'MILV', 'MMHG', 'PCNT', 'LB'};



function lut = curveVRlut
%CURVEVRLUT   VR lookup table for curve-related data

lut = {'(50xx,0103)', {0, 'US'}, {1, 'SS'}, {2, 'FL'}, {3, 'FD'}, {4, 'SL'}};
