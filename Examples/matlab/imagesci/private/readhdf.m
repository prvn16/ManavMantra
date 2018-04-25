function [X,map] = readhdf(filename, ref)
%READHDF Read an image from an HDF file.
%   [X,MAP] = READHDF(FILENAME) reads the first raster image data
%   set from the HDF file FILENAME.  X will be a 2-D uint8 array
%   if the specified data set contains an 8-bit image.  It will
%   be an M-by-N-by-3 uint8 array if the specified data set
%   contains a 24-bit image.  MAP may be empty if the data set
%   does not have an associated colormap.
%
%   ... = READHDF(FILENAME, ref) reads the raster
%   image data set with the specified reference number.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, June 1996
%   Copyright 1984-2013 The MathWorks, Inc.

info = imhdfinfo(filename);

if (nargin < 2)
    idx = 1;   % ref not specified, so get the first one.
else
    refNums = [info.Reference];            % comma-separated list syntax
    idx = find(ref == refNums);
    if (isempty(idx))
        error(message('MATLAB:imagesci:readhdf:noRasterAtReference'));
    end
    idx = idx(1);
end

ref = info(idx).Reference;
ncomp = info(idx).NumComponents;

FAIL = -1;

if (ncomp == 1)
    hdfdfr8('restart');

    status = hdfdfr8('readref', filename, ref);
    if (status == FAIL)
        error(message('MATLAB:imagesci:readhdf:libhdfError', hdferror));
    end
    
    [X, map, status] = hdfdfr8('getimage', filename);
    if (status == FAIL)
        error(message('MATLAB:imagesci:readhdf:libhdfError', hdferror));
    end
    
    X = X';  % HDF uses C-style dimension ordering
    map = double(map')/255;
    
elseif (ncomp == 3)
    hdf('DF24', 'restart');
    
    status = hdfdf24('reqil', 'pixel');
    if (status == FAIL)
        error(message('MATLAB:imagesci:readhdf:libhdfError', hdferror));
    end
    
    status = hdfdf24('readref', filename, ref);
    if (status == FAIL)
        error(message('MATLAB:imagesci:readhdf:libhdfError', hdferror));
    end
    
    [X, status] = hdfdf24('getimage', filename);
    if (status == FAIL)
        error(message('MATLAB:imagesci:readhdf:libhdfError', hdferror));
    end
    
    % Compensate for pixel interlace and the fact that
    % HDF uses C-style dimension ordering
    X = permute(X,[3 2 1]);
        
    map = [];
    
else
    error(message('MATLAB:imagesci:readhdf:wrongNumberOfComponents'));
    
end

%%%
%%% Function hdferror
%%%
function str = hdferror()
%HDFERROR The current HDF error string.

str = hdf('HE', 'string', hdf('HE', 'value', 1));
