function writegif(mat,map,filename,varargin)
%WRITEGIF Write a GIF (Graphics Interchange Format) file to disk.
%	WRITEGIF(X,MAP,FILENAME) writes the indexed image X,MAP
%   to the file specified by the string FILENAME. The extension 
%   '.gif' will be added to FILENAME if it doesn't already 
%   have an extension.
%
%   X can be a single image (M-by-N) or a series of
%   frames(M-by-N-by-1-by-P).  X must be of type uint8, logical, or double.
%   If X is uint8 or logical, then colormap indexing starts at zero.  If X
%   is double, then colormap indexing starts at one.
%
%   MAP can be a single colormap (M-by-3) that is applied to all frames, or a series of colormaps
%   (M-by-3-by-P) where P is the number of frames specified in X.  
%
%   WRITEGIF(X,[],FILENAME) writes the grayscale image GRAY
%   to the file.
%
%   WRITEGIF(...,'writemode','append') appends a single image to a file existing
%   on disk.
%
%   WRITEGIF(...,'comment',TEXT) writes an image to a file with the
%   comment specified in TEXT.  The comment is placed immediately before the image.
%   TEXT can be either a character array or a cell array of strings.  If
%   TEXT is a cell array of strings, then a carriage return is added after
%   each row.
%
%   WRITEGIF(...,'disposalmethod',DMETH) specifies the disposal
%   method for the image.  DMETH must be one of
%   'leaveInPlace','restoreBG','restorePrevious', or 'doNotSpecify'.
%
%   WRITEGIF(...,'delaytime',TIME) specifies the delay before displaying
%   the next image.  TIME must be a scalar value measured in seconds
%   between 0 and 655 inclusive.
%   
%   WRITEGIF(...,'transparentcolor',COLOR) specifies the transparent color
%   for the image.  COLOR must be a scalar index into the colormap.  If X
%   is uint8 or logical, then indexing starts at 0.  If X is double, then
%   indexing starts at 1.
%
%   WRITEGIF(...,'backgroundcolor',COLOR) specifies the background color
%   for the image.  COLOR must be a scalar index into the colormap.  If X
%   is uint8 or logical, then indexing starts at 0.  If X is double, then
%   indexing starts at 1.
%
%   WRITEGIF(...,'loopcount',COUNT) specifies the number of times to repeat
%   the animation.  If COUNT is Inf, the animation will be continuously
%   looped.  If COUNT is 0, the animation will be played once.  If
%   COUNT is 1, the animation will be played twice, etc.  The maximum value
%   of COUNT (other than Inf) is 65535.

%   WRITEGIF(...,'screensize',SIZE) specifies the screensize for the
%   image.  SIZE must be a two element vector where the first element is
%   the screen height and the second element is the screen width.
%
%   WRITEGIF(...,'location',LOC) specifies the offset of the top left
%   corner of the image relative to the top left corner of the screen.  LOC
%   must be a two element vector where the first element is the offset from
%   the top and the second element is the offset from the left.   
%
%	See also: GIFREAD, BMPWRITE, HDFWRITE, PCXWRITE, TIFFWRITE,
%	          XWDWRITE.

%	Copyright 1993-2013 The MathWorks, Inc.


% Process param/value pairs
propStrings = {'writemode','comment','disposalmethod',...
        'delaytime','transparentcolor',...
        'loopcount','location','screensize','backgroundcolor'};


% Process varargin into a form that we can use with the input parser.
for k = 1:2:length(varargin)
    prop = lower(varargin{k});
    if (~ischar(prop))
        error(message('MATLAB:imagesci:writegif:badParameterName'));
    end
    
    idx = find(strncmp(prop, propStrings, numel(prop)));
    if (isempty(idx))
        error(message('MATLAB:imagesci:validate:unrecognizedParameterName', prop));
    elseif (length(idx) > 1)
        error(message('MATLAB:imagesci:validate:ambiguousParameterName', prop));
    end
    
    varargin{k} = propStrings{idx};
end


% Parse and validate the input arguments.
p = inputParser;
p.addRequired('mat',@(x)validateattributes(x,{'logical','uint8','double'},{'nonempty'}));
p.addRequired('map',@isnumeric);
p.addRequired('filename',@(x)validateattributes(x,{'char'},{'nonempty','row'}));

