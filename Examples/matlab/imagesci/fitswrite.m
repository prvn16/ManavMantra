function fitswrite(imagedata,filename,varargin)
%FITSWRITE Write image to FITS file.
%   fitswrite(IMAGEDATA,FILENAME) writes IMAGEDATA to the FITS file
%   specified by FILENAME.  If FILENAME does not exist, it is created as a
%   simple FITS file.  If FILENAME does exist, it is either overwritten or
%   the image is appended to the end of the file.
%
%   fitswrite(...,'PARAM','VALUE') writes IMAGEDATA to the FITS file
%   according to the specified parameter value pairs.  The parameter names
%   are as follows:
%
%       'WriteMode'    One of these strings: 'overwrite' (the default)
%                      or 'append'. 
%
%       'Compression'  One of these strings: 'none' (the default), 'gzip', 
%                      'gzip2', 'rice', 'hcompress', or 'plio'.
%
%   Please read the file cfitsiocopyright.txt for more information.
%
%   Example:  Create a FITS file the red channel of an RGB image.
%       X = imread('ngc6543a.jpg');
%       R = X(:,:,1); 
%       fitswrite(R,'myfile.fits');
%       fitsdisp('myfile.fits');
%
%   Example:  Create a FITS file with three images constructed from the
%   channels of an RGB image.
%       X = imread('ngc6543a.jpg');
%       R = X(:,:,1);  G = X(:,:,2);  B = X(:,:,3);
%       fitswrite(R,'myfile.fits');
%       fitswrite(G,'myfile.fits','writemode','append');
%       fitswrite(B,'myfile.fits','writemode','append');
%       fitsdisp('myfile.fits');
%
%   See also FITSREAD, FITSINFO, MATLAB.IO.FITS.

%   Copyright 2011-2017 The MathWorks, Inc.


p = inputParser;

datatypes = {'uint8','int16','int32','int64','single','double'};
p.addRequired('imagedata',@(x) validateattributes(x,datatypes,{'nonempty'}));
p.addRequired('filename', ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','FILENAME'));

p.addParamValue('writemode','overwrite', ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','WRITEMODE'));

p.addParamValue('compression','none', ...
     @(x) validateattributes(x,{'char'},{'nonempty'},'','COMPRESSION'));

p.parse(imagedata,filename,varargin{:});

mode = validatestring(p.Results.writemode,{'overwrite','append'});
compscheme = validatestring(p.Results.compression, ...
    {'gzip','gzip2','rice','hcompress','plio','none'});

import matlab.io.*
if strcmpi(mode,'append')
    try
        fptr = fits.openDiskFile(filename,'readwrite');
    catch ME
        try
            [~, ~, hasExtSyntax] = matlab.io.fits.internal.resolveExtendedFileName(filename);
        catch
            throw(ME);
        end
        if hasExtSyntax
            error(message('MATLAB:imagesci:fitswrite:fileOpenExtSyntax'));
        end
    end
else
    if exist(filename,'file')
        delete(filename);
    end
    fptr = fits.createFile(filename);
end


try
    if ~strcmpi(compscheme,'none')
        fits.setCompressionType(fptr,compscheme);
    end
    
    fits.createImg(fptr,class(imagedata),size(imagedata));
    fits.writeImg(fptr,imagedata);
    
catch me
    fits.closeFile(fptr);
    rethrow(me);
end

fits.closeFile(fptr);
