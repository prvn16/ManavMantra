function h = visboundaries(varargin)
%VISBOUNDARIES Plot region boundaries.
%   VISBOUNDARIES(BW) draws boundaries of regions in the binary image BW on
%   the current axes. BW is a 2D binary image where pixels that are logical
%   true belong to the foreground region and pixels that are logical false
%   constitute the background. VISBOUNDARIES uses BWBOUNDARIES to find the
%   boundary pixel locations in the image.
%
%   VISBOUNDARIES(B) draws region boundaries specified by B, where B is a
%   cell array containing the boundary pixel locations of the regions,
%   similar in structure to the first output from BWBOUNDARIES (see
%   function help for BWBOUNDARIES). Each cell contains a Q-by-2 matrix,
%   where Q is the number of boundary pixels for the corresponding region.
%   Each row of these Q-by-2 matrices contains the row and column
%   coordinates of a boundary pixel.
%
%   VISBOUNDARIES(AX, ___)  draws region boundaries on the axes specified
%   by AX.
%   
%   H = VISBOUNDARIES(___) returns a handle to an hggroup object for the
%   boundaries. The hggroup object, H, is the child of the axes object, AX.
%
%   H = VISBOUNDARIES(___,NAME,VALUE,...) passes the name-value pair
%   arguments to specify additional properties of the boundaries. Parameter
%   names can be abbreviated.
%
%   'Color'
%       <a href="matlab:doc('ColorSpec')">ColorSpec</a>
%       Specifies the color of the boundary. Default color is red.
%
%   'LineStyle'
%       {-} | -- | : | -. | none
%       Line style for the boundary. 
%       <a href="matlab:helpview(fullfile(docroot,'toolbox','images','images.map'),'viscircles_linespec')">Line Style Specifiers Table</a>
%
%   'LineWidth'
%       Size in points
%       Width of the boundary. Specify this value in points. 1 point = 1/72
%       inch. The default value is 2 points.
% 
%   'EnhanceVisibility'
%       Specifies whether or not to augment the drawn boundary with
%       contrasting features to improve visibility on a varying background.
%       Setting the value to true draws an augmented boundary and setting
%       it to false does not. Default value is true.
%             
%   Example 1
%   ---------
%   This example computes the boundaries of a binary images and plots it on
%   the image.
%
%    BW = imread('blobs.png');
%    B = bwboundaries(BW);
%    imshow(BW)
%    hold on
%    visboundaries(B)
%      
%   Example 2
%   ---------
%   This example shows how to visualize the result of segmentation of an
%   image using VISBOUNDARIES.
%
%    I = imread('toyobjects.png');
%    imshow(I)
%    hold on    
% 
%    % Segment the image using active contour
%    % First, specify initial contour location close to the object that is     
%    % to be segmented.    
%    mask = false(size(I));
%    mask(50:150,40:170) = true;
% 
%    % Display the initial contour on the original image in blue.
%    visboundaries(mask,'Color','b');
% 
%    % Segment the image using the 'edge' method and 200 iterations
%    bw = activecontour(I, mask, 200, 'edge');
%    
%    % Display the final contour on the original image in red.
%    visboundaries(bw,'Color','r');
%    title('Red - Initial Contour, Blue - Final Contour');
% 
% See also BWBOUNDARIES, BWPERIM, BWTRACEBOUNDARY, VISCIRCLES.

%   Copyright 2014-2017 The MathWorks, Inc.

narginchk(1, Inf);

varargin = matlab.images.internal.stringToChar(varargin);

[ax, boundaries, options] = parseInputs(varargin{:});

if isempty(boundaries)
    if nargout > 0
        h = gobjects(0); % Return handle only if requested.
    end
    return;
end

try
    numRegions = numel(boundaries);
    boundaries = [(boundaries(:))'; repmat({cast([NaN NaN],'like', ...
        boundaries{1})},1,length(boundaries))];
    boundaries = cell2mat(boundaries(:));
