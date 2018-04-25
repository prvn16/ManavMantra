function h = viscircles(varargin)
%VISCIRCLES Create circle.
%   VISCIRCLES(CENTERS, RADII) adds circles with specified CENTERS and
%   RADII to the current axes. CENTERS is a 2-column matrix with
%   X-coordinates of the circle centers in the first column and
%   Y-coordinates in the second column. RADII is a vector which specifies
%   radius for each circle. By default the circles are red.
%
%   VISCIRCLES(AX, CENTERS, RADII) adds circles to the axes specified by
%   AX.
%
%   H = VISCIRCLES(AX, CENTERS, RADII) returns a handle to an hggroup
%   object for the circles. H is a child of the axes object, AX.
%
%   H = VISCIRCLES(...,PARAM1,VAL1,PARAM2,VAL2,...) passes the name-value
%   pair arguments to specify additional properties of the circles.
%   Parameter names can be abbreviated.
%
%   'Color'
%       <a href="matlab:doc('ColorSpec')">ColorSpec</a>
%       Specifies the color of the circle edges.
%
%   'LineStyle'
%       {-} | -- | : | -. | none
%       Line style of circle edge.
%       <a href="matlab:helpview(fullfile(docroot,'toolbox','images','images.map'),'viscircles_linespec')">Line Style Specifiers Table</a>
%
%   'LineWidth'
%       size in points
%       Width of the circles edge line. Specify this value in points. 1
%       point = 1/72 inch. The default value is 2 points.
% 
%   'EnhanceVisibility'
%       Specifies whether or not to augment the drawn circles with
%       contrasting features to improve visibility on a varying background.
%       Setting the value to true draws an augmented boundary and setting
%       it to false does not. Default value is true.
%                         
%   Example 1
%   ---------
%   This example finds both bright and dark circles in the image.
%
%         I = imread('circlesBrightDark.png');
%         imshow(I)
% 
%         Rmin = 30;
%         Rmax = 65;
% 
%         % Find all the bright circles in the image
%         [centersBright, radiiBright] = imfindcircles(I,[Rmin Rmax], ...
%                                       'ObjectPolarity','bright');
% 
%         % Find all the dark circles in the image
%         [centersDark, radiiDark] = imfindcircles(I, [Rmin Rmax], ...
%                                       'ObjectPolarity','dark');
% 
%         % Plot bright circles in blue
%         viscircles(centersBright, radiiBright,'Color','b');
% 
%         % Plot dark circles in dashed red boundaries
%         viscircles(centersDark, radiiDark,'LineStyle','--');
%
%   Example 2
%   ---------
%   VISCIRCLES does not clear the axes before plotting circles. Use CLA to 
%   remove content that has been previously plotted in the axes.
%
%         % Create a new figure and define colors to plot with
%         figure
%         colors = {'b','r','g','y','k'}; 
%
%         for k = 1:5
%             % Create 5 random circles to display
%             X = rand(5,1);
%             Y = rand(5,1);
%             centers = [X Y];
%             radii = 0.1*rand(5,1);
%
%             % Clear the axes
%             cla
%
%             % Fix the axis limits
%             xlim([-0.1 1.1])
%             ylim([-0.1 1.1])
%
%             % Set the axis aspect ratio to 1:1
%             axis square
%
%             % Set a title
%             title(['k = ' num2str(k)])
%
%             % Display the circles
%             viscircles(centers,radii,'Color',colors{k});
%             
%             % Pause for 1 second
%             pause(1)
%         end
%                    
% See also IMDISTLINE, IMFINDCIRCLES, IMTOOL, VISBOUNDARIES.

%   Copyright 2011-2017 The MathWorks, Inc.
 
%   'EdgeColor'
%       <a href="matlab:doc('ColorSpec')">ColorSpec</a>
%       Specifies the color of the circle edges.
% 
%   'DrawBackgroundCircle'
%       Specifies whether or not to draw the contrasting background circle
%       below the colored circle. Setting the value to 'true' draws the
%       background circle and setting it to 'false' does not draw the
%       background circle. Default value is 'true'.

varargin = matlab.images.internal.stringToChar(varargin);

[ax, centers, radii, options] = parseInputs(varargin{:});

if isempty(centers)
    h = [];
    return;
end

isHoldOn = ishold;
hold on;
cObj = onCleanup(@()preserveHold(isHoldOn)); % Preserve original hold state

thetaResolution = 2; 
theta=(0:thetaResolution:360)'*pi/180;

