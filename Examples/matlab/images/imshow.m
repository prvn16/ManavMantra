function h=imshow(varargin)
%IMSHOW Display image in Handle Graphics figure.  
%   IMSHOW(I) displays the grayscale image I.
%
%   IMSHOW(I,[LOW HIGH]) displays the grayscale image I, specifying the display
%   range for I in [LOW HIGH]. The value LOW (and any value less than LOW)
%   displays as black, the value HIGH (and any value greater than HIGH) displays
%   as white. Values in between are displayed as intermediate shades of gray,
%   using the default number of gray levels. 
%
%   IMSHOW(I,[]) displays the grayscale image I scaling the display based
%   on the range of pixel values in I. IMSHOW uses [min(I(:)) max(I(:))] as
%   the display range, that is, the minimum value in I is displayed as
%   black, and the maximum value is displayed as white.
%
%   IMSHOW(RGB) displays the truecolor image RGB.
%
%   IMSHOW(BW) displays the binary image BW. IMSHOW displays pixels with the
%   value 0 (zero) as black and pixels with the value 1 as white.
%
%   IMSHOW(X,MAP) displays the indexed image X with the colormap MAP.
%
%   IMSHOW(FILENAME) displays the image stored in the graphics file
%   FILENAME. The file must contain an image that IMREAD or DICOMREAD can
%   read. IMSHOW calls IMREAD or DICOMREAD to read the image from the file,
%   but does not store the image data in the MATLAB workspace. If the file
%   contains multiple images, the first one will be displayed. The file
%   must be in the current directory or on the MATLAB path. (DICOMREAD
%   capability and the NITF file format require the Image Processing
%   Toolbox.)
%
%   IMSHOW(IMG,RI,___) displays the image IMG with associated 2-D spatial
%   referencing object RI. IMG may be a grayscale, RGB, or binary image.
%   IMG may also be a graphics file FILENAME. (This syntax requires the
%   Image Processing Toolbox.)
%
%   IMSHOW(I,RI,[LOW HIGH]) displays the grayscale image I with associated
%   2-D spatial referencing object RI and a specified display range for I
%   in [LOW HIGH]. (This syntax requires the Image Processing Toolbox.)
%
%   IMSHOW(X,RX,MAP) displays the indexed image X with associated 2-D
%   spatial referencing object RX and colormap MAP. (This syntax requires
%   the Image Processing Toolbox.)
%
%   HIMAGE = IMSHOW(___) returns the handle to the image object created by
%   IMSHOW.
%
%   IMSHOW(___,PARAM1,VAL1,PARAM2,VAL2,___) displays the image, specifying
%   parameters and corresponding values that control various aspects of the
%   image display. Parameter names can be abbreviated, and case does not matter.
%
%   Parameters include:
%
%   'Border'                 String that controls whether
%                            a border is displayed around the image in the
%                            figure window. Valid strings are 'tight' and
%                            'loose'.
%
%                            Note: There can still be a border if the image
%                            is very small, or if there are other objects
%                            besides the image and its axes in the figure.
%                               
%                            By default, the border is set to 'loose'.
%
%   'Colormap'               2-D, real, M-by-3 matrix specifying a colormap. 
%                            IMSHOW uses this to set the colormap of the
%                            axes object containing the displayed image.
%                            Use this parameter to view grayscale images
%                            in false color.
%
%   'DisplayRange'           Two-element vector [LOW HIGH] that controls the
%                            display range of a grayscale image. See above
%                            for more details about how to set [LOW HIGH].
%
%                            Including the parameter name is optional,
%                            except when the image is specified by a
%                            filename. The syntax IMSHOW(I,[LOW HIGH]) is
%                            equivalent to IMSHOW(I,'DisplayRange',[LOW
%                            HIGH]). The parameter name must be specified
%                            when using IMSHOW with a filename, as in the
%                            syntax IMSHOW(FILENAME,'DisplayRange',[LOW
%                            HIGH]). If I is an integer type,
%                            'DisplayRange' defaults to the minimum and
%                            maximum representable values for that integer
%                            class. For images with floating point data,
%                            the default is [0 1].
%
%   'InitialMagnification'   A numeric scalar value, or the text string 'fit',
%                            that specifies the initial magnification used to 
%                            display the image. When set to 100, the image is 
%                            displayed at 100% magnification. When set to 
%                            'fit' IMSHOW scales the entire image to fit in 
%                            the window.
%
%                            On initial display, the entire image is visible.
%                            If the magnification value would create an image 
%                            that is too large to display on the screen,  
%                            IMSHOW warns and displays the image at the 
%                            largest magnification that fits on the screen.
%
%                            By default, the initial magnification is set to
%                            100%.
%
%                            If the image is displayed in a figure with its
%                            'WindowStyle' property set to 'docked', then
%                            IMSHOW warns and displays the image at the
%                            largest magnification that fits in the figure.
%
%                            Note: If you specify the axes position (using
%                            subplot or axes), imshow ignores any initial
%                            magnification you might have specified and
%                            defaults to the 'fit' behavior.
%
%                            When used with the 'Reduce' parameter, only
%                            'fit' is allowed as an initial magnification.
%
%   'Parent'                 Handle of an axes that specifies
%                            the parent of the image object created
%                            by IMSHOW.
%
%   'Reduce'                 Logical value that specifies whether IMSHOW
%                            subsamples the image in FILENAME. The 'Reduce'
%                            parameter is only valid for TIFF images and
%                            you must specify a filename. Use this
%                            parameter to display overviews of very large
%                            images.
%
%   'XData'                  Two-element vector that establishes a
%                            nondefault spatial coordinate system by
%                            specifying the image XData. The value can
%                            have more than 2 elements, but only the first
%                            and last elements are actually used.
%
%   'YData'                  Two-element vector that establishes a
%                            nondefault spatial coordinate system by
%                            specifying the image YData. The value can
%                            have more than 2 elements, but only the first
%                            and last elements are actually used.
%
%   Class Support
%   -------------  
%   A truecolor image can be uint8, uint16, single, or double. An indexed
%   image can be logical, uint8, single, or double. A grayscale image can
%   be any numeric datatype. A binary image is of class logical.
%
%   If your image is int8, int16, uint32, int32, or single, the CData in
%   the resulting image object will be double. For all other classes, the
%   CData matches the input image class.
% 
%   Image Processing Toolbox Preferences
%   ------------------------------------  
%   If you have the Image Processing Toolbox installed, you can use the
%   IPTSETPREF function to set several toolbox preferences that modify the
%   behavior of IMSHOW:
%
%   - 'ImshowBorder' controls whether IMSHOW displays the image with a border
%     around it.
%
%   - 'ImshowAxesVisible' controls whether IMSHOW displays the image with the
%     axes box and tick labels.
%
%   - 'ImshowInitialMagnification' controls the initial magnification for
%     image display, unless you override it in a particular call by
%     specifying IMSHOW(...,'InitialMagnification',INITIAL_MAG).
%   
%   For more information about these preferences, see the reference entry for
%   IPTSETPREF.
%   
%   Remarks
%   -------
%   IMSHOW is the fundamental image display function in MATLAB, optimizing
%   figure, axes, and image object property settings for image display. If
%   you have the Image Processing Toolbox installed, IMTOOL provides all
%   the image display capabilities of IMSHOW but also provides access to
%   several other tools for navigating and exploring images, such as the
%   Pixel Region tool, Image Information tool, and the Adjust Contrast
%   tool. IMTOOL presents an integrated environment for displaying images
%   and performing some common image processing tasks.
%
%   IMSHOW can be used in conjunction with SUBPLOT to create figures with
%   multiple images, even if the images have different colormaps. If a
%   colormap is specified, IMSHOW uses the COLORMAP function to change the
%   colormap of the axes containing the displayed image. In R2016a and
%   prior releases, IMSHOW changed the colormap of the figure containing
%   the image.
%
%   The IMSHOW function is not supported when MATLAB is started with the
%   -nojvm option.
%
%   Examples
%   --------
%       % Display an indexed image
%       imdata = load('clown.mat');
%       imshow(imdata.X,imdata.map)
%
%   Examples (Requires Image Processing Toolbox)
%   --------------------------------------------
%       % Display a grayscale image 
%       I = imread('cameraman.tif');
%       imshow(I) 
%
%       % Display a grayscale image, adjust the display range
%       h = imshow(I,[0 80]);
%
%       % Display a grayscale image with an
%       % associated spatial referencing object.
%       I = imread('pout.tif');
%       RI = imref2d(size(I));
%       RI.XWorldLimits = [0 3];
%       RI.YWorldLimits = [2 5];
%       imshow(I,RI);
%
%       % Display two indexed images with
%       % different colormaps in the same figure.
%       load trees
%       [X2,map2] = imread('forest.tif');
%       subplot(1,2,1), imshow(X,map)
%       subplot(1,2,2), imshow(X2,map2)
%
%       % Display a grayscale image in false colors
%       imshow('cameraman.tif', 'Colormap', summer(256))
%
%       % Change the colormap of the displayed image
%       colormap(gca, winter(256))
%
%   See also IMREAD, IMAGE, IMAGESC, IMSCROLLPANEL.

