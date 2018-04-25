function metadata = niftiinfo(filename)
%NIFTIINFO Read metadata from NIfTI file.
%   METADATA = NIFTIINFO(FILENAME) reads the header of the NIfTI file named
%   in the string or character vector FILENAME and returns all its contents
%   in a MATLAB structure called METADATA. If the file extension is not
%   specified, NIFTIINFO looks for a '.nii' file or its gzipped version
%   (with extension '.nii.gz'). If that is not found, it looks for a '.hdr'
%   file or its gzipped version (with extension '.hdr.gz'), and then a
%   '.img' file or its gzipped version (with extension '.img.gz'). If it
%   cannot find any of these files, NIFTIINFO returns an error.
%
%   References:
%   -----------
%   [1] Cox, R.W., Ashburner, J., Breman, H., Fissell, K., Haselgrove, C.,
%   Holmes, C.J., Lancaster, J.L., Rex, D.E., Smith, S.M., Woodward, J.B.
%   and Strother, S.C., 2004. A (sort of) new image data format standard:
%   Nifti-1. Neuroimage, 22, p.e1440.
%
%   Example 1
%   ---------
%   %Viewing metadata fields from a NIfTI header file.
%
%   % Load metadata from 'brain.nii'.
%   info = niftiinfo('brain.nii');
%
%   % Display the pixel dimensions of this file
%   info.PixelDimensions
%
%   % Display the raw header content
%   info.raw
% 
%   % Display the intent code from the raw structure
%   info.raw.intent_code
%
%   See also NIFTIREAD, NIFTIWRITE.

%   Copyright 2016-2017 The MathWorks, Inc.

    narginchk(1,1);
    filename = matlab.images.internal.stringToChar(filename);
    NF = images.internal.nifti.niftiFile(filename);
    
    fileDetails = dir(NF.HeaderFileName);
    metadata.Filename = fullfile(fileDetails.folder, fileDetails.name);
    metadata.Filemoddate = fileDetails.date;
    metadata.Filesize = fileDetails.bytes;
    NV = images.internal.nifti.niftiImage(NF.FileWithHeader);

    % Get the simplified structure from niftiImage.
    simpleStruct = NV.simplifyStruct();
    % Copy simplified fields into metadata.
    fields = fieldnames(simpleStruct);
    for i = 1:numel(fields)
        metadata.(fields{i}) = simpleStruct.(fields{i});
    end
    % Finally. append the raw struct to fileInfo.
    metadata.raw = NV.header;
end