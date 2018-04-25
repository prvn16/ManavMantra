function data = layout(width, height, shape, args, sample)
% This internal helper function may be removed in a future release.

%LAYOUT Compute wordcloud layout 
%   DATA = LAYOUT(WIDTH, HEIGHT, SHAPE, ARGS, SAMPLE)
%   returns a structure with layout information. WIDTH and HEIGHT are the pixel
%   width and height of the area to fill. SHAPE is a matrix of word metrics in pixels.
%   SHAPE is M-by-N where each column encodes bounds info about the corresponding
%   word shape. each column is [wl wr md ma d1 a1 d2 a2 ... ] where
%   'wl' and 'wr' are the widths in pixels from center to left and right most pixels
%   or the bounding box edges. 
%   'dn' and 'an' are the descent and ascent in pixels of the nth column of pix
%   along the string. The ascent and descent are relative to the center line.
%   wl+wr is the number of pairs [dn an] for the shape.
%   So [d1 a1] = [2 5] means the first strip of the string starts 2 pixels
%   below the center line and 5 pixels above.
%   'ma' and 'md' are the maximum ascent and descent for the word.
%   We do not capture holes in strings - only the start and end of vertical spaces.
%   ARGS is a structure with fields:
%     Layout: 'oval'/'rectangle'
%     LayoutNum: rng seed number
%     maxFontSizePixels: pixel size of max font size used in 'shape'
%     fontsize: array of fontsizes
%   SAMPLE is a function handle of the form 
%     [x,y] = SAMPLE(width, height, wordWidth, wordHeight);
%   which returns a random [x y] position to test within the target pixel area.
%   To implement non-random layouts pass in a non-random SAMPLE. Note random numbers
%   may be used if the sampler returns overlapping sample points.
%   The output DATA has fields 
%     fontsize: a numeric vector of normalized font sizes from scaling args.fontsize
%     pos: an 2-by-N matrix of [x;y] positions of the layout (center is [0 0])
%     layoutSize: width and height in pixels of final layout area
%     mask: the matrix used for tracking word placement (for debugging)

% Copyright 2016-2017 The MathWorks, Inc.

num_words = size(shape,2);

if num_words == 0
    data.fontsize = [];
    data.pos = [];
    data.mask = [];
    data.layoutSize = [width height];
    return;
end

oldstate = rng;
rng(args.LayoutNum);
resetRng = onCleanup(@()rng(oldstate));

% ratio between target largest word and wordshape largest word.
% this is our initial scale factor for layout. After we place
% words and grow the layout region we scale again at the end
% in case the region grew.
maxPix = args.maxFontSizePixels;
shapeScaleFactor = height*args.fontsize(1)/maxPix;

layoutData.scaleFactor = shapeScaleFactor;
layoutData.width = width;
layoutData.height = height;
layoutData.origWidth = width;
layoutData.origHeight = height;
layoutData.style = args.Layout;

% mask encodes vertical gap runs along each pixel column. 
% Each gap is encoded as a start index (0-based) and length.
% The initial mask is blank.
nw = ceil(width/maskResolution);
layoutData.mask = makeEmptyMask(nw,height);
layoutData.pos = zeros(2,num_words); % matrix of positions to compute

% grow width and height so that first word fits horizontally
wordShape = extractShapeFromArray(shape,1,layoutData);
symw = 2*max(wordShape(1),wordShape(2)); % symmetric centering width
layoutData = growToFitWidth(symw,layoutData);
k=1;
attemptCount = 0;
while k <= num_words
    [k, attemptCount, layoutData] = tryOneWord(k, attemptCount,shape, sample, layoutData);
end
% prepare output
data.fontsize = args.fontsize*layoutData.origHeight/layoutData.height;
data.pos = layoutData.pos;
data.mask = layoutData.mask;
data.layoutSize =[layoutData.width layoutData.height];

function [k, attemptCount, layoutData] = tryOneWord(k,attemptCount,shape,sample,layoutData)
wordShape = extractShapeFromArray(shape,k,layoutData);
symw = 2*max(wordShape([1 2])); % symmetric centering width
symh = 2*max(wordShape([3 4])); % symmetric centering height
layoutData = growToFitWidth(symw,layoutData);
width = layoutData.width;
height = layoutData.height;

[x,y] = sample(width, height, symw, symh);
x = round(x);
y = round(y);
box = wordShape(1:4);
if strcmp(layoutData.style,'oval')
    [xy, gotPosition] = computeOvalPosition(layoutData.mask,x,y,box,width,height);
    % since cloud layout checks many more positions we have smaller control
    % values than the rectangle layout
    controls = [15 3];
