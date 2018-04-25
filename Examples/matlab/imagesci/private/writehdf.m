function writehdf(data, map, filename, varargin)
%WRITEHDF Write an raster-image HDF file to disk.
%   WRITEHDF(X,MAP,FILENAME) writes the indexed image X,MAP
%   to the file specified by the string FILENAME.
%
%   WRITEHDF(GRAY,[],FILENAME) writes the grayscale image GRAY
%   to the file.
%
%   WRITEHDF(RGB,[],FILENAME) writes the truecolor image
%   represented by the M-by-N-by-3 array RGB.
%
%   WRITEHDF(..., 'compression', COMP) uses the compression
%   type indicated by the string COMP.  COMP can be 'none',
%   'rle' (for grayscale or indexed images), or 'jpeg'
%   (for grayscale or rgb images).  The default value is
%   'none'.
%
%   WRITEHDF(..., 'compression', 'jpeg', 'quality', QUAL)
%   specifies the quality factor to use with JPEG
%   compression.  100 is best, 0 is worst, and 75 is
%   the default.  Lower values generally result in smaller
%   files.
%
%   WRITEHDF(..., 'writemode', MODE) either writes over
%   an existing HDF file (if MODE is 'overwrite') or appends
%   the image to the existing HDF file (if MODE is 'append').
%   The default is 'overwrite'.

%   Steven L. Eddins, August 1996
%   Copyright 1984-2013 The MathWorks, Inc.

p = inputParser;
p.addRequired('DATA', ...
    @(x)validateattributes(x,{'logical','uint8','single','double'},{'real'},'','DATA'));
p.addRequired('MAP', ...
    @(x)validateattributes(x,{'double','2d'},{'real'},'','MAP'));
p.addRequired('FILENAME', ...
    @(x)validateattributes(x,{'char'},{'nonempty'},'','FILENAME'));
p.addParamValue('compression','none',...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','COMPRESSION VALUE'));
p.addParamValue('quality',75,...
    @(x) validateattributes(x,{'numeric'},{'scalar','>=', 0, '<=', 100},'','QUALITY VALUE'));
p.addParamValue('baseline',1,...
    @(x) validateattributes(x,{'numeric'},{'scalar','>=', 0, '<=', 1},'','BASELINE VALUE'));
p.addParamValue('writemode','overwrite',...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','WRITEMODE VALUE'));

p.parse(data,map,filename,varargin{:});

compressionType = validatestring(p.Results.compression,{'none','rle','jpeg'});
quality = p.Results.quality;
baseline = p.Results.baseline;
writeMode = validatestring(p.Results.writemode,{'append','overwrite'});


if (ndims(data) > 3)
    error(message('MATLAB:imagesci:writehdf:tooManyDims', ndims( data )));
end

% 1 component or 3 components?
ncomp = size(data,3);
if ((ncomp ~= 1) && (ncomp ~= 3))
    error(message('MATLAB:imagesci:writehdf:wrongNumberOfComponents', ncomp));
end

FAIL = -1;
if (ncomp == 1)
    hdf('DFR8', 'restart');
    
    % Convert data to uint8 if necessary
    if (~isa(data, 'uint8'))
        if (isempty(map))
            % Assume intensity image in range [0, 1].
            data = uint8(255*data);
        else
            % Assume indexed image
            data = uint8(data-1);
        end
    end

    if (~isempty(map) && ~isa(map, 'uint8'))
        map = uint8(255*map);
    end
    
    
    if (~isempty(map))
        if (size(map,1) < 256)
            map(256,3) = 0;
        elseif (size(map,1) > 256)
            error(message('MATLAB:imagesci:writehdf:tooManyColormapEntries'));
        end
        status = hdf('DFR8', 'setpalette', map');
    else
        status = hdf('DFR8', 'setpalette', []);
    end
    check_error(status);
    
    if (strcmp(compressionType, 'jpeg'))
        status = hdf('DFR8', 'setcompress', 'jpeg', quality, baseline);
        check_error(status);
    else
        hdf('DFR8', 'setcompress', compressionType);
    end
    
    if (strcmp(writeMode, 'append'))
        status = hdf('DFR8', 'addimage', filename, data', compressionType);
        
    else
        status = hdf('DFR8', 'putimage', filename, data', compressionType);
    end
    check_error(status);
    
else
    % 3 components

    if (strcmp(compressionType, 'rle'))
        error(message('MATLAB:imagesci:writehdf:rleNotSupportedForRgb'));
    end

    if ((isa(data,'double')) || (isa(data,'single')))
        data = uint8(data*255);
    end

    hdf('DF24', 'restart');

    data = permute(data, [3 2 1]);  % HDF API uses C-style element ordering
    
    if (~isempty(map))
        warning(message('MATLAB:imagesci:writehdf:colormapIgnoredForRgb'));
    end
    
    if (strcmp(compressionType, 'jpeg'))
        status = hdf('DF24', 'setcompress', 'jpeg', quality, baseline);
    else
        status = hdf('DF24', 'setcompress', compressionType);
    end
    check_error(status);
            
    status = hdf('DF24', 'setil', 'pixel');
    check_error(status);
    
    if (strcmp(writeMode, 'append'))
        status = hdf('DF24', 'addimage', filename, data);
        
    else
        status = hdf('DF24', 'putimage', filename, data);
    end
    check_error(status);
    
end

%%%
%%% Function hdferror
%%%
function check_error(status)
if status == -1
    str = hdf('HE', 'string', hdf('HE', 'value', 1));
    error(message('MATLAB:imagesci:writehdf:libhdfError', str));
end