x = bsxfun(@times,radii',cos(theta));
x = bsxfun(@plus,x,(centers(:,1))');
x = cat(1,x,nan(1,length(radii)));
x = x(:);

y = bsxfun(@times,radii',sin(theta));
y = bsxfun(@plus,y,(centers(:,2))');
y = cat(1,y,nan(1,length(radii)));
y = y(:);

% Create hggroup object that will contain the two circles as children
h = hggroup('Parent', ax);

% Draw the thinner foreground colored circle
thinCircHdl = line(x,y,'Parent',h, ...
                   'Color',options.Color, ...
                   'LineWidth',options.LineWidth, ...
                   'LineStyle',options.LineStyle);

if options.EnhanceVisibility
    % Draw the thicker background white circle
        
    thickEdgeColor = 'w';    
    thickLineWidth = options.LineWidth + 1;
    if (strcmpi(options.LineStyle,'none'))
        thickLineStyle = 'none';
    else
        thickLineStyle = '-';
    end

    line(x,y,'Parent',h, ...
        'Color',thickEdgeColor, ...
        'LineWidth',thickLineWidth, ...
        'LineStyle',thickLineStyle);

    % Bring the thin foreground circle on top
    uistack(thinCircHdl,'up');
    
end

end

% -------------------------------------------------------------------------

function [ax, centers, radii, options] = parseInputs(varargin)

narginchk(2, 11);

needNewAxes = 0;

first_string = min(find(cellfun(@ischar, varargin), 1, 'first'));
if isempty(first_string)
    first_string = length(varargin) + 1;
end

if first_string == 3
    % viscircles(centers, radii)    
    needNewAxes = 1;   
    centers = varargin{1};
    radii = varargin{2};
    
elseif first_string == 4
    % viscircles(ax, centers, radii)
    ax = varargin{1};
    ax = validateAxes(ax);
    
    centers = varargin{2};
    radii = varargin{3};
    
else
    error(message('images:validate:invalidSyntax'))
end

% Handle remaining name-value pair parsing
name_value_pairs = varargin(first_string:end);

num_pairs = numel(name_value_pairs);
if (rem(num_pairs, 2) ~= 0)
    error(message('images:validate:missingParameterValue'));
end

% Do not change the order of argument names listed below
args_names = {'Color','LineWidth','LineStyle','EnhanceVisibility'};
arg_default_values = {'red', 2, '-', true};

% Set default parameter values
for i = 1: numel(args_names)
    options.(args_names{i}) = arg_default_values{i};
end

% Support for older arguments - do not change the order of argument names listed below
args_names = cat(2,args_names, {'EdgeColor', 'DrawBackgroundCircle'});

for i = 1:2:num_pairs
    arg = name_value_pairs{i};
    if ischar(arg)        
        idx = find(strncmpi(arg, args_names, numel(arg)));
        if isempty(idx)
            error(message('images:validate:unknownInputString', arg))
        elseif numel(idx) > 1
            error(message('images:validate:ambiguousInputString', arg))
        elseif numel(idx) == 1
            if(idx == 5) % If 'EdgeColor' is specified
                idx = 1; % Map to 'Color' 
            elseif(idx == 6) % If 'DrawBackgroundCircle' is specified
                idx = 4; % Map to 'EnhanceVisibility'
            end
            options.(args_names{idx}) = name_value_pairs{i+1};
        end    
    else
        error(message('images:validate:mustBeString')); 
    end
end

% Validate parameter values. Let LINE do the validation for EdgeColor,
% LineStyle and LineWidth.
[centers, radii] = validateCentersAndRadii(centers, radii, first_string); 
options.EnhanceVisibility = validateEnhanceVisibility( ...
    options.EnhanceVisibility);

% If required, create new axes after parsing
if(needNewAxes)    
    ax = gca;
end

end

% -------------------------------------------------------------------------

function preserveHold(wasHoldOn)
% Function for preserving hold behavior on exit
if ~wasHoldOn
    hold off
end

end

function ax = validateAxes(ax)

if ~ishghandle(ax)
    error(message('images:validate:invalidAxes','AX'))
end

objType = get(ax,'type');
if ~strcmp(objType,'axes')
    error(message('images:validate:invalidAxes','AX'))
end

end

function [centers, radii] = validateCentersAndRadii(centers, radii, ...
                                                    first_string)

if(~isempty(centers))
    validateattributes(centers,{'numeric'},{'nonsparse','real', ...
        'ncols',2}, mfilename,'centers',first_string-2);
    validateattributes(radii,{'numeric'},{'nonsparse','real','nonnegative', ...
        'vector'}, mfilename,'radii',first_string-1);
    
    if(size(centers,1) ~= length(radii))
        error(message('images:validate:unequalNumberOfRows','CENTERS','RADII'))
    end
    
    centers = double(centers);
    radii   = double(radii(:)); % Convert to a column vector
end

end

function doEnhanceVisibility = validateEnhanceVisibility(doEnhanceVisibility)

if ~(islogical(doEnhanceVisibility) || isnumeric(doEnhanceVisibility)) ...
        || ~isscalar(doEnhanceVisibility)
    error(message('images:validate:invalidLogicalParam', ...
        'EnhanceVisibility', 'VISCIRCLES', 'EnhanceVisibility'))
end

doEnhanceVisibility = logical(doEnhanceVisibility);

end



