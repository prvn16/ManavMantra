function [yout,x] = imhist(varargin)
%IMHIST Display histogram of N-D image data.
%   IMHIST(I) displays a histogram for the intensity image I whose number
%   of bins are specified by the image type.  If I is a grayscale image,
%   IMHIST uses 256 bins as a default value. If I is a binary image, IMHIST
%   uses only 2 bins. I can be 2-D, 3-D or N-D.
%
%   IMHIST(I,N) displays a histogram with N bins for the intensity image I
%   above a grayscale colorbar of length N.  If I is a binary image, then N
%   can only be 2.
%
%   IMHIST(X,MAP) displays a histogram for the indexed image X. This
%   histogram shows the distribution of pixel values above a colorbar of
%   the colormap MAP. The colormap must be at least as long as the largest
%   index in X. The histogram has one bin for each entry in the colormap.
%   X can be 2-D, 3-D or N-D.
%
%   [COUNTS,X] = imhist(...) returns the histogram counts in COUNTS and the
%   bin locations in X so that stem(X,COUNTS) shows the histogram. For
%   indexed images, it returns the histogram counts for each colormap
%   entry; the length of COUNTS is the same as the length of the colormap.
%
%   Class Support
%   -------------  
%   An input intensity image can be uint8, int8, uint16, int16, uint32,
%   int32, single, double, or logical. An input indexed image can be uint8,
%   uint16, single, double, or logical. Both I and X can have any number of
%   dimensions.
%
%   Note
%   ----
%   For intensity images, the N bins of the histogram are each half-open
%   intervals of width A/(N-1).
%  
%   For uint8, uint16, and uint32 intensity images, the p-th bin is the
%   half-open interval:
%
%        A*(p-1.5)/(N-1)  <= x  <  A*(p-0.5)/(N-1)
%
%   For int8, int16, and int32 intensity images, the p-th bin is the
%   half-open interval:
%  
%        A*(p-1.5)/(N-1) - B  <= x  <  A*(p-0.5)/(N-1) - B  
%
%   The intensity value is represented by "x". Intensity images of class
%   single and double are assumed to take values in [0 1]. The scale factor
%   A depends on the image class.  A is 1 if the intensity image is double
%   or single; A is 255 if the intensity image is uint8 or int8; A is 65535
%   if the intensity image is uint16 or int16; A is 4294967295 if the
%   intensity image is uint32 or int32. B is 128 if the image is int8; B is
%   32768 if the intensity image is int16; B is 2147483648 if the intensity
%   image is int32.
%  
%   Example 1
%   -------
%   Display the histogram of a grayscale image.
%
%        I = imread('pout.tif');
%        imhist(I)
%
%   Example 2
%   -------
%   Display the histogram of a 3-D intensity image.
%
%        load mristack
%        imhist(mristack)
%
%   See also HISTEQ, HISTOGRAM, IMHISTMATCH, IMHISTMATCHN.

%   Copyright 1992-2017 The MathWorks, Inc.

[a, n, isScaled, top, map] = parse_inputs(varargin{:});

if islogical(a)
    if (n ~= 2)
        error(message('images:imhist:invalidParameterForLogical'))
    end
    y(2) = sum(a(:));
    y(1) = numel(a) - y(2);
    y = y';
elseif isa(a,'int8')
    y = imhistc(int8touint8mex(a), n, isScaled, top); % Call MEX file to do work.
elseif isa(a, 'int16')
    y = imhistc(int16touint16mex(a), n, isScaled, top); % Call MEX file to do work.
elseif isa(a, 'int32')
    y = imhistc(int32touint32mex(a), n, isScaled, top); % Call MEX file to do work.
else
    y = imhistc(a, n, isScaled, top); % Call MEX file to do work.
end

range = getrangefromclass(a);

if ~isScaled
    if isfloat(a)
        x = 1:n;
    else
        x = 0:n-1;
    end    
elseif islogical(a)
    x = range';
