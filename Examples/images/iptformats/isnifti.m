function TF = isnifti(niifilename)
%ISNIFTI Check if a file uses NIfTI.
%   TF = ISNIFTI(FILENAME) checks if the input .nii file is a NIfTI file or
%   not. It returns true if it is, and false otherwise.
%
%   Example 1
%   ---------
%   This example checks if a file is indeed a NIfTI file.
%   TF = isnifti('brain.nii');
%
%   See also NIFTIINFO, NIFTIREAD, NIFTIWRITE.

%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within other toolbox classes and
%   functions. Its behavior may change, or the feature itself may be
%   removed in a future release.

% Copyright 2017 The MathWorks, Inc.

if nargin > 0
    niifilename = convertStringsToChars(niifilename);
end

TF = true;
try
    niftiinfo(niifilename);
catch
    TF = false;
end

end