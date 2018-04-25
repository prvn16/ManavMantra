function writepng(data, map, filename, varargin)
%WRITEPNG Write a PNG file to disk.
%   WRITEPNG(I,[],FILENAME) writes the grayscale image I
%   to the file specified by the string FILENAME.
%
%   WRITEPNG(RGB,[],FILENAME) writes the truecolor image
%   represented by the M-by-N-by-3 array RGB.
%
%   WRITEPNG(X,MAP,FILENAME) writes the indexed image X with
%   colormap MAP.  The resulting file will contain the equivalent
%   truecolor image.
%
%   WRITEPNG(...,PARAM,VAL,...) sets the specified parameters.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2014 The MathWorks, Inc.

% Parse the inputs 
[results, unmatched] = parseInputs(data,map,filename,varargin{:});

if ((ndims(data) > 3) || (~ismember(size(data,3), [1 3])))
    error(message('MATLAB:imagesci:writepng:wrongImageDimensions'));
end

alpha = results.alpha;

% Identify color type
isTruecolor = (size(data,3) == 3);
paletteUsed = ~isempty(map) && ~isTruecolor;
colorUsed = paletteUsed || isTruecolor;
alphaUsed = ~isempty(alpha);
colortype = paletteUsed + 2*colorUsed + 4*alphaUsed;
if (colortype == 7)
    error(message('MATLAB:imagesci:writepng:alphaNotSupportedForIndexed'));
end

% Set default bitdepth if not specified
bitdepth = results.bitdepth;
if (isempty(bitdepth))
    switch class(data)
        case 'logical'
            bitdepth = 1;
            
        case {'uint8', 'double', 'single'}
            bitdepth = 8;
            
        case 'uint16'
            bitdepth = 16;
    end
end


% Color type values (as in PNG library defs)
PNG_COLOR_TYPE_GRAY = 0;
PNG_COLOR_TYPE_RGB = 2;
PNG_COLOR_TYPE_PALETTE = 3;
PNG_COLOR_TYPE_GRAY_ALPHA = 4;
PNG_COLOR_TYPE_RGB_ALPHA = 6;


% Validate bitdepth
switch colortype
    case PNG_COLOR_TYPE_GRAY
        if (~ismember(bitdepth, [1 2 4 8 16]))
            error(message('MATLAB:imagesci:writepng:invalidGrayscaleBitDepth'));
        end
        
    case { PNG_COLOR_TYPE_RGB, PNG_COLOR_TYPE_RGB_ALPHA }
        if (~ismember(bitdepth, [8 16]))
            error(message('MATLAB:imagesci:writepng:invalidRgbBitDepth'));
        end
        
    case PNG_COLOR_TYPE_PALETTE
        if (~ismember(bitdepth, [1 2 4 8]))
            error(message('MATLAB:imagesci:writepng:invalidIndexedBitDepth'));
        end
        
    case PNG_COLOR_TYPE_GRAY_ALPHA
        if (~ismember(bitdepth, [8 16]))
            error(message('MATLAB:imagesci:writepng:invalidGrayscaleAlphaBitDepth'));
        end
        
end

%
% Scale image if necessary to match requested bitdepth
%
switch class(data)
    case {'double', 'single'}
        if (colortype == PNG_COLOR_TYPE_PALETTE)
            data = data - 1;
            data = uint8(data);
            
        else
            % Grayscale or RGB; clamp data to [0,1] dynamic range before
            % scaling, rounding, and casting.
            data = max(min(data,1),0);
            switch bitdepth
                case 8
                    data = uint8(255*data);
                    
                case 16
                    data = uint16(65535*data);
                    
                case 4
                    data = uint8(15*data);
                    
                case 2
                    data = uint8(3*data);
                    
                case 1
                    data = uint8(data ~= 0);
            end
        end
        
    case 'uint8'
        if (colortype == PNG_COLOR_TYPE_PALETTE)
            % Nothing to do
            
        else
            switch bitdepth
                case 16
                    data = uint16(data);
                    data = bitor(bitshift(data,8),data);
                    
                case 8
                    % Nothing to do
                    
                case 4
                    data = bitshift(data,-4);
                    
                case 2
                    data = bitshift(data,-6);
                    
                case 1
                    % Nothing to do
            end
        end
        
    case 'uint16'
        switch bitdepth
            case 16
                % Nothing to do
                
            case 8
                data = uint8(bitshift(data,-8));
                
            case 4
                data = uint8(bitshift(data,-12));
                
            case 2
                data = uint8(bitshift(data,-14));
                
            case 1
                data = uint8(data ~= 0);
        end