else
    % integer or float
    x = linspace(range(1), range(2), n)';
end

if (nargout == 0)
    plot_result(x, y, map, isScaled, class(a), range);
else
    yout = y;
end


%%%
%%% Function plot_result
%%%
function plot_result(x, y, cm, isScaled, classin, range)

n = length(x);
stem(x,y, 'Marker', 'none')
hist_axes = gca;

h_fig = ancestor(hist_axes,'figure');

% Get x/y limits of axes using axis
limits = axis(hist_axes);
if n ~= 1
  limits(1) = min(x);
else
  limits(1) = 0;
end
limits(2) = max(x);
var = sqrt(y'*y/length(y));
limits(4) = 2.5*var;
axis(hist_axes,limits);


% Cache the original axes position so that axes can be repositioned to
% occupy the space used by the colorstripe if nextplot clears the histogram
% axes.
original_axes_pos = get(hist_axes,'Position');

% In GUIDE, default axes units are characters. In order for axes repositiong
% to behave properly, units need to be normalized.
hist_axes_units_old = get(hist_axes,'units');
set(hist_axes,'Units','Normalized');
% Get axis position and make room for color stripe.
pos = get(hist_axes,'pos');
stripe = 0.075;
set(hist_axes,'pos',[pos(1) pos(2)+stripe*pos(4) pos(3) (1-stripe)*pos(4)])
set(hist_axes,'Units',hist_axes_units_old);

set(hist_axes,'xticklabel','')

% Create axis for stripe
stripe_axes = axes('Parent',get(hist_axes,'Parent'),...
                'Position', [pos(1) pos(2) pos(3) stripe*pos(4)]);
				 				 
limits = axis(stripe_axes);

% Create color stripe
if isScaled
    binInterval = 1/n;
    xdata = [binInterval/2 1-(binInterval/2)];
    limits(1:2) = range;
    switch classin
     case {'uint8', 'uint16', 'uint32'}
        xdata = range(2)*xdata;
        C = (1:n)/n;
     case {'int8','int16', 'int32'}
        xdata = (range(2)-range(1))* xdata + range(1);
        C = (1:n)/n;
     case {'double','single'}
        C = (1:n)/n;
     case 'logical'
        C = [0 1];
     otherwise
        error(message('images:imhist:internalError'))
    end
    
    % image(X,Y,C) where C is the RGB color you specify. 
    image(xdata,[0 1],repmat(C, [1 1 3]),'Parent',stripe_axes);
else
    if length(cm)<=256
        image([1 n],[0 1],1:n,'Parent',stripe_axes); 
        colormap(stripe_axes,cm);
        limits(1) = 0.5;
        limits(2) = n + 0.5;
    else
        image([1 n],[0 1],permute(cm, [3 1 2]),'Parent',stripe_axes);
        limits(1) = 0.5;
        limits(2) = n + 0.5;
    end
end

set(stripe_axes,'yticklabel','')
axis(stripe_axes,limits);

% Put a border around the stripe.
line(limits([1 2 2 1 1]),limits([3 3 4 4 3]),...
       'LineStyle','-',...
       'Parent',stripe_axes,...
       'Color',get(stripe_axes,'XColor'));

% Special code for a binary image
if strcmp(classin,'logical')
    % make sure that the stripe's X axis has 0 and 1 as tick marks.
    set(stripe_axes,'XTick',[0 1]);

    % remove unnecessary tick marks from axis showing the histogram
    set(hist_axes,'XTick',0);
    
    % make the histogram lines thicker
    h = get(hist_axes,'children');
    obj = findobj(h,'flat','Color','b');
    lineWidth = 10;
    set(obj,'LineWidth',lineWidth);
end

set(h_fig,'CurrentAxes',hist_axes);

% Tag for testing. 
set(stripe_axes,'tag','colorstripe');

wireHistogramAxesListeners(hist_axes,stripe_axes,original_axes_pos);

% Link the XLim of histogram and color stripe axes together.
% In calls to imhist in a tight loop, the histogram and colorstripe axes
% are destroyed and recreated repetitively. Use linkprop rather than
% linkaxes to link xlimits together to solve deletion timing problems.
h_link = linkprop([hist_axes,stripe_axes],'XLim');
setappdata(stripe_axes,'linkColorStripe',h_link);

%%%
%%% Function wireHistogramAxesListeners
%%%
function wireHistogramAxesListeners(hist_axes,stripe_axes,original_axes_pos)

% If the histogram axes is deleted, delete the color stripe associated with
% the histogram axes.
cb_fun = @(obj,evt) removeColorStripeAxes(stripe_axes);
lis.histogramAxesDeletedListener = iptui.iptaddlistener(hist_axes,...
    'ObjectBeingDestroyed',cb_fun);

% This is a dummy hg object used to listen for when the histogram axes is cleared.
deleteProxy = text('Parent',hist_axes,...
    'Visible','Off', ...
    'Tag','axes cleared proxy',...
    'HandleVisibility','off');

% deleteProxy is an invisible text object that is parented to the histogram
% axes.  If the ObjectBeingDestroyed listener fires, the histogram axes has
% been cleared. This listener is triggered by newplot when newplot clears
% the current axes to make way for new hg objects being drawn. This
% listener does NOT fire as a result of the parent axes being deleted.
prox_del_cb = @(obj,evt) histogramAxesCleared(obj,stripe_axes,original_axes_pos);
lis.proxydeleted = iptui.iptaddlistener(deleteProxy,...
    'ObjectBeingDestroyed',prox_del_cb);

setappdata(stripe_axes,'ColorStripeListeners',lis);


%%%
%%% Function removeColorStripeAxes
%%%
function removeColorStripeAxes(stripe_axes)

if ishghandle(stripe_axes)
    delete(stripe_axes);
end
        

%%%
%%% Function histogramAxesCleared
%%%
function histogramAxesCleared(hDeleteProxy,stripe_axes,original_axes_pos)

removeColorStripeAxes(stripe_axes);

h_hist_ax = get(hDeleteProxy,'parent');
set(h_hist_ax,'Position',original_axes_pos);


%%%
%%% Function parse_inputs
%%%
function [a, n, isScaled, top, map] = parse_inputs(varargin)

narginchk(1,2);
a = varargin{1};
validateattributes(a, {'double','uint8','int8','logical','uint16','int16','single','uint32', 'int32'}, ...
              {'nonsparse'}, mfilename, ['I or ' 'X'], 1);
n = 256;

switch (class(a))
case {'double', 'single'}
    isScaled = 1;
    top = 1;
    map = []; 
    
case {'uint8', 'int8'}
    isScaled = 1; 
    top = 255;
    map = [];
    
case 'logical'
    n = 2;
    isScaled = 1;
    top = 1;
    map = [];

case {'int16', 'uint16'}
    isScaled = 1; 
    top = 65535;
    map = [];

case {'int32', 'uint32'}
    isScaled = 1;
    top = double(intmax('uint32'));
    map = [];
    
otherwise
    % shouldn't happen.
end
    
if (nargin ==2)
    if (numel(varargin{2}) == 1)
        % IMHIST(I, N)
        n = varargin{2};
        validateattributes(n, {'numeric'}, {'real','positive','integer'}, mfilename, ...
                      'N', 2);
                  
        n = double(n);
        
    elseif (size(varargin{2},2) == 3)
      if isa(a,'int16')
        error(message('images:imhist:invalidIndexedImage'))
      end

      % IMHIST(X,MAP) or invalid second argument
      iptcheckmap(varargin{2}, mfilename, 'varargin{2}', 2);
      n = size(varargin{2},1);
      isScaled = 0;
      top = n;
      map = varargin{2};
      
    else
        error(message('images:imhist:invalidSecondArgument'))
    end
end