catch
    error(message('images:visboundaries:badFormatInCellArray','B','B'));
end

if (numel(boundaries) <= 2*numRegions) && (all(isnan(boundaries(:))))
    % Case when the cell array 'boundaries' contains only empty matrices
    % Leveraging short-circuit AND here. 
    if nargout > 0
        h = gobjects(0); % Return handle only if requested.
    end
    return;
end

x = boundaries(:,2);
y = boundaries(:,1);

% Create hggroup object that will contain the two circles as children
if isempty(ax)
    % No axes was specified as input
    ax = newplot;
end
hh = hggroup('Parent', ax);

% Draw the thinner foreground colored circle
thinCircHdl = line(x,y,'Parent',hh, ...
                   'Color', options.Color, ...
                   'LineWidth', options.LineWidth, ...
                   'LineStyle', options.LineStyle);

if options.EnhanceVisibility
    % Draw the thicker background white circle
        
    thickEdgeColor = 'w';    
    thickLineWidth = options.LineWidth + 1;
    if (strcmpi(options.LineStyle,'none'))
        thickLineStyle = 'none';
    else
        thickLineStyle = '-';
    end

    line(x,y,'Parent',hh, ...
        'Color', thickEdgeColor, ...
        'LineWidth', thickLineWidth, ...
        'LineStyle', thickLineStyle);

    % Bring the thin foreground circle on top
    uistack(thinCircHdl,'up');
    
end

if nargout > 0
    % Return handle only if requested.
    h = hh;
end

end

% -------------------------------------------------------------------------

function [ax, boundaries, options] = parseInputs(varargin)

first_string = min(find(cellfun(@ischar, varargin), 1, 'first'));
if isempty(first_string)
    first_string = length(varargin) + 1;
end

if first_string == 2
    % visboundaries(B), or visboundaries(BW) 
    ax = [];    
           
elseif first_string == 3
    % visboundaries(ax, B) or visboundaries(ax, BW)
    ax = varargin{1};
    ax = validateAxes(ax);
              
else
    error(message('images:validate:invalidSyntax'))
end

B = varargin{first_string-1}; 
boundaries = obtainAndValidateBoundaries(B,first_string);
    
% Handle remaining name-value pair parsing
name_value_pairs = varargin(first_string:end);

num_pairs = numel(name_value_pairs);
if (rem(num_pairs, 2) ~= 0)
    error(message('images:validate:missingParameterValue'));
end

args_names = {'Color', 'LineWidth','LineStyle','EnhanceVisibility'};
arg_default_values = {'red', 2, '-', true};

% Set default parameter values
for i = 1: numel(args_names)
    options.(args_names{i}) = arg_default_values{i};
end

for i = 1:2:num_pairs
    arg = name_value_pairs{i};
    if ischar(arg)        
        idx = find(strncmpi(arg, args_names, numel(arg)));
        if isempty(idx)
            error(message('images:validate:unknownInputString', arg))
        elseif numel(idx) > 1
            error(message('images:validate:ambiguousInputString', arg))
        elseif numel(idx) == 1            
            options.(args_names{idx}) = name_value_pairs{i+1};
        end    
    else
        error(message('images:validate:mustBeString')); 
    end
end

% Validate EnhanceVisbility value. Others will be validate by LINE.
validateattributes(options.EnhanceVisibility, {'numeric','logical'}, ...
    {'scalar','nonempty','nonsparse','real'}, mfilename,'EnhanceVisibility');

end


function boundaries = obtainAndValidateBoundaries(B, first_string)

if iscell(B)
    % B is the output of bwboundaries
    validateattributes(B,{'cell'},{'vector','nonsparse','real'}, ...
              mfilename,'B',first_string-1);
    boundaries = B;
    
else
    % Check if B is a numeric or logical matrix
    validateattributes(B, {'numeric','logical'}, {'2d','real','nonsparse'}, ...
              mfilename, 'BW', first_string-1);    
    boundaries = bwboundaries(B); % Handles any numeric type for B.
                
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

