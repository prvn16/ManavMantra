function varargout = colorcloud(RGB, varargin)
%COLORCLOUD Display 3D color gamut in specified color space.
%
%   colorcloud(RGB) displays the full color gamut of the truecolor image
%   RGB in the RGB color space.
%
%   colorcloud(RGB,colorspace) displays the full color gamut of the
%   truecolor image RGB in the color space specified by colorspace.
%   colorspace can be one of the following values.
%
%       Values:
%
%       'rgb'         Displays color gamut in RGB color space. 
%       'hsv'         Displays color gamut in HSV color space.
%       'ycbcr'       Displays color gamut in YCbCr color space. 
%       'lab'         Displays color gamut in CIE 1976 L*a*b* color space.
%
%   colorcloud(____,NAME,VALUE) displays the full color gamut using
%   name-value pairs to control the visualization of the color gamut.
%
%   Parameters include:
%
%   'Parent'                 Handle of a figure or uipanel that specifies
%                            the parent of the object created by
%                            colorcloud. If no valid handle is assigned, a
%                            new figure window is created.
%
%   'BackgroundColor'        Color of the color cloud background, defined 
%                            as MATLAB ColorSpec. Default value: 
%                            [0.94 0.94 0.94].
%
%   'WireFrameColor'         Color of the color space wire frame, defined 
%                            as MATLAB ColorSpec. If a value of 'none' is 
%                            specified, the wire frame is removed. Default 
%                            value: 'black'.
%
%   'OrientationAxesColor'   Color of the orientation axes and labels, 
%                            defined as MATLAB ColorSpec. If a value of 
%                            'none' is specified, the labels are removed. 
%                            Default value: 'black'.
%
%   hPanel = colorcloud(____) returns the handle to the uipanel object
%   created by colorcloud.
%
%   Example 
%   ------- 
%   View the 3D color gamut of an RGB image in HSV color space.
%
%   % Read in RGB image 
%   RGB = imread('peppers.png');
%
%   % View color gamut 
%   colorcloud(RGB,'hsv');

%   Copyright 2016-2017 The MathWorks, Inc.


validateInputImage(RGB);
args = matlab.images.internal.stringToChar(varargin);
options = parseOptionalInputs(args{:});

% Set up panel and initial viewpoint
if isa(options.Parent,'matlab.ui.container.Panel')
    % If parent is panel, then use that panel
    hPanel = options.Parent;
elseif isa(options.Parent,'matlab.ui.Figure')
    % If parent is figure, then create panel as child
    hPanel = uipanel('Parent',options.Parent);
else
    % If no parent is specified, create new figure
    hFig = figure;
    hPanel = uipanel('Parent',hFig);
    
    % Strip toolbar of incompatible features    
    hFig.MenuBar = 'none';
    hFig.ToolBar = 'figure';
    
    hObjects = findall(hFig,'Tag','Exploration.Brushing','-or',...
        'Tag','DataManager.Linking','-or',...
        'Tag','Annotation.InsertColorbar','-or',...
        'Tag','Plottools.PlottoolsOn','-or',...
        'Tag','Plottools.PlottoolsOff','-or',...
        'Tag','Annotation.InsertLegend');
    
    arrayfun(@(h) set(h,'Separator','off'),hObjects);
    arrayfun(@(h) set(h,'Visible','off'),hObjects);
    
end

hAx = axes('Parent',hPanel);

% Convert RGB data into specified colorspace
colorData = computeColorspaceRepresentation(RGB,options.ColorSpace);

% Resize data into 1D array
rgbClass = class(RGB);
[m,n,~] = size(RGB);
colorData = reshape(colorData,[m*n 3]);
RGB = reshape(RGB,[m*n 3]);

% Downsample to 2e6 points if image is large to keep number of points in
% scatter plot manageable
targetNumPoints = 2e6;
numPixels = m*n;

if numPixels > targetNumPoints
    sampleFactor = round(numPixels/targetNumPoints);
    colorData = colorData(1:sampleFactor:end,:);
    RGB = RGB(1:sampleFactor:end,:);