else
    [xy, gotPosition] = computeRectPosition(layoutData.mask,x,y,box);
    controls = [100 20];
end
if ~gotPosition
    attemptCount = attemptCount+1;
    
    if attemptCount == controls(1)
        % skip this word
        gotPosition = true;
    elseif mod(attemptCount,controls(2)) == 0
        layoutData = growLayout(layoutData,1.1); % grow by 10%
    end
end

% record position and move to next word
if gotPosition
    center = [layoutData.width/2 layoutData.height/2];
    layoutData.pos(:,k) = xy - center;
    if ~any(isnan(xy))
        layoutData = removeShapeFromMask(layoutData,...
                                         xy, ...
                                         wordShape);
    end
    attemptCount = 0;
    k = k+1;
end

function over = overlapxy(mask, x, y, box)
% return true iff placing word centered at [x y] with given metrics
% overlaps an existing word in mask.
x = round(x);
y = round(y);
min_y = floor(y - box(3));
max_y = ceil(y + box(4));
if box(1) == 0 && box(2) == 0
    over = false;
else
    i1 = computeIndex(mask, x - box(1));
    i2 = computeIndex(mask, x + box(2));
    over = overlaps(mask, i1, i2, min_y, max_y);
end

function over = overlaps(mask,i1,i2,min_y,max_y)
% return true iff [min_y max_y] overlaps an existing word between [i1 i2]
over = false;
for i=i1:i2
    strip = mask(:,i);
    n = length(strip);
    found = false;
    for k=1:2:n
        if strip(k) <= min_y && strip(k)+strip(k+1) >= max_y
            found = true;
            break;
        end
    end
    if ~found
        over = true;
        return;
    end
end

function [xy, gotPosition] = computeOvalPosition(mask,x,y,box,width,height)
% try spiral
xy = [nan nan];
gotPosition = false;
h2 = height/2;
w2 = width/2;
t = 20*pi; % spiral 10 times around the circle
sgn = 1;
if x < w2
    sgn = -1;
end
symw = 2*max(box([1 2])); % symmetric centering width
symh = 2*max(box([3 4])); % symmetric centering height
rstart = abs(x-w2)/width/2;
dr = 1 - rstart;
tstart = y/height*pi;
N = 100;
for i=1:N
    r = rstart + i/N*dr;
    th = tstart + i/N*t*sgn;
    x = r*w2*cos(th) + w2;
    y = r*h2*sin(th) + h2;
    x = max(symw/2,min(width-symw/2,x));
    y = max(symh/2,min(height-symh/2,y));
    over = overlapxy(mask,x,y,box);
    if ~over
        xy = [x y];
        gotPosition = true;
        break;
    end
end

function [xy, gotPosition] = computeRectPosition(mask,x,y,box)
gotPosition = false;
xy = [nan nan];
start = computeIndex(mask, x);
strip = mask(:,start);
box_span = (box(3)+box(4)+1);
big_gaps = strip(2:2:end) - box_span;
if ~any(big_gaps > 0)
    % no space in this column. try again.
    return
end
over = overlapxy(mask,x,y,box);
if over
    % Look through the gaps along this column and try to place
    % inside them.
    [~,gaps] = sort(big_gaps,'descend');
    i1 = computeIndex(mask, x - box(1));
    i2 = computeIndex(mask, x + box(2));
    for idx=gaps.'
        gap_y = double(strip(idx*2-1));
        span = double(strip(idx*2));
        if span <= box_span
            break;
        end
        for k=1:4 % try 4 different random locations within this span
            y = round(sampleDim(gap_y + box(3), gap_y + span - box(4)));
            min_y = y - box(3);
            max_y = y + box(4);
            over = overlaps(mask, i1, i2, min_y, max_y);
            if ~over
                break;
            end
        end
    end
end
if ~over
    xy = [x y];
    gotPosition = true;
end

function layoutData = removeShapeFromMask(layoutData,pos,shape)
% removes the specified shape centered as pos from the mask.
widthLeft = shape(1); % may be non-integer if scaling the word
header = 4; % header size of shape
ncols = (length(shape)-header)/2;
w = (0:ncols)*layoutData.scaleFactor;
startw = pos(1)-widthLeft;
mask = layoutData.mask;
for j=1:ncols
    i1 = computeIndex(mask, startw + w(j));
    i2 = computeIndex(mask, startw + w(j+1));
    coli = 2*(j-1) + header + 1;
    descent = shape(coli);
    ascent = shape(coli + 1);
    if ascent ~= 0 || descent ~= 0
        min_y = floor(pos(2) - descent);
        max_y = ceil(pos(2) + ascent);
        for k=i1:i2
            mask = removeOneColumnFromMask(mask, k, min_y, max_y);
        end
    end
