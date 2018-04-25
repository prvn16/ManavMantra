% Image Processing Toolbox --- File Formats
%
% Analyze 7.5
%   analyze75info  - Read metadata from header file of Mayo Analyze 7.5 data set.
%   analyze75read  - Read the image file of Mayo Analyze 7.5 data set.
%
% DICOM
%   dicomanon           - Anonymize DICOM file.
%   dicomBrowser        - Explore collection of DICOM files.
%   dicomCollection     - Gather details about related series of DICOM files.
%   dicomdict           - Get or set active DICOM data dictionary.
%   dicomdisp           - Display DICOM file structure.
%   dicominfo           - Read metadata from DICOM message.
%   dicomlookup         - Find attribute in DICOM data dictionary.
%   dicomread           - Read DICOM image.
%   dicomreadVolume     - Construct volume from directory of DICOM images/slices.
%   dicomuid            - Generate DICOM Unique Identifier.
%   dicomwrite          - Write images as DICOM files.
%   dicom-dict.txt      - Text file containing DICOM data dictionary (2007).
%   dicom-dict-2005.txt - Text file containing DICOM data dictionary (2005).
%   isdicom             - Check if file is DICOM.
%   images.dicom.decodeUID     - Get information about Unique Identifier (UID).
%   images.dicom.parseDICOMDIR - Extract metadata from DICOMDIR file.
%
% DPX (Digital Moving-Picture Exchange)
%   dpxinfo        - Read metadata about DPX image.
%   dpxread        - Read DPX image.
%   isdpx          - Check if file is DPX.
%
% High Dynamic Range Imaging
%   hdrread        - Read Radiance HDR image.
%   hdrwrite       - Write Radiance HDR image.
%   makehdr        - Create high dynamic range image.
%   tonemap        - Render high dynamic range image for viewing.
%
% Interfile
%   interfileinfo  - Read metadata from Interfile files.
%   interfileread  - Read images from Interfile files.
%
% National Imagery Transmission Format (NITF)
%   isnitf         - Check if file is NITF.
%   nitfinfo       - Read metadata from NITF file.
%   nitfread       - Read NITF image.
%
% Neuroimaging Informatics Technology Initiative (NIfTI)
%   niftiinfo      - Read metadata from NIfTI file.
%   niftiread      - Read images as NIfTI files.
%   niftiwrite     - Write images as NIfTI files.
%
% Large Data Handling
%   ImageAdapter   - Interface for image format I/O.
%   isrset         - Check if file is reduced-resolution dataset (R-Set).
%   rsetwrite      - Create reduced-resolution dataset (R-Set) from image file.
%
% See also COLORSPACES, IMAGES, IMAGESLIB, IMDEMOS, IMUITOOLS, IPTUTILS.

% Undocumented functions.
%   Copyright 2007-2017 The MathWorks, Inc.
% Undocumented functions.
%   isdicom        - Check if a file uses DICOM.
%   isnifti        - Check if a file uses NIfTI.

%   Copyright 2007-2017 The MathWorks, Inc.
