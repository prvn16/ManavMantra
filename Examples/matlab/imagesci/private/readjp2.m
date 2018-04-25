function [A, map] = readjp2(filename, varargin)
%READJP2 Read image data from JPEG 2000 files.
%   A = READJP2(FILENAME) reads image data from a JPEG file.
%   A is a 2-D grayscale or 3-D RGB image whose type depends on the
%   bit-depth of the image (logical, uint8, uint16, int8, int16).
%
%   See also IMREAD.

%   Copyright 2008-2013 The MathWorks, Inc.

options = parse_args(varargin{:});


% Setup default options.
options.useResilientMode = false;  % default is fast mode

% Call the interface to the Kakadu library.
try
	A = readjp2c(filename,options);

catch firstException
	
	switch firstException.identifier
		case 'MATLAB:imagesci:jp2adapter:ephMarkerNotFollowingPacketHeader'

		    % Try resilient mode.  
			options.useResilientMode = true;
			try
				A = readjp2c(filename,options);

				% Ok we succeeded.  Issue a warning to the user that their
				% file might have some problems.  
				warning(message('MATLAB:imagesci:readjp2:ephMarkerNotFollowingPacketHeader', filename, firstException.message));

			catch secondException
				% Ok it's hopeless, just give up.
				rethrow(firstException);	
			end

		otherwise
			% We don't know what to try.  Give up.
			rethrow(firstException);	
	end


end
map = [];

function args = parse_args(varargin)
%PARSE_ARGS  Convert input arguments to structure of arguments.

args.reductionlevel = 0;
args.pixelregion = [];
args.v79compatible = false;

params = {'reductionlevel', 'pixelregion', 'v79compatible'};

% Process varargin into a form that we can use with the input parser.
for k = 1:2:length(varargin)
    if (~ischar(varargin{k}))
        error(message('MATLAB:imagesci:readjp2:paramType'));
    end
    
    prop = lower(varargin{k});
    idx = find(strncmp(prop, params, numel(prop)));
    if (numel(idx) > 1)
        error(message('MATLAB:imagesci:validate:ambiguousParameterName', prop));
    elseif isscalar(idx)
        varargin{k} = params{idx};
    end
    
end

p = inputParser;
p.addParamValue('reductionlevel',0, ...
    @(x)validateattributes(x,{'numeric'},{'integer','finite','nonnegative','scalar'},'','REDUCTIONLEVEL'));
p.addParamValue('v79compatible',false, ...
    @(x)validateattributes(x,{'logical'},{'scalar'},'','V79COMPATIBLE'));
p.addParamValue('pixelregion',[], ...
    @(x)validateattributes(x,{'cell'},{'numel',2},'','PIXELREGION'));

p.parse(varargin{:});

args.reductionlevel = p.Results.reductionlevel;
args.v79compatible = p.Results.v79compatible;

args.pixelregion = process_region(p.Results.pixelregion);



%--------------------------------------------------------------------------=
function region_struct = process_region(region_cell)
%PROCESS_PIXELREGION  Convert a cells of pixel region info to a struct.

region_struct = struct([]);
if isempty(region_cell)
    % Not specified in call to readjp2.
    return;
end

for p = 1:numel(region_cell)
    
    validateattributes(region_cell{p},{'numeric'},{'integer','finite','positive','numel',2},'','PIXELREGION');
    
    start = max(0, region_cell{p}(1) - 1);
    stop = region_cell{p}(2) - 1;
        
    if (start > stop)
        error(message('MATLAB:imagesci:readjp2:badPixelRegionStartStop'))
    end

    region_struct(p).start = start;
    region_struct(p).stop = stop;

end