end

if (ismember(colortype, [PNG_COLOR_TYPE_GRAY_ALPHA, ...
        PNG_COLOR_TYPE_RGB_ALPHA]))
    %
    % Scale alpha data if necessary to match data class
    %
    switch bitdepth
        case 8
            switch class(alpha)
                case {'double', 'single'}
                    alpha = max(min(alpha,1),0);
                    alpha = uint8(255 * alpha);
                    
                case 'uint16'
                    alpha = uint8(bitshift(alpha, -8));
                    
                case 'uint8'
                    % nothing to do
                    
            end
            
        case 16
            switch class(alpha)
                case {'double', 'single'}
                    alpha = max(min(alpha,1),0);
                    alpha = uint16(65535 * alpha);
                    
                case 'uint16'
                    % nothing to do
                    
                case 'uint8'
                    alpha = uint16(alpha);
                    alpha = bitor(bitshift(alpha, 8), alpha);
                    
            end
    end
end

sigbits        = results.significantbits;
transparency   = results.transparency;
background     = results.background;
gamma          = results.gamma;
chromaticities = results.chromaticities;
xres           = results.xresolution;
yres           = results.yresolution;
if ischar(results.resolutionunit)
    resunit        = validatestring(results.resolutionunit,{'unknown','meter'});
else
    resunit = results.resolutionunit;
end
interlace      = validatestring(results.interlacetype,{'none','adam7'});
imagemodtime   = results.imagemodtime;

textchunks = cell(0,2);
strs = {'Title','Author','Description','Copyright','Software', ...
    'Disclaimer', 'Warning','Source','Comment'};
for j = 1:numel(strs)
    param_name = lower(strs{j});
    if isfield(results,lower(param_name))
        param_value = results.(param_name);
        if ~isempty(param_value)
            textchunks{end+1,1} = strs{j}; %#ok<AGROW>
            textItem = CheckTextItem(param_value);
            textchunks{end,2} = textItem;
        end
    end
end


if ~isempty(results.creationtime)
    keyword = 'Creation Time';
    ctime = results.creationtime;
    if ischar(ctime)
        textItem = datestr(datenum(ctime), 0);
    else
        textItem = datestr(ctime, 0);
    end
    textchunks{end+1,1} = keyword;
    textchunks{end,2} = textItem;
end
if ~isempty(results.imagemodtime)
    try
        imagemodtime = fix(datevec(results.imagemodtime));
    catch me
        error(message('MATLAB:imagesci:writepng:invalidImageModTime'));
    end
    
    if (numel(imagemodtime) > 6)
        error(message('MATLAB:imagesci:writepng:tooMuchImageModTimeData'))
    end
end

% validate and process any unmatched parameters.
if ~isempty(unmatched)
    param_names = fields(unmatched);
    nelts = numel(param_names);
    for j = 1:nelts
        param_name = param_names{j};
        keyword = CheckKeyword(param_name);
        item = CheckTextItem(unmatched.(param_name));
        textchunks{end+1,1} = keyword; %#ok<AGROW>
        textchunks{end,2} = item;
    end
end

% Be friendly about specifying resolutions
if (~isempty(xres) && isempty(yres))
    yres = xres;
    
elseif (~isempty(yres) && isempty(xres))
    xres = yres;
end

if (~isempty(xres) && isempty(resunit))
    resunit = 'unknown';
end

if (isempty(xres) && isempty(yres) && ~isempty(resunit))
    error(message('MATLAB:imagesci:writepng:resolutionsRequired'));
end

pngwritec(data, map, filename, colortype, bitdepth, ...
    sigbits, alpha, interlace, ...
    transparency, background, gamma, ...
    chromaticities, xres, yres, ...
    resunit, textchunks, imagemodtime);


function [results, unmatched] = parseInputs(data,map,filename,varargin)

% Validate required arguments
validateattributes(data,{'double','single','logical','uint8','uint16'},{'nonempty'});
if isempty(map)
    validateattributes(map,{'double'},{});
else
    validateattributes(map,{'double'},{'2d','ncols',3,'>=',0,'<=',1});
end
validateattributes(filename,{'char'},{'row','nonempty'});

propStrings = {'interlacetype', 'imagemodtime', ...
    'transparency', 'bitdepth', 'significantbits', 'alpha', ...
    'background',   'gamma',    'xresolution',     'chromaticities', ...
    'yresolution',  'title',    'author',          'resolutionunit', ...
    'description',  'source',   'software',        'creationtime',  ...
    'disclaimer',   'warning',  'copyright',       'comment' };