end
layoutData.mask = mask;

function data = removeOneColumnFromMask(data, x, min_y, max_y)
strip = data(:,x);
n = length(strip);
for k=1:2:n
    bottom = strip(k);
    top = bottom + strip(k+1);
    if top < min_y
        continue;
    end
    if bottom >= max_y
        break;
    end
    % we have overlap
    if max_y <= top % [bottom min_y max_y top]
        new_run1 = max(0,min_y - strip(k));
        new_start = max_y;
        new_run2 = top - max_y;
        strip = [strip(1:k); new_run1; new_start; new_run2; strip(k+2:end)];
        strip = discardShortSpans(strip);
        data(:,x) = 0;
        data(1:length(strip),x) = strip;
        break;
    elseif bottom <= min_y % [bottom min_y top max_y]
        data(k+1,x) = min_y - bottom;
    end
end

function newstrip = discardShortSpans(strip)
min_gap = 2; % remove gaps smaller than 2 pixels
gaps = strip(2:2:end);
short = gaps < min_gap;
if any(short)
    ok = find(~short);
    newstrip = strip(sort([2*ok; 2*ok-1]));
else
    newstrip = strip;
end

function i = computeIndex(mask, x)
res = maskResolution;
i = floor(x/res)+1;
w = size(mask,2);
i = max(1,min(w,i));

function layoutData = growToFitWidth(strwidth,layoutData)
factor = 0.8;
w2 = layoutData.width*factor;
if strwidth > w2
    newWidth = round(strwidth/factor);
    rat = newWidth/layoutData.width;
    layoutData = growLayout(layoutData, rat);
end

function layoutData = growLayout(layoutData, rat)
% rat is ratio compared to current width and height
newHeight = round(rat*layoutData.height);
minGrowth = 5; % grow at least 5 pixels
dy = max(minGrowth,ceil((newHeight - layoutData.height)/2));
newHeight = layoutData.height + 2*dy;
ref_rat = newHeight/layoutData.origHeight;
newWidth = round(layoutData.origWidth*ref_rat);
dx = round((newWidth - layoutData.width)/2);
oldHeight = layoutData.height;
layoutData.height = newHeight;
% now expand mask size
mask = layoutData.mask;
% increase existing mask along top and bottom
for i=1:size(mask,2)
    strip = growStripAtEnds(mask(:,i),dy,oldHeight);
    mask(1:length(strip),i) = strip;
end
% insert completely free columns at the ends
cols = makeEmptyMask(dx,newHeight);
if size(mask,1) ~= size(cols,1)
    cols(size(mask,1),1) = 0;
end
mask = [cols mask cols];
layoutData.mask = mask;
layoutData.width = size(mask,2);

function strip = growStripAtEnds(strip,dy,height)
height = height + dy;
if strip(1) == 0
    strip(2) = strip(2) + dy; % increase bottom gap
else
    strip = [0; dy; strip];   % new bottom gap
end
k = 3;
n = length(strip);
while k < n
    if strip(k+1) > 0
        strip(k) = strip(k) + dy;
    end
    k = k+2;
end
k = find(strip~=0,1,'last'); % last non-zero run
% now adjust top gap
if strip(k-1) + strip(k) >= height
    strip(k) = strip(k)+dy;
else
    strip(k+1:k+2) = [height+dy dy];
end

function y = sampleDim(low,high)
% y is a random point between [low high] near the center
span = high - low;
y = low + rand*span;

function wordShape = extractShapeFromArray(shape, k, layoutData)
% wordShape is [wl wr md ma d1 a1 d2 a2 ... ] 
wordShape = shape(:,k);
width = wordShape(1)+wordShape(2);
dataStart = 5;
wordShape((dataStart+width*2):end) = []; % remove unused portion
wordShape = ceil(wordShape*layoutData.scaleFactor);

function res = maskResolution
res = 1; % pixels per mask grid entry

function mask = makeEmptyMask(width, height)
mask = zeros(2,width,'uint16');
mask(2,:) = height;

%{
function debugPlot(layout)
f = findall(0,'Tag','WordCloudDebug','Type','figure');
if isempty(f)
    f = figure('HandleVisibility','off','Tag','WordCloudDebug');
    f.Position = get(gcf,'Position');
    ax = axes('Parent',f,'OuterPosition',[0 0 1 1]);
    xticks(ax,[]);
    yticks(ax,[]);
end
ax = f.Children;
graphicstest.utils.wordcloud.hPlotWordCloudMask(layout,ax);
%}
