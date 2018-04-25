function hh = colordef(arg1,arg2)
%COLORDEF Set color defaults.
%   COLORDEF WHITE or COLORDEF BLACK changes the color defaults on the
%   root so that subsequent figures produce plots with a white or
%   black axes background color.  The figure background color and
%   many other defaults are changed so that there will be adequate
%   contrast for most plots.
%
%   COLORDEF NONE will set the defaults to their MATLAB 4 values.
%   The most noticeable difference is that the axis background is set
%   to 'none' so that the axis background and figure background colors
%   are the same.  The figure background color is set to black.
%
%   COLORDEF(FIG,OPTION) changes the defaults of the figure FIG
%   based on OPTION.  OPTION can be 'white','black', or 'none'.
%   The figure must be cleared first (via CLF) before using this
%   variant of COLORDEF.
%
%   H = COLORDEF('new',OPTION) returns a handle to a new figure
%   created with the specified default OPTION.  This form of the
%   command is handy in GUI's where you may want to control the
%   default environment.  The figure is created with 'visible','off'
%   to prevent flashing.
%
%   See also WHITEBG.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    arg1 = convertStringsToChars(arg1);
end

if nargin > 1
    arg2 = convertStringsToChars(arg2);
end

narginchk(1,2);

% If only one input, then set properties on the root
if nargin==1
  fig = 0;
  option = arg1;
elseif nargin==2
    if ischar(arg1)
        % If first input is a string, it must be the string 'new'
        if ~strcmpi(arg1, 'new')
            error(message('MATLAB:colordef:InvalidOption'));
        else
            % Create a new, invisible figure
            fig = figure('visible', 'off');
        end
    % All non-character inputs must be handles to figures or the root 
    elseif all(isgraphics(arg1))
        if isscalar(arg1) && ~isgraphics(arg1, 'figure') && ~isgraphics(arg1, 'root')
            % If the first input is a scalar handle, it can be the root 
            % object or a figure window
            error(message('MATLAB:colordef:RootOrFigureHandle'));
        elseif ~isscalar(arg1) && ~all(isgraphics(arg1, 'figure'))
            error(message('MATLAB:colordef:FigureHandleExpected'));
        else
            fig = arg1;
        end
    else
        error(message('MATLAB:colordef:InvalidHandle'));
    end
    option = arg2;
end

if all(isgraphics(fig, 'figure')) && ~isempty(findobj(fig, '-regexp', 'Type', '.*axes'))
    error(message('MATLAB:colordef:MustClearFigure'));
end



switch option
case 'white'
  wdefault(fig)
case 'black'
  kdefault(fig)
case 'none'
  default4(fig)
otherwise
  error(message('MATLAB:colordef:UnknownDefaultOption', option))
end

if nargout>0, hh = fig; end

%----------------------------------------------------------
function kdefault(fig)
%KDEFAULT Black figure and axes defaults.
%   KDEFAULT sets up certain figure and axes defaults
%   for plots with a black background.
%
%   KDEFAULT(FIG) only affects the figure with handle FIG.

if nargin==0, fig = 0; end

whitebg(fig,[0 0 0])

gray85 = [.85 .85 .85];

fc = [.15 .15 .15];

if fig==0
  set(fig,'DefaultFigureColor',fc)
else
  set(fig,'color',fc)
end
set(fig,'DefaultAxesColor',[0 0 0])
colors =[  255   255  17;
           19    159  255;
           255   105  41;
           100   212  19;
           183   70   255;
           15    255  255;
           255   19   166 ]/255; % Scope axes colors used for black scheme
set(fig,'DefaultAxesColorOrder', colors);
set(fig,'DefaultPolarAxesColor',[0 0 0])
set(fig,'DefaultPolarAxesColorOrder', colors);
if fig == 0
  cmap = 'DefaultFigureColormap';
else
  cmap = 'colormap';