p.addParamValue('writemode','overwrite', ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','WRITEMODE'));
p.addParamValue('comment','', ...
    @(x) validateattributes(x,{'char','cell'},{'nonempty'},'','COMMENT'));
p.addParamValue('disposalmethod', 'donotspecify',...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','DISPOSALMETHOD'));
p.addParamValue('delaytime',[], ...
    @(x) validateattributes(x,{'double'},{'scalar','>=',0,'<=',655}));
p.addParamValue('transparentcolor',[], ...
    @(x) validateattributes(x,{'double'},{'integer','scalar'},'','TRANSPARENTCOLOR') );
p.addParamValue('loopcount',[], ...
    @(x) isnumeric(x) && isscalar(x) && (isinf(x) || (x<=65535 && x>=0)));
p.addParamValue('location',[0 0], ...
    @(x) validateattributes(x,{'double'},{'integer','vector','numel',2},'','LOCATION'));
p.addParamValue('backgroundcolor',[], ...
    @(x) validateattributes(x,{'double'},{'integer','scalar'},'','BACKGROUNDCOLOR'));
p.addParamValue('screensize',[], ...
    @(x) validateattributes(x,{'double'},{'integer','vector','numel',2,'<=',2^32-1},'','SCREENSIZE'));

p.parse(mat,map,filename,varargin{:});


valid_strings = {'append','overwrite'};
writemode = validatestring(p.Results.writemode, valid_strings);

comment = p.Results.comment;
if iscell(comment) && ~iscellstr(comment)
    error(message('MATLAB:imagesci:writegif:badComment'));
end

valid_strings = {'leaveinplace','restorebg','restoreprevious','donotspecify'};
disposalmethod = validatestring(p.Results.disposalmethod, valid_strings);



%check for number of dimensions greater than four
validateattributes(size(mat),{'numeric'},{'<=',2^32-1},'','SIZE(X)');
nd = ndims(mat);


if ((nd == 3) || (nd > 4))
    error(message('MATLAB:imagesci:writegif:badSize', nd));
end

ndcmap = ndims(map);
if ndcmap > 3
    error(message('MATLAB:imagesci:writegif:badColormapDimensions', ndcmap));
elseif (ndcmap == 3) && ~(nd == 4)
    error(message('MATLAB:imagesci:writegif:badColormapForSingleFrame'));
end

if (~isempty(map)) && ((size(map,1)>256) || (size(map,2) ~= 3))
    warning(message('MATLAB:imagesci:writegif:tooManyColormapEntries'));
    map = map(1:256,:,:);
end
    
%this variable determines whether or not color index params are zero based
%or one based (this is determined by the data type of mat)
zerobased = 1;

%convert to zero based indexing if data is one based (type double)
if(isa(mat,'double'))
    mat = mat-1;
    zerobased = 0;
end


if isempty(p.Results.backgroundcolor)
    backgroundcolor = 0;
else
    backgroundcolor = double(p.Results.backgroundcolor);
    if (not(zerobased))
        backgroundcolor = backgroundcolor-1;
    end
end

if isempty(p.Results.loopcount)
    loopcount = -1;
else
    loopcount = round(p.Results.loopcount);
    switch(loopcount)
        case 0
            loopcount = -1;
        case Inf
            loopcount = 0;
    end
end

if isempty(p.Results.screensize)
    screensize = [size(mat,2) size(mat,1)];
else
    screensize = round(p.Results.screensize);
end

if iscellstr(comment)
    tmp = '';
    for str = comment
        %TODO - make sure newline characters are correct
        tmp = [tmp str{1} char(13) char(10)]; %#ok<AGROW>
    end
    comment = tmp;
end

switch(lower(p.Results.disposalmethod))
    case 'leaveinplace'
        disposalmethod=1;
    case 'restorebg'
        disposalmethod=2;
    case 'restoreprevious'
        disposalmethod=3;
    case 'donotspecify'
        disposalmethod=0;
end

switch(writemode)
    case 'append'
        writemode = 1;
        
        % Make checks for things that should not be supplied in append
        % mode.
        if ~isempty(p.Results.comment)
            warning(message('MATLAB:imagesci:writegif:badParameterInAppendMode','COMMENT'))
            comment = '';
        end
        if ~isempty(p.Results.loopcount)
            warning(message('MATLAB:imagesci:writegif:badParameterInAppendMode','LOOPCOUNT'))
            loopcount = -1;
        end
        if ~isempty(p.Results.screensize)
            warning(message('MATLAB:imagesci:writegif:badParameterInAppendMode','SCREENSIZE'))
            screensize = [size(mat,2) size(mat,1)];
        end
        if ~isempty(p.Results.backgroundcolor)
            warning(message('MATLAB:imagesci:writegif:badParameterInAppendMode','BACKGROUNDCOLOR'))
            backgroundcolor = 0;
        end
        
    case 'overwrite'
        writemode = 0;
end

%convert seconds to the nearest hundredth of a second
if isempty(p.Results.delaytime)
    delaytime = 50;
else
    delaytime = round(p.Results.delaytime*100);
end

if isempty(p.Results.transparentcolor)
    transparentcolor = -1;
else   
    transparentcolor = round(double(p.Results.transparentcolor));
    transparentcolor = transparentcolor - double(not(zerobased));  %if one-based image data, then this is also treated as one-based
end

%parameter defaults
location = round(p.Results.location);


%generate grayscale colormap if map is empty and we are not appending 
%(will use global colormap if appending)
if(isempty(map) && not(writemode==1))
    if(islogical(mat))
        map = gray(2);
    else
        map = gray(256);
    end
end

% assume normal orientation of the colormap and image data passed in
if nd==2
    mat = mat';
elseif nd ==4
    mat = permute(mat,[2,1,3,4]);
end

if ndcmap==2
    map = map';
elseif ndcmap==3
    map = permute(map,[2,1,3]);
end

if(isempty(map))
    cmaplength = 256;
else
    cmaplength = size(map,2);
end

greaterthancmap = find(mat>=cmaplength);
lessthancmap = mat<0;

if(~isempty(greaterthancmap) || ~isempty(find(mat<0, 1)))
    warning(message('MATLAB:imagesci:writegif:dataOutOfRange'));
    mat(greaterthancmap) = cmaplength-1;
    mat(lessthancmap) = 0;
end

if(transparentcolor>=cmaplength || transparentcolor < -1)
    warning(message('MATLAB:imagesci:writegif:transparentcolorNotUsed'));
    transparentcolor = -1;
end
if(backgroundcolor>=cmaplength || backgroundcolor < -1)
    warning(message('MATLAB:imagesci:writegif:backgroundcolorNotUsed'));
    backgroundcolor = -1;
end

%make sure data is uint8 format
mat = uint8(mat);

wgifc(mat, map, filename,writemode,disposalmethod,delaytime,...
    transparentcolor,comment,backgroundcolor,loopcount,location,screensize);
