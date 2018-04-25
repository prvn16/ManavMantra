function shape = wordshape(words,weights,height,props)

% Shape is M-by-N where each column encodes bounds info about the corresponding
% word shape. Each column is [wl wr md ma d1 a1 d2 a2 ... ] where 
% 'wl' and 'wr' are the widths in pixels from center to left and right most pixels
% 'dn' and 'an' are the descent and ascent in pixels of the nth column of pix
% along the string. The ascent and descent are relative to the center line.
% wl+wr is the number of pairs [dn an] for the shape.
% So [d1 a1] = [2 5] means the first strip of the string starts 2 pixels
% below the center line and 5 pixels above.
% 'ma' and 'md' are the maximum ascent and descent for the word.
% We do not capture holes in strings - only the start and end of vertical spaces.
% If a section is blank the ascent and descent are 0.

% Copyright 2016-2017 The MathWorks, Inc.

num_words = length(words);

shape = zeros(3,num_words);

fig.f = figure('HandleVisibility','off','Visible','off','IntegerHandle','off',...
           'Color','k','InvertHardcopy','off','WindowStyle','normal','Units','pixels');
clean = onCleanup(@()close(fig.f));
fig.ax = axes('Parent',fig.f,'Position',[0 0 1 1],'Visible','off');

% get vertical extent of a test string 
props.Parent = fig.ax;
t0 = text(0,0,'test',props,...
          'FontUnits','pixels',...
          'FontSize',100,...
          'Interpreter','tex');
t0.Units = 'pixels';
ext = t0.Extent;
factor = ext(4)/100; % how much larger is the text height than our requested height
fontname = t0.FontName;

fsize = weights*height; % font sizes in pixels
offset = ceil(fsize*factor); % vertical extents of each word (including leading)
delete(t0);
font = matlab.graphics.general.Font;
font.Name = fontname;
font.Size = 1;
fig.t1 = matlab.graphics.primitive.world.Text(...
    'Font',font,...
    'Margin',1e-10,...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'ColorData',uint8([255;255;255;255]),...
    'Parent',fig.ax,...
    'Interpreter','tex');

% process in stacks of strings up to 500 pixels high at a time, otherwise figure gets too big
i1 = 1;
i2 = 1;
run_sum = 0;
while i2 <= num_words
    run_sum = run_sum + offset(i2);
    if run_sum > 500 || i2 == num_words
        chunk = processWords(fig,words(i1:i2),fsize(i1:i2),offset(i1:i2));
        shape(1:size(chunk,1), i1:i2) = chunk;
        i2 = i2+1;
        i1 = i2;
        run_sum = 0;
    else
        i2 = i2+1;
    end
end

function shape = processWords(fig,words,fsize,offset)
% Take words with given font sizes and vertical placement offsets and
% return the shape information for those strings. The strings are stacked
% vertically, bottom to top, along the hidden figure and rendered to a
% bitmap. The bitmap is then scanned along columns of each string to
% find the vertical metrics.
num_words = length(words);
estimatedWidth = ceil(max((5+strlength(words))*fsize(1)));
inset = 10; % keep 10 pixels away from edges since printing prefers that
ss = get(groot,'ScreenSize');
max_width = ss(3)-2*inset; % don't get bigger than the screen
estimatedWidth = min(max_width,estimatedWidth);
estimatedHeight = sum(offset) + 2*inset + 2*num_words;
fig.f.Position = [inset inset estimatedWidth estimatedHeight];
axcenter = round(estimatedWidth/2);
fig.ax.Units = 'pixels';
fig.ax.Position = [1 inset+1 estimatedWidth estimatedHeight]; % small gap on bottom
fig.ax.YLim = [0 estimatedHeight];
fig.ax.XLim = [0 estimatedWidth];

% compute world primitive text data to stack words up along y
vd = zeros(3,num_words);
str = cell(num_words,1);
ppp = get(0,'ScreenPixelsPerInch')/72;
y = 0;
for k=1:num_words
    txt = words(k);
    txt = regexprep(txt,'([_{}^\\])','\\$1'); % escape tex special chars
    str{k} = ['\fontsize{' num2str(floor(fsize(k)/ppp)) '}' char(txt)];
    vd(1,k) = axcenter;
    vd(2,k) = y;
    y = y + offset(k) + 2; % also include 2 pix gap between words
end
vd = single(vd);
fig.t1.VertexData = vd;
fig.t1.String = str;

% get pixel data
pix = print(fig.f,'-RGBImage','-r0');
pix = pix(:,:,1); % extract just R from RGB (they're all the same)
pix = matlab.graphics.chart.internal.wordcloud.shrinkHighDPI(pix, fig.f.Position); % remove hi-dpi scaling
pix = flipud(pix);
shape = zeros(3,num_words);

% loop over rendered words and get bound information
y = inset;
for k=1:num_words
    y1 = y;
    y2 = floor(y1 + offset(k));

    % word_pix are the pixels for a given word.
    word_pix = pix(y1:y2,:);

    % now look for left and right edge of glyphs
    [wl,wr] = computeLeftRightEdge(word_pix);
    thicken = 2; % thicken the shape slightly for robustness
    wl = wl + thicken;
    wr = wr + thicken;

    % now loop over columns and find the ascent and descent of each one
    centerline = round(offset(k)/2);
    pixwidth = size(word_pix,2);
    width = wl + wr;
    header = 4; % size of header of shape data
    shape(header + 2*width,k) = 0; % pre-allocate space for metrics
    for j=1:width
        % take pixels at around column j to make the outline "bolder"
        a = max(1,axcenter - wl + j - 1 - thicken);
        b = max(1,min(pixwidth,axcenter - wl + j - 1 + thicken));
        c = word_pix(:,a:b);
        c = max(c.');
        
        starti = find(c,1,'first');
        endi = find(c,1,'last');
        if ~isempty(starti)
            coli = 2*(j-1) + header + 1;
            shape(coli,k) = centerline - starti + thicken; % descent
            shape(coli+1,k) = endi - centerline + thicken; % ascent
        end
    end
    
    y = y + offset(k) + 2;

    max_descent = max(shape((header+1):2:end,k));
    max_ascent = max(shape((header+2):2:end,k));
    shape(1,k) = wl;
    shape(2,k) = wr;
    shape(3,k) = max_descent;
    shape(4,k) = max_ascent;
end

function [wl,wr] = computeLeftRightEdge(word)
% word is a bitmap rendering of a word
% wl and wr are left and right widths from the center
h = size(word,1);
flat = word(:); % flatten by columns
first = floor((find(flat,1,'first')-1)/h)+1;
last = floor((find(flat,1,'last')-1)/h)+1;
if isempty(first)
    wl = 0;
    wr = 0;
else
    n = size(word,2);
    center = n/2;
    wl = max(1,ceil(center - first));
    wr = max(1,ceil(last - center));
end
