function writejp2k(data, map, filename, fmt, varargin)
%WRITEJP2K Internal function facilitating JPEG2000 writes for J2C and JP2.

%   Copyright 2009-2013 The MathWorks, Inc.

% Input checking.
if (ndims(data) > 3)
    error(message('MATLAB:imagesci:writejp2k:tooManyDims', ndims( data )));
end

if (~isempty(map))
    error(message('MATLAB:imagesci:writejp2k:tooManyDimsForIndexed', ndims( data )));
end

if isfloat(data)
    % single/double data is converted to uint8
    maxval = 255;
    data = uint8(maxval * data);
end

props = set_jp2c_props(data,fmt,varargin{:});

writejp2c(data, filename, props);

function props = set_jp2c_props(data,fmt,varargin)
% SET_JP2C_PROPS
%
% Parse input parameters to produce a properties structure.  
%

% "Fix" any partial parameter names.
propStrings = {'compressionratio','comment','mode','progressionorder', ...
    'qualitylayers','reductionlevels','tilesize'};
for j = 1:2:numel(varargin)
    if ischar(varargin{j})
        prop = varargin{j};
        idx = strncmpi(prop,propStrings,numel(prop));
        if any(idx)
            varargin{j} = propStrings{idx};
        end
    end
end


p = inputParser;

cratioValidationFcn = @(x) validateattributes(x,{'numeric'},{'scalar','finite','>=',1},'','COMPRESSIONRATIO');
addParamValue(p,'CompressionRatio',1,cratioValidationFcn);

commentValidationFcn = @(x) ischar(x) || iscellstr(x);
addParamValue(p,'Comment',{},commentValidationFcn);

modeValidationFcn = @(x) validateattributes(x,{'char'},{'nonempty'},'','MODE');
addParamValue(p,'Mode','lossy',modeValidationFcn);

progOrderValidationFcn = @(x) validateattributes(x,{'char'},{'nonempty'},'','PROGRESSIONORDER');
addParamValue(p,'ProgressionOrder','lrcp',progOrderValidationFcn);

qlayersValidationFcn = @(x) validateattributes(x,{'numeric'},{'scalar','integer','>=',1,'<=',20},'','QUALITYLAYERS');
addParamValue(p,'QualityLayers',1,qlayersValidationFcn);

rlevelValidationFcn = @(x) validateattributes(x,{'numeric'},{'scalar','integer','>=',1,'<=',8},'','REDUCTIONLEVELS');
addParamValue(p,'ReductionLevels',-1,rlevelValidationFcn);

tileValidationFcn = @(x) validateattributes(x,{'numeric'},{'integer','numel',2,'>=',128,'<=',intmax},'','TILESIZE');
addParamValue(p,'TileSize',size(data),tileValidationFcn);

parse(p,varargin{:});

props.comment = cellstr(p.Results.Comment);
props.cratio = p.Results.CompressionRatio;
props.mode = validatestring(p.Results.Mode,{'lossy','lossless'});
props.porder = validatestring(p.Results.ProgressionOrder,{'lrcp','rlcp','rpcl','pcrl','cprl'});
props.qlayers = p.Results.QualityLayers;
props.rlevels = p.Results.ReductionLevels;
props.tileheight = p.Results.TileSize(1);
props.tilewidth = p.Results.TileSize(2);
props.format = fmt;

return