%   Copyright 1993-2017 The MathWorks, Inc.

% handle spatially referenced syntaxes.
if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

[RI,varargin] = preParseInputsForSpatialReferencing(varargin{:});
% translate older syntaxes
varargin_translated = preParseInputs(varargin{:});
% handle 'Reduce' syntax
preparsed_varargin = processReduceSyntax(varargin_translated{:});

s = settings;


[common_args,specific_args] = ...
    images.internal.imageDisplayParseInputs({'Parent','Border','Reduce'},preparsed_varargin{:});

cdata = common_args.CData;
cdatamapping = common_args.CDataMapping;
clim = common_args.DisplayRange;
map = common_args.Map;
xdata = common_args.XData;
ydata = common_args.YData;
initial_mag = common_args.InitialMagnification;

[xdata,ydata,isSpatiallyReferenced] = convertImrefToXDataYData(cdata,xdata,ydata,RI);

initial_mag_specified = ~isempty(initial_mag);

if ~initial_mag_specified
    style = s.matlab.imshow.InitialMagnificationStyle.ActiveValue;
    if strcmp(style,'numeric')
        initial_mag = s.matlab.imshow.InitialMagnification.ActiveValue;
    else
        initial_mag = style;
    end
else
    initial_mag = images.internal.checkInitialMagnification(initial_mag,{'fit'},...
        mfilename,'INITIAL_MAG', ...
        []);
