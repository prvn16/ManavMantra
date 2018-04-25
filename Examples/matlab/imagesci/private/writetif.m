function writetif(data, map, filename, varargin)
%WRITETIF Write a TIF file to disk.
%   WRITETIF(X,MAP,FILENAME) writes the indexed image X,MAP
%   to the file specified by the string FILENAME.
%
%   WRITETIF(GRAY,[],FILENAME) writes the grayscale image GRAY
%   to the file.
%
%   WRITETIF(RGB,[],FILENAME) writes the truecolor image
%   represented by the M-by-N-by-3 array RGB.
%
%   WRITETIF(..., 'compression', COMP) uses the compression
%   type indicated by the string COMP.  COMP can be 'packbits',
%   'ccitt', 'fax3', 'fax4', or 'none'.  'ccitt', 'fax3', and 'fax4'
%   are allowed for logical inputs only.  'packbits' is the default.
%
%   WRITETIF(..., 'description', DES) writes the string contained
%   in DES to the TIFF file as an ImageDescription tag.
%
%   WRITETIF(..., 'resolution', XYRes) uses the scalar in XYRes
%   for the XResolution and YResolution tags.
%
%   WRITETIF(..., 'rowsperstrip', RPS) uses the scalar in RPS for
%   the RowsPerStrip tag.  Specifying too large a value will result in
%   RowsPerStrip being equal to the number of rows in the image.
%
%   WRITETIF(..., 'colorspace', CS) writes a TIFF file using the
%   specified colorspace, either 'rgb', 'icclab', or 'cielab'.  The input
%   image array must be M-by-N-by-3.
%
%   Copyright 1984-2017 The MathWorks, Inc.

if (ndims(data) > 3)
    error(message('MATLAB:imagesci:writetif:tooManyDims', ndims( data )));
end

% 1 component or 3 or 4 (cmyk) components ?
ncomp = size(data,3);
if ((ncomp ~= 1) && (ncomp ~= 3) && (ncomp ~= 4))
    error (message('MATLAB:imagesci:writetif:invalidComponentsNumber', ncomp));
end


[compression, description, resolution, rowsperstrip, writemode, colorspace] ...
    = parse_param_value_pairs ( data, map, varargin{:} );


% JPEG compression requires RowsPerStrip to be a multiple of 8.  It 
% also cannot use logical data.  The library catches this on most, 
% but not all platforms.
if strcmpi(compression,'jpeg')
    if (mod(rowsperstrip,8) ~= 0)
        error(message('MATLAB:imagesci:writetif:badRowsPerStripForJpegCompression'));
    end 
    if isa(data,'logical') 
        error(message('MATLAB:imagesci:writetif:badDatatypeForJpegCompression'));
    end 
end

if (ndims(data) == 3) && (size(data,3) == 3) && ...
        (isequal(colorspace, 'cielab') || isequal(colorspace, 'icclab'))
    if isa(data, 'double')
        % Convert to 8-bit ICCLAB.
        data(:,:,1) = round(data(:,:,1) * 255 / 100);
        data(:,:,2:3) = round(data(:,:,2:3) + 128);
        data = uint8(data);
    end
    
    if isequal(colorspace, 'cielab')
        % Convert to "munged" cielab values before writing them with
        % wtifc.
        data = icclab2cielab(data);
    end
end

% Logical data with more than 1 channel are not supported
if islogical(data) && size(data, 3) ~= 1
    error(message('MATLAB:imagesci:writetif:unsupportedData'));
end


if(isa(data,'double'))
    if (~isempty(map))
        % Zero based indexing for colormaps
        data = uint8(data - 1);
    else
        % Clip and scale double data
        data = min(1, max(0, data));
        data = uint8(255 * data);
    end
elseif ~(isa(data, 'logical') || isa(data, 'uint8') || isa(data, 'uint16'))
    error(message('MATLAB:imagesci:writetif:unsupportedDataType', class( data )));    
end


if (~isempty(map) && ~isa(map,'uint16'))
    map = uint16(65535 * map);
end

%
% Pack up the required tags into a single structure.
required_tags.compression     = lower(compression);
required_tags.description     = description;
required_tags.resolution      = resolution;
required_tags.rowsperstrip    = rowsperstrip;
required_tags.imageHeight     = size(data,1);
required_tags.imageWidth      = size(data,2);
required_tags.samplesPerPixel = size(data,3);

wtifc(data, map, filename, writemode, colorspace, required_tags);



%===============================================================================
function [comp, desc, res, rps, wmode, colorspace] = parse_param_value_pairs ( data, map, varargin )
%
% comp = compression
% res = resolution
% rps = rowsperstrip
% wmode = writemode

default_compression= 'packbits';
if (islogical(data) && (ismatrix(data)) && isempty(map))
    default_compression = 'ccitt';
end
if ismatrix(data)
    default_colorspace = 'gray';
else
    default_colorspace = 'rgb';
end


% Process varargin into a form that we can use with the input parser.
propStrings = {'compression','description','resolution','rowsperstrip','writemode','colorspace'};
for k = 1:2:length(varargin)
    if ischar(varargin{k})
        prop = lower(varargin{k});
        idx = find(strncmp(prop, propStrings, numel(prop)));
        if (numel(idx) > 1)
            error(message('MATLAB:imagesci:validate:ambiguousParameterName', prop));
        elseif isscalar(idx)
            varargin{k} = propStrings{idx};
        end
    end
                                                            
end

p = inputParser;
p.addParamValue('compression',default_compression, ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','COMPRESSION'));
p.addParamValue('description','', ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','DESCRIPTION'));
p.addParamValue('resolution',72, ...
    @(x) validateattributes(x,{'double'},{'nonempty','vector'},'','RESOLUTION'));
p.addParamValue('rowsperstrip',-1, ...
    @(x) validateattributes(x,{'numeric'},{'scalar','>=',1},'','ROWSPERSTRIP'));
p.addParamValue('writemode','overwrite', ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','MODE'));
p.addParamValue('colorspace',default_colorspace, ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','COLORSPACE'));
p.parse(varargin{:});

comp = validatestring(p.Results.compression, ...
    {'packbits','ccitt','deflate','fax3','fax4','jpeg','lzw','none'});
desc = p.Results.description;
res = p.Results.resolution;
rps = p.Results.rowsperstrip;
mode = validatestring(p.Results.writemode,{'overwrite','append'});
if strcmp(mode,'overwrite')
    wmode = 1;
else
    wmode = 0;
end

colorspace = validatestring(p.Results.colorspace,{'gray','rgb','cielab','icclab'});

if ~strcmp(colorspace,'gray') && (ndims(data) ~= 3) && (size(data, 3) ~= 3)
    warning(message('MATLAB:imagesci:writetif:ignoredColorspaceInput'));
end