end

createScatter(hAx,colorData,RGB,options.ColorSpace);

if ~isempty(options.WireFrameColor)
    createWireFrame(hAx,options,rgbClass);
end

setAxesProperties(hPanel,hAx,options);

if ~isempty(options.OrientationAxesColor)
    createOrientationAxes(hPanel,hAx,options);
end

% Return handle for panel if specified as output
if nargout > 0
    varargout{1} = hPanel;
end

end


function createScatter(hAx,colorData,RGB,csname)

switch (csname)
    case 'RGB'
        scatter3(hAx,colorData(:,1),colorData(:,2),colorData(:,3),6,im2double(RGB),'.');
        
    case 'HSV'
        % Convert to cartesian coordinates from conical coordinates for
        % plotting with scatter3
        Xcoord = colorData(:,2).*colorData(:,3).*cos(2*pi*colorData(:,1));
        Ycoord = colorData(:,2).*colorData(:,3).*sin(2*pi*colorData(:,1));
        Zcoord = colorData(:,3);
        
        scatter3(hAx,Xcoord,Ycoord,Zcoord,6,im2double(RGB),'.');
        view(hAx,20,30);
        
    case 'YCbCr'
        scatter3(hAx,colorData(:,2),colorData(:,3),colorData(:,1),6,im2double(RGB),'.');

    case 'Lab'
        scatter3(hAx,colorData(:,2),colorData(:,3),colorData(:,1),6,im2double(RGB),'.');

    otherwise
        assert(false,'Unknown color space specified.');
end

end

function cdata = computeColorspaceRepresentation(RGB,csname)

% Convert data into specified colorspace representation
switch (csname)   
    case 'RGB'
        cdata = RGB;
    case 'HSV'
        cdata = rgb2hsv(RGB);
    case 'YCbCr'
        cdata = rgb2ycbcr(RGB);
    case 'Lab'
        cdata = rgb2lab(RGB);
    otherwise
        assert(false,'Unknown color space specified.')
end

end