end

parent_specified = isfield(specific_args,'Parent');
if parent_specified
    validateParent(specific_args.Parent)
end

new_figure = isempty(get(0,'CurrentFigure')) || ...
    strcmp(get(get(0,'CurrentFigure'), 'NextPlot'), 'new');
figureDefaultVisibleOff = false;

if parent_specified
    ax_handle = specific_args.Parent;
elseif new_figure
    figureDefaultVisibleOff = strcmp(get(groot,'DefaultFigureVisible'),'off');
    if figureDefaultVisibleOff
        fig_handle = figure;
    else
        fig_handle = figure('Visible', 'off');
    end
    ax_handle = axes('Parent', fig_handle);
else
    ax_handle = newplot;
end
fig_handle = ancestor(ax_handle,'figure');

do_fit = strcmp(initial_mag,'fit');
style = get(fig_handle,'WindowStyle');

% MOTW does not accurately report its WindowStyle. We have a different
% preference to check that is set by MOTW that will tell us if we are
% running MOTW.
dockedInMOTWContext = s.matlab.imshow.AlwaysUseFitMagnification.ActiveValue;
nonFitMagSpecifiedAsNameValue = initial_mag_specified && ~strcmp(initial_mag,'fit');
if dockedInMOTWContext
    do_fit = true;
    if nonFitMagSpecifiedAsNameValue
        warning(message('MATLAB:images:imshow:ignorningNonFitMag'))
    end
end

if ~do_fit && (strcmp(style,'docked'))
    warning('images:imshow:magnificationMustBeFitForDockedFigure', '%s', getString(message('MATLAB:images:imshow:magnificationMustBeFitForDockedFigure')))
    do_fit = true;
