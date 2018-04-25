function dicomBrowser(source)
%dicomBrowser  Explore collection of DICOM files.
%   dicomBrowser launches an interactive app for exploring the contents of
%   collections of DICOM files. Images are sorted by study and series.
%
%   dicomBrowser(DIR) gathers details about the files in the directory DIR
%   and its subfolders.
%
%   dicomBrowser(DICOMDIR) gathers deatails from the DICOM directory file
%   referenced in DICOMDIR, which can contain a full path name, a relative
%   path name to the file, or the name of a file on the MATLAB search path.
%
%   Examples:
%   ---------
%   % 1 - Explore by directory name.
%   dicomBrowser(fullfile(matlabroot, 'toolbox/images/imdata'))
%
%   % 2 - Explore by DICOMDIR file.
%   dicomBrowser(fullfile(matlabroot, 'toolbox/images/imdata/DICOMDIR'))
%
%   See also dicomCollection, dicominfo, dicomread, dicomreadVolume.

% Copyright 2016-2017

if nargin == 0
    images.internal.app.dicom.DICOMBrowser();
else
    validateattributes(source, {'string', 'char', 'table'}, {'nonempty'}, ...
        mfilename, 'SOURCE', 1)
    images.internal.app.dicom.DICOMBrowser(source);
end
end