% Process varargin into a form that we can use with the input parser.
for k = 1:2:length(varargin)
    prop = lower(varargin{k});
    if (~ischar(prop))
        error(message('MATLAB:imagesci:writepng:parameterNotString'));
    end
    
    idx = find(strncmp(prop, propStrings, numel(prop)));
    if (length(idx) > 1)
        error(message('MATLAB:imagesci:validate:ambiguousParameterName', prop));
    elseif isscalar(idx)
        varargin{k} = propStrings{idx};
    end
end

% Define the parser
p = inputParser;
p.KeepUnmatched = true;

% Add PV pairs to the input parser
p.addParamValue('bitdepth',[],       @(x)validateattributes(x,{'double'},{'scalar'}));
p.addParamValue('significantbits',[],@(x)validateattributes(x,{'double'},{'nonempty','>=',1}));
p.addParamValue('transparency',[],   @(x)validateattributes(x,{'double'},{'>=',0,'<=',1}));
p.addParamValue('alpha',[],          @(x)validateattributes(x,{'double','uint8','uint16'},{'size',[size(data,1) size(data,2)]}));
p.addParamValue('background',[],     @(x)validateattributes(x,{'char','double'},{'row','nonempty'}));
p.addParamValue('gamma',[],          @(x)validateattributes(x,{'double'},{'scalar','>=',0}));
p.addParamValue('chromaticities',[], @(x)validateattributes(x,{'double'},{'row','numel',8,'>=',0,'<=',1}));
p.addParamValue('xresolution',[],    @(x)validateattributes(x,{'double'},{'scalar'}));
p.addParamValue('yresolution',[],    @(x)validateattributes(x,{'double'},{'scalar'}));
p.addParamValue('title',[],          @(x)validateattributes(x,{'char'},{'nonempty'}));
p.addParamValue('author',[],         @(x)validateattributes(x,{'char'},{'nonempty'}));
p.addParamValue('description',[],    @(x)validateattributes(x,{'char'},{'nonempty'}));
p.addParamValue('copyright',[],      @(x)validateattributes(x,{'char'},{'nonempty'}));
p.addParamValue('software',[],       @(x)validateattributes(x,{'char'},{'nonempty'}));
p.addParamValue('disclaimer',[],     @(x)validateattributes(x,{'char'},{'nonempty'}));
p.addParamValue('warning',[],        @(x)validateattributes(x,{'char'},{'nonempty'}));
p.addParamValue('source',[],         @(x)validateattributes(x,{'char'},{'nonempty'}));
p.addParamValue('comment',[],        @(x)validateattributes(x,{'char'},{'nonempty'}));
p.addParamValue('creationtime',[],   @(x)validateattributes(x,{'char','double'},{'nonempty'}));
p.addParamValue('imagemodtime',[],   @(x)validateattributes(x,{'char','double'},{'nonempty'}));
p.addParamValue('interlacetype','none', @(x) validateattributes(x,{'char'},{'row'}));
p.addParamValue('resolutionunit',[], @(x)validateattributes(x,{'char'},{'nonempty'}));

% Parse remaining arguments and return results and unmatched
p.parse(varargin{:});
results = p.Results;
unmatched = p.Unmatched;


function out = CheckKeyword(in)
%CheckKeyword
%   out = CheckKeyWord(in) checks the validity of the input text chunk keyword.

if ((in(1) == 32) || (in(end) == 32))
    error(message('MATLAB:imagesci:writepng:paddedTextChunkKeyword'));
end
if (numel(in) > 80)
    error(message('MATLAB:imagesci:writepng:tooMuchKeywordData'));
end
if (any(~ismember(in,[32:126 161:255])))
    error(message('MATLAB:imagesci:writepng:invalidCharsInTextChunkKeyword'));
end

out = in;


function out = CheckTextItem(in)
%CheckTextItem
%   out = CheckTextItem(in) strips out control characters from text; PNG spec
%   discourages them.  It also replaces [13 10] by 10; then it replaces 13
%   by 10.  The PNG spec says newlines must be represented by a single 10.

if (~ischar(in))
    error(message('MATLAB:imagesci:writepng:invalidTextChunk'));
end

out = in;
out = strrep(out, char([13 10]), char(10));
out = strrep(out, char(13), char(10));
badChars = find((out < 32) & (out ~= 10));
if (~isempty(badChars))
    warning(message('MATLAB:imagesci:writepng:changedTextChunk'));
    out(badChars) = [];
end