end

%if (size(cdata,3) > 1) && ~isempty(clim)
%    warning(message('MATLAB:images:imshow:ignoringDisplayRange'))
%end

hh = images.internal.basicImageDisplay(fig_handle,ax_handle,...
    cdata,cdatamapping,clim,map,xdata,ydata,isSpatiallyReferenced);
set(get(ax_handle,'Title'),'Visible','on')
set(get(ax_handle,'XLabel'),'Visible','on')
set(get(ax_handle,'YLabel'),'Visible','on')

single_image = images.internal.isSingleImageDefaultPos(fig_handle, ax_handle);

border = getBorder(specific_args);
is_border_tight = strcmp(border,'tight');
if single_image && do_fit && is_border_tight
    % Have the image fill the figure.
    set(ax_handle, 'Units', 'normalized', 'Position', [0 0 1 1])
    axes_moved = true;
    
elseif single_image && ~do_fit
    images.internal.initSize(hh,initial_mag/100,is_border_tight)
    axes_moved = true;
    
else
    axes_moved = false;
    
end

if axes_moved
    % The next line is so that a subsequent plot(1:10) goes back
    % to the default axes position.
    set(fig_handle, 'NextPlot', 'replacechildren')
end

if (nargout > 0)
    % Only return handle if caller requested it.
    h = hh;
end

if new_figure && ~figureDefaultVisibleOff
    set(fig_handle, 'Visible', 'on')
end

end % imshow


function border = getBorder(specific_args)

border_specified = isfield(specific_args,'Border');
if ~border_specified
    s = settings;
    border = s.matlab.imshow.BorderStyle.ActiveValue;
else
    valid_borders = {'loose','tight'};
    border = validatestring(specific_args.Border,valid_borders,mfilename,'BORDER',[]);
end

end


function validateParent(h_parent)

if ~ishghandle(h_parent)
    error('images:imshow:invalidAxes', '%s', getString(message('MATLAB:images:imshow:invalidAxes','HAX')))
end

parentType = get(h_parent,'type');
if ~strcmp(parentType,'axes')
    error('images:imshow:invalidAxes', '%s', getString(message('MATLAB:images:imshow:invalidAxes','HAX')))
end

end


function [xdata,ydata,isSpatiallyReferencedSyntax] = convertImrefToXDataYData(cdata,xdata,ydata,RI)

isSpatiallyReferencedSyntax = false;
if ~isempty(RI)
    if ~RI.sizesMatch(cdata)
        error('images:imref:sizeMismatch', '%s', getString(message('images:imref:sizeMismatch','ImageSize','imref2d')));
    end
    isSpatiallyReferencedSyntax = true;
    [xdata, ydata] = RI.intrinsicToWorld([1 RI.ImageSize(2)],[1, RI.ImageSize(1)]);
end
    
end


function [RI,varargin] = preParseInputsForSpatialReferencing(varargin)
% Preparse varargin list to pick out spatial referencing objects if they
% are specified to allow input parsing to proceed the way it always has.

spatialArgPositions = cellfun(@(c) isa(c,'imref2d'),varargin);

if ~any(spatialArgPositions)
    RI = [];
    return
end

if ~isequal(find(spatialArgPositions),2)
    error('images:imshow:incorrectImrefPosition', '%s', getString(message('MATLAB:images:imshow:incorrectImrefPosition','imshow(IMG,RI,___)')));
end

RI = varargin{2};
varargin(2) = [];
if isa(RI,'imref3d')
    error('images:imshow:imref3dNotValidRef', '%s', getString(message('MATLAB:images:imshow:imref3dNotValidRef')));
end

stringLocations = cellfun(@(c) isa(c,'char'),varargin);
for i = 1:length(stringLocations)
    if strncmpi(varargin{i},'XData',length(varargin{i})) || ...
            strncmpi(varargin{i},'YData',length(varargin{i}))
        error('images:imshow:xyDataAndImref', '%s', getString(message('MATLAB:images:imshow:xyDataAndImref','''XData''','''YData''')));
    end
end



end


function varargin_translated = preParseInputs(varargin)
% Catch old style syntaxes and error, as well as validate uses of the
% 'Reduce' param/value pair