function setAxesProperties(hPanel, hAx, options)

    % Set panel properties
    set(hPanel,'Units','normalized',...
        'BorderType','none');
    
    % Set background color
    if ~isempty(options.BackgroundColor)
        set(hPanel,'BackgroundColor',options.BackgroundColor);
    end   
    
    % Set axes properties
    set(hAx,'Visible','off',...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','ColorCloudAxes');
    
    axis(hAx,'tight');
    axis(hAx,'vis3d');
    
    % Turn on rotation and data cursor
    if isempty(options.Parent)
        rotate3d(hAx,'on');
        dcm_obj = datacursormode(get(hPanel,'Parent'));
        set(dcm_obj,'UpdateFcn',@(hobj,evt) updateDataTip(hobj,evt,options.ColorSpace))
    end

end

function createWireFrame(hAx, options, rgbClass)

    switch options.ColorSpace
        case 'RGB'
            [x,y,z] = getRGBCoordinates();
            x = rescaleWireFrameCoordinates(x,rgbClass);
            y = rescaleWireFrameCoordinates(y,rgbClass);
            z = rescaleWireFrameCoordinates(z,rgbClass);
            for ii = 1:size(x,2)
                line('Parent',hAx,'XData',x(:,ii),'YData',y(:,ii),'ZData',z(:,ii),'Color',options.WireFrameColor,'LineWidth',1,'HitTest','off');
            end
            
        case 'HSV'
            % Create circumferential ring for wireframe
            ang=(0:0.05:2*pi+0.05)';
            xp=cos(ang);
            yp=sin(ang);
            line('Parent',hAx,'XData',xp,'YData',yp,'ZData',ones(numel(xp),1),'Color',options.WireFrameColor,'LineWidth',1,'HitTest','off');
            % Create radial spokes for wireframe
            ang = 0:pi/4:2*pi;
            xp = [zeros(1,numel(ang)); cos(ang)];
            yp = [zeros(1,numel(ang)); sin(ang)];
            zp = [zeros(1,numel(ang)); ones(1,numel(ang))];
            for ii = 1:size(xp,2)
                line('Parent',hAx,'XData',xp(:,ii),'YData',yp(:,ii),'ZData',zp(:,ii),'Color',options.WireFrameColor,'LineWidth',1,'HitTest','off');
            end

        case 'YCbCr'
            % Get data and transform it into YCbCr space
            [cData(:,:,1),cData(:,:,2),cData(:,:,3)] = getRGBCoordinates();
            cData = rescaleWireFrameCoordinates(cData,rgbClass);
            wireData = computeColorspaceRepresentation(cData,options.ColorSpace);
            % Plot converted coordinates
            x = squeeze(wireData(:,:,1));
            y = squeeze(wireData(:,:,2));
            z = squeeze(wireData(:,:,3));
            for ii = 1:size(x,2)
                line('Parent',hAx,'XData',y(:,ii),'YData',z(:,ii),'ZData',x(:,ii),'Color',options.WireFrameColor,'LineWidth',1,'HitTest','off');
            end
            
        case 'Lab'
            % Generate lines in RGB space
            rgbNum = uint8((0:255)');
            zvec = uint8(zeros(numel(rgbNum),1));
            ovec = uint8(ones(numel(rgbNum),1)*255);
            wireFrame(:,:,1) = [rgbNum rgbNum zvec ovec rgbNum rgbNum zvec ovec zvec ovec zvec ovec];
            wireFrame(:,:,2) = [zvec ovec rgbNum rgbNum zvec ovec rgbNum rgbNum zvec zvec ovec ovec];
            wireFrame(:,:,3) = [zvec zvec zvec zvec ovec ovec ovec ovec rgbNum rgbNum rgbNum rgbNum];
            % Convert to class of input image
            wireFrame = rescaleWireFrameCoordinates(wireFrame,rgbClass);
            % Convert wireframe to L*a*b* color space
            transformedWire = computeColorspaceRepresentation(wireFrame,options.ColorSpace);
            % Plot converted coordinates
            for ii = 1:size(transformedWire,2)
                line('Parent',hAx,'XData',transformedWire(:,ii,2),'YData',transformedWire(:,ii,3),'ZData',transformedWire(:,ii,1),'Color',options.WireFrameColor,'LineWidth',1,'HitTest','off');
            end
            
    end
    
end

function createOrientationAxes(hPanel, hAx, options)

    hOrientAx = axes('Parent',hPanel);
    set(hOrientAx,'Units','normalized',...
        'Position',[0.84 0.04 0.12 0.12],...
        'Tag','OrientationAxes',...
        'HitTest','off',...
        'Visible','off');
    
    switch options.ColorSpace      
        case 'RGB'
            labels = {'R','G','B'};
        case 'HSV'   
            labels = {'S','H','V'};
            x = [0 0; 1 0];
            y = [0 0; 0 0];
            z = [0 0; 0 1];
            ang=(0:0.05:pi/2)';
            r = 0.8;
            xp=r*cos(ang);
            yp=r*sin(ang);
            xp(end+1) = 0;
            yp(end+1) = r;
            line('Parent',hOrientAx,'XData',xp,'YData',yp,'Color',options.OrientationAxesColor,'LineWidth',1);
            % Lines defined so that the length and width of the arrow head are
            % 20% of the length of the axes
            xarrow = [1 1 0 0 0 0; 0.8 0.8 0.2 0.2 0.1/sqrt(2) -0.1/sqrt(2)];
            yarrow = [0 0 r r 0 0; 0 0 r+0.1 r-0.1 -0.1/sqrt(2) 0.1/sqrt(2)];
            zarrow = [0 0 0 0 1 1; 0.1 -0.1 0 0 0.8 0.8];
        case 'YCbCr'
            labels = {'Cb','Cr','Y'};
        case 'Lab'
            labels = {'a*','b*','L*'};
    end

    if ~strcmp(options.ColorSpace,'HSV')
        x = [0 0 0; 1 0 0];
        y = [0 0 0; 0 1 0];
        z = [0 0 0; 0 0 1];
        % Lines defined so that the length and width of the arrow head are
        % 20% of the length of the axes
        xarrow = [1 1 0 0 0 0; 0.8 0.8 0 0 0.1/sqrt(2) -0.1/sqrt(2)];
        yarrow = [0 0 1 1 0 0; 0 0 0.8 0.8 -0.1/sqrt(2) 0.1/sqrt(2)];
        zarrow = [0 0 0 0 1 1; 0.1 -0.1 0.1 -0.1 0.8 0.8];
    end
    
    text('Position',[1 0 0.3],'String',labels{1},'Color',options.OrientationAxesColor,'Parent',hOrientAx);
    text('Position',[0 1 0.3],'String',labels{2},'Color',options.OrientationAxesColor,'Parent',hOrientAx);
    text('Position',[0 0 1.3],'String',labels{3},'Color',options.OrientationAxesColor,'Parent',hOrientAx);
    
    for ii = 1:size(x,2)
        line('Parent',hOrientAx,'XData',x(:,ii),'YData',y(:,ii),'ZData',z(:,ii),'LineWidth',1,'Color',options.OrientationAxesColor)
    end
    for ii = 1:size(xarrow,2)
        line('Parent',hOrientAx,'Xdata',xarrow(:,ii),'YData',yarrow(:,ii),'ZData',zarrow(:,ii),'LineWidth',1,'Color',options.OrientationAxesColor)
    end
    axis(hOrientAx,'tight');
    axis(hOrientAx,'equal');
    axis(hOrientAx,'vis3d');
    uistack(hOrientAx,'top');

    view(hOrientAx,hAx.View(1),hAx.View(2));
    
    % Listener to rotate orientation axes as the point cloud is rotated
    addlistener(hAx,'View','PostSet',@(hobj,evt) rotateColorSpaceCallback(hobj,evt,hOrientAx));

end

function rotateColorSpaceCallback(~,evt,hOrientAx)

    set(hOrientAx,'View',evt.AffectedObject.View)

end

function txt = updateDataTip(~,evt,csname)

% Get position of data cursor and display color space data
pos = get(evt,'Position');

switch (csname)
    
    case 'RGB'
        txt = {['R: ',num2str(pos(1))],...
	      ['G: ',num2str(pos(2))],...
          ['B: ',num2str(pos(3))]};  
    case 'HSV'
        % Convert cartesian to conical coordinates 
        rootPortion = sqrt(pos(1)^2 + pos(2)^2);
        s = rootPortion/pos(3);
        h = acos(pos(1)/rootPortion)/(2*pi);
        % Adjustment needed for third and fourth quadrant values
        if pos(2) < 0
            h = 1-h;
        end
        txt = {['H: ',num2str(h,'%0.3f')],...
	      ['S: ',num2str(s,'%0.3f')],...
          ['V: ',num2str(pos(3),'%0.3f')]}; 
    case 'YCbCr'
        txt = {['Y: ',num2str(pos(3))],...
	      ['Cb: ',num2str(pos(1))],...
          ['Cr: ',num2str(pos(2))]}; 
    case 'Lab'
        txt = {['L*: ',num2str(pos(3),'%0.3f')],...
	      ['a*: ',num2str(pos(1),'%0.3f')],...
          ['b*: ',num2str(pos(2),'%0.3f')]}; 

end

end

function out = rescaleWireFrameCoordinates(data,rgbClass)
    % Assuming all input data is the coordinates for uint8 RGB color space,
    % stored as an array of type double. Coordinates are returned in data
    % type that matches input image for conversion to YCbCr color space.
    switch rgbClass
        case 'uint8'
            out = uint8(data);
        case 'uint16'
            out = uint16(round(data*257));
        case {'single','double'}
            out = data/255;
    end

end

function [x,y,z] = getRGBCoordinates()

% Return x,y,z coordinates of RGB space
x = [0 0 0 255 255 255 255 255 255 0 0 0; 255 0 0 0 255 255 255 0 255 0 255 0];
y = [0 0 0 255 255 255 0 0 0 255 255 255; 0 255 0 255 0 255 255 0 0 0 255 255];
z = [0 0 0 0 0 0 255 255 255 255 255 255; 0 0 255 0 0 255 255 255 0 255 255 0];

end

function options = parseOptionalInputs(varargin)

% Define structure holding default values for optional arguements and
% Name/Value pairs
options = struct('ColorSpace','RGB',...
'Parent',[],...
'WireFrameColor',[0 0 0],...
'BackgroundColor', [0.94 0.94 0.94],...
'OrientationAxesColor',[0 0 0]);

% Validate color space
if mod(numel(varargin),2) ~= 0
    options.ColorSpace = validateColorSpaceName(varargin{1});
    beginningOfNameVal = 2;
else
    beginningOfNameVal = 1;
end

% Validate name/value pairs
ParamName = {'Parent','WireFrameColor','BackgroundColor','OrientationAxesColor'};
ValidateFcn = {@validateParent, @validateColor, @validateColor, @validateColor};

for p = beginningOfNameVal:2:length(varargin)

    name  = varargin{p};
    value = varargin{p+1};

    % Look for the parameter amongst the possible values.
    logical_idx = strncmpi(name, ParamName, numel(name));

    if ~any(logical_idx)
        error(message('images:colorcloud:unknownParameterName',name));
    elseif numel(find(logical_idx)) > 1
        error(message('images:colorcloud:ambiguousParameterName',name));
    end

    % Validate the value.
    validateFcn = ValidateFcn{logical_idx};
    options.(ParamName{logical_idx}) = validateFcn(value);

end

end

function csname = validateColorSpaceName(nameInput)

% Check that color space name is a string
if ~ischar(nameInput)
    error(message('images:colorcloud:requireStringColorSpace'));
end

% Check color space name
ColorSpaceName = {'rgb','hsv','ycbcr','lab'};
idx = strncmpi(nameInput, ColorSpaceName, numel(nameInput));

if ~any(idx)
    error(message('images:colorcloud:unknownColorSpace',nameInput));
elseif numel(find(idx)) > 1
    error(message('images:colorcloud:ambiguousColorSpace',nameInput));
end

switch find(idx)      
    case 1          
        csname = 'RGB';
    case 2          
        csname = 'HSV';
    case 3          
        csname = 'YCbCr';
    case 4
        csname = 'Lab';
end
    
end

function hParent = validateParent(inHandle)

% Check if Parent is a valid uipanel of figure handle
if ~isempty(inHandle) && isgraphics(inHandle) && (isa(inHandle,'matlab.ui.container.Panel') || isa(inHandle,'matlab.ui.Figure'))
    hParent = inHandle;
else       
    error(message('images:colorcloud:requireValidHandle'))  
end

end

function rgbColor = validateColor(inColor)

% Check for the specification of 'none' and use the provided value for
% color. This value gets checked for error when it is utilized later
if isa(inColor,'char') && strcmpi(inColor,'none')
    rgbColor = [];
else
    rgbColor = convertColorSpec(images.internal.ColorSpecToRGBConverter,inColor);
end

end

function validateInputImage(RGB)

supportedImageClasses = {'uint8','uint16','single','double'};
supportedImageAttributes = {'real','nonsparse','nonempty','ndims',3};
validateattributes(RGB,supportedImageClasses,supportedImageAttributes,'colorcloud','RGB');

if size(RGB,3) ~= 3
    error(message('images:colorcloud:requireRGBInput'));
end

floatDataOutsideZeroOneRange = isfloat(RGB) && (max(RGB(:)) > 1 || min(RGB(:)) < 0);

if floatDataOutsideZeroOneRange
    error(message('images:colorcloud:requireScaledFloatInput'));
end
    
end