end
set(fig,cmap,'factory')
set(fig,'DefaultSurfaceEdgeColor',[0 0 0])
set(fig,'DefaultTextColor', gray85)
set(fig,'DefaultAxesXColor', gray85)
set(fig,'DefaultAxesYColor', gray85)
set(fig,'DefaultAxesZColor', gray85)
set(fig,'DefaultAxesGridColor', gray85)
set(fig,'DefaultAxesGridAlpha', 0.35)
set(fig,'DefaultAxesMinorGridColor', gray85)
set(fig,'DefaultAxesMinorGridAlpha', 0.5)
set(fig,'DefaultPolarAxesThetaColor', gray85)
set(fig,'DefaultPolarAxesRColor', gray85)
set(fig,'DefaultPolarAxesGridColor', gray85)
set(fig,'DefaultPolarAxesGridAlpha', 0.35)
set(fig,'DefaultPolarAxesMinorGridColor', gray85)
set(fig,'DefaultPolarAxesMinorGridAlpha', 0.5)

%------------------------------------------------------------
function wdefault(fig)
%WDEFAULT White figure and axes defaults
%   WDEFAULT sets up certain figure and axes defaults
%   for plots with a white background.  This is
%   accomplished by reverting to factory settings.
%
%   WDEFAULT(FIG) only affects the figure with handle FIG.

if nargin==0, fig = 0; end

whitebg(fig,[1 1 1])
if fig==0
  set(fig,'DefaultFigureColor', 'factory')
else
  set(fig,'color', 'factory')
end
set(fig,'DefaultAxesColor', 'factory')
set(fig,'DefaultAxesColorOrder', 'factory');
set(fig,'DefaultPolarAxesColor', 'factory')
set(fig,'DefaultPolarAxesColorOrder', 'factory');
if fig == 0 
  cmap = 'DefaultFigureColormap';
else
  cmap = 'colormap';
end
set(fig,cmap,'factory')
set(fig,'DefaultSurfaceEdgeColor', 'factory')
set(fig,'DefaultTextColor', 'factory')
set(fig,'DefaultAxesXColor', 'factory')
set(fig,'DefaultAxesYColor', 'factory')
set(fig,'DefaultAxesZColor', 'factory')
set(fig,'DefaultAxesGridColor', 'factory')
set(fig,'DefaultAxesGridAlpha', 'factory') % Reset to 'factory' in whitebg call above as well
set(fig,'DefaultAxesMinorGridColor', 'factory')
set(fig,'DefaultAxesMinorGridAlpha', 'factory') % Reset to 'factory' in whitebg call above as well
set(fig,'DefaultPolarAxesThetaColor', 'factory')
set(fig,'DefaultPolarAxesRColor', 'factory')
set(fig,'DefaultPolarAxesGridColor', 'factory')
set(fig,'DefaultPolarAxesGridAlpha', 'factory') % Reset to 'factory' in whitebg call above as well
set(fig,'DefaultPolarAxesMinorGridColor', 'factory')
set(fig,'DefaultPolarAxesMinorGridAlpha', 'factory') % Reset to 'factory' in whitebg call above as well

%----------------------------------------------------------------
function default4(fig)
%DEFAULT MATLAB version 4.0 figure and axes defaults.
%   DEFAULT4 sets certain figure and axes defaults to match what were
%   the defaults for MATLAB version 4.0.
%
%   DEFAULT4(FIG) only affects the figure with handle FIG.

if nargin==0, fig = 0; end
set(fig,'DefaultAxesColor','none')
whitebg(fig,[0 0 0])
set(fig,'DefaultAxesColorOrder',[1 1 0;1 0 1;0 1 1;1 0 0;0 1 0;0 0 1]) % ymcrgb
if fig == 0
  cmap = 'DefaultFigureColormap';
else
  cmap = 'colormap';
end
set(fig,cmap,hsv(64))
set(fig,'DefaultSurfaceEdgeColor',[0 0 0])