% Removed syntaxes:
%   IMSHOW(I,N) 
%
%   IMSHOW(...,DISPLAY_OPTION) 
%
%   IMSHOW(x,y,A,...) 

new_args = {};
num_args = nargin;

if (num_args == 0)
    error('images:imshow:tooFewArgs', '%s', getString(message('MATLAB:images:imshow:tooFewArgs')))
end


if (num_args==3 || num_args==4) && ...
        isvector(varargin{1}) && isvector(varargin{2}) && ...
        isnumeric(varargin{1}) && isnumeric(varargin{2}) && ...
        (isnumeric(varargin{3}) || islogical(varargin{3}))
    % IMSHOW(x,y,...)
    error('images:imshow:invalidSyntax', '%s', getString(message('MATLAB:images:imshow:invalidSyntax')));
end

if num_args == 2 && (numel(varargin{2}) == 1)
    % IMSHOW(I,N)
    error('images:imshow:invalidSyntax', '%s', getString(message('MATLAB:images:imshow:invalidSyntax')));
end


if isempty(new_args)
    varargin_translated = varargin;
else
    varargin_translated = [varargin new_args];
end

end


function preparsed_varargin = processReduceSyntax(varargin)
% Handles the 'Reduce' P/V pair in IMSHOW syntaxes.  We have to preparse
% this particular P/V pair before we call imageDisplayParseInputs.

preparsed_varargin = varargin;

% Ignore first position if filenane is a string, looking for p/v pairs.
str_loc = cellfun('isclass',varargin,'char');
str_loc(1) = false;
first_param_loc = find(str_loc,1);
if isempty(first_param_loc)
    return
end

% scan input args looking for 'Reduce' related args
[reduce,xdata,ydata,initmag] = scanArgsForReduce(first_param_loc,varargin{:});

if reduce
    
    % Make sure we have no parameter conflicts
    checkForReduceErrorConditions(initmag,varargin{:});
    
    % get filename and file info
    filename = varargin{1};
    image_info = imfinfo(filename);
    if numel(image_info) > 1
        image_info = image_info(1);
        warning('images:imshow:multiframeFile', '%s', getString(message('MATLAB:images:imshow:multiframeFile', filename)));
    end
    
    try
        % find sample factor
        [usableWidth, usableHeight] = getUsableScreenSize;

        sampleFactor = max(ceil(image_info.Width / usableWidth), ...
            ceil(image_info.Height / usableHeight));
        
        sampled_rows = images.internal.getReduceSampling(image_info.Height,sampleFactor);
        sampled_cols = images.internal.getReduceSampling(image_info.Width,sampleFactor);

        [imageData, colormap] = imread(filename, 'PixelRegion', ...
            {[sampled_rows(1) sampleFactor sampled_rows(end)], ...
            [sampled_cols(1) sampleFactor sampled_cols(end)]});
        
        % if we subsample and initmag is not 'fit', warn
        initmag_is_fit = ~isempty(initmag) && strcmpi(initmag,'fit');
        if sampleFactor > 1 && ~initmag_is_fit
            warning('images:imshow:reducingImage', '%s', getString(message('MATLAB:images:imshow:reducingImage', makeDataPercentString( sampleFactor ))));
        end
        
        % if we have read an intensity image, do not supply empty map
        if isempty(colormap)
            preparsed_varargin = {imageData,varargin{2:end}};
        else
            preparsed_varargin = {imageData,colormap,varargin{2:end}};
        end
        
    catch %#ok<CTCH>
        error('images:imshow:unableToReduce', '%s', getString(message('MATLAB:images:imshow:unableToReduce', filename)));
    end
    
    % we slightly modify the X & Y Data to take into account the sampling
    % of the image
    new_xdata = adjustXYData(xdata,image_info.Width,sampled_cols);
    p = length(preparsed_varargin);
    preparsed_varargin{p+1} = 'XData';
    preparsed_varargin{p+2} = new_xdata;
    
    new_ydata = adjustXYData(ydata,image_info.Height,sampled_rows);
    p = length(preparsed_varargin);
    preparsed_varargin{p+1} = 'YData';
    preparsed_varargin{p+2} = new_ydata;
    
end

end


function [reduce,xdata,ydata,initmag] = scanArgsForReduce(first_param_loc, varargin)
% Make initial pass through param list.  Check for presence of 'Reduce'
% param/value pair as well as user provided X/YData and InitMag.

reduce = false;
xdata = [];
ydata = [];
initmag = [];
isParam = @(arg,param) ~isempty(strmatch(lower(arg),{param}));
for i = first_param_loc:2:numel(varargin)-1
    
    % check for provided x/y data
    if isParam(varargin{i},'xdata')
        xdata = varargin{i+1};
        continue
    end
    if isParam(varargin{i},'ydata')
        ydata = varargin{i+1};
        continue
    end

    % check for initial magnification
    if isParam(varargin{i},'initialmagnification')
        initmag = varargin{i+1};
        continue
    end

    % check for reduce
    if isParam(varargin{i},'reduce')
        reduce = varargin{i+1};
        validateattributes(reduce,{'numeric','logical'},{'nonempty'},...
            mfilename,'Reduce', i+1);
        continue
    end
end

end


function checkForReduceErrorConditions(initmag,varargin)
% checks for several error conditions that can occur with uses of 'Reduce'
% parameter.

% Check for the IMSHOW(FILENAME,...) syntax
filename_syntax = ischar(varargin{1});
if ~filename_syntax
    error('images:imshow:badReduceSyntax', '%s', getString(message('MATLAB:images:imshow:badReduceSyntax')))
end
filename = varargin{1};

% Check for supplied 'InitialMagnification' param/value pair
if ~isempty(initmag)
    if isnumeric(initmag)
        error('images:imshow:incompatibleParameters', '%s', getString(message('MATLAB:images:imshow:incompatibleParameters')))
    end
end

% Verify input file is a TIFF file for Reducing
image_info = imfinfo(filename);
image_info = image_info(1);
if ~strcmpi(image_info.Format,'tif')
    error('images:imshow:badReduceFormat', '%s', getString(message('MATLAB:images:imshow:badReduceFormat')))
end

end


function string_value = makeDataPercentString(sampleFactor)
% generates magnification string with significant digits that change based
% on the magnitude

actual_val = 100 / sampleFactor;
if actual_val < 1
    string_value = sprintf('%.2f',actual_val);
elseif actual_val < 10
    string_value = sprintf('%.1f',actual_val);
else
    string_value = sprintf('%d',round(actual_val));
end

end


function [usableWidth, usableHeight] = getUsableScreenSize
% returns the width and height of the usable screen area.  Assumes 'Border'
% is loose for simplicity

% get the size of screen and the figure decorations
wa = images.internal.getWorkArea;
p  = images.internal.figparams;

% compute usable area
usableWidth = wa.width - p.horizontalDecorations - p.looseBorderWidth;
usableHeight = wa.height - p.verticalDecorations - p.looseBorderHeight;
  
end


function new_data = adjustXYData(default_data,image_dim,samples)
% adjusts the X and Y data to account for sub sampling.

% provide default XYData if none was specified
if isempty(default_data)
    default_data = [1 image_dim];
end

% verify x/ydata is 2-element numeric
if ~isequal(numel(default_data),2) || ~isnumeric(default_data)
    error('images:imshow:invalidXYData', '%s', getString(message('MATLAB:images:imshow:invalidXYData')))
end

% adjust the endpoints of the X/YData to account for clipped pixels
spatial_to_pixel_ratio = (default_data(2) - default_data(1)) / (image_dim - 1);

% start clipping
first_pixel = samples(1);
removed_pixels = first_pixel - 1;
removed_spatial_units = removed_pixels * spatial_to_pixel_ratio;
first_spatial_coord = default_data(1) + removed_spatial_units;

% end clipping
last_pixel = samples(end);
removed_pixels = image_dim - last_pixel;
removed_spatial_units = removed_pixels * spatial_to_pixel_ratio;
last_spatial_coord = default_data(2) - removed_spatial_units;

new_data = [first_spatial_coord last_spatial_coord];

end
