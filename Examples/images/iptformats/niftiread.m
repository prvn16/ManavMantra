function V = niftiread(varargin)
%NIFTIREAD Read NIfTI image.
%   V = NIFTIREAD(FILENAME) reads the image data from the NIfTI file named
%   using the string or character vector FILENAME from the current
%   directory or on the path, and returns volumetric data in V. If the file
%   extension is not specified, this function will look for a '.nii' file
%   or its gzipped version (with extension '.nii.gz'). If that is not
%   found, it looks for a '.hdr' file or its gzipped version (with
%   extension '.hdr.gz'), and then a '.img' file or its gzipped version
%   (with extension '.img.gz').
%
%   V = NIFTIREAD(HEADERFILE, IMAGEFILE) reads a NIfTI file pair,
%   represented by a .hdr or a .hdr.gz file called HEADERFILE and a .img or
%   a .img.gz file called IMAGEFILE, and returns volumetric data in V.
% 
%   V = NIFTIREAD(INFO) reads a NIfTI file described by the structure INFO
%   returned by niftiinfo, and returns volumetric data in V.
%
%   The output V is a numeric matrix containing the volume referred to by
%   the input filename.
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
%   % This example loads a volume from a .nii file using its filename.
%
%   % Load a NIfTI image using it's .nii filename.
%   V = niftiread('brain.nii');
% 
%   % Visualize the volume
%   volumeViewer(V)
%
%   Example 2
%   ---------
%   % Read the header structure, and then load the image using it.
%
%   info = niftiinfo('brain.nii');
%
%   % Read the volume using this info structure.
%   V = niftiread(info);
%   
%   % Visualize the volume
%   volumeViewer(V)
%
%   See also NIFTIINFO, NIFTIWRITE.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(1,2);
varargin = matlab.images.internal.stringToChar(varargin);

if isstruct(varargin{1}) % the info syntax.
    infoIn = varargin{1};
    if isfield(infoIn, 'Filename')
        NF = images.internal.nifti.niftiFile(infoIn.Filename);
    else
        error(message('images:nifti:invalidStructSpecified'))
    end
else
    NF = images.internal.nifti.niftiFile(varargin{:});
end

NV = images.internal.nifti.niftiImage(NF.FileWithHeader);
NV.readVolume(NF.FileWithImage);
V = NV.img;

end