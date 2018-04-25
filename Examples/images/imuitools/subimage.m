function hout = subimage(varargin)
%SUBIMAGE Display multiple images in single figure.
%
%   SUBIMAGE is not recommended. Use IMSHOW instead.
%
%   You can use SUBIMAGE in conjunction with SUBPLOT to create
%   figures with multiple images, even if the images have
%   different colormaps. SUBIMAGE works by converting images to
%   truecolor for display purposes, thus avoiding colormap
%   conflicts.
%
%   SUBIMAGE(X,MAP) displays the indexed image X with colormap
%   MAP in the current axes.
%
%   SUBIMAGE(I) displays the intensity image I in the current
%   axes.
%
%   SUBIMAGE(BW) displays the binary image BW in the current
%   axes.
%
%   SUBIMAGE(RGB) displays the truecolor image RGB in the current
%   axes.
%
%   SUBIMAGE(x,y,...) displays an image with nondefault spatial
%   coordinates.
%
%   H = SUBIMAGE(...) returns a handle to the image object.
%
%   Class Support
%   -------------
%   The input image can be of class logical, uint8, uint16,
%   or double.
%
%   Example
%   -------
%       load trees
%       [X2,map2] = imread('forest.tif');
%       subplot(1,2,1), subimage(X,map)
%       subplot(1,2,2), subimage(X2,map2)
%
%   See also IMSHOW, SUBPLOT.

%   Copyright 1993-2016 The MathWorks, Inc.

[x,y,cdata] = parse_inputs(varargin{:});

ax  = newplot;
fig = ancestor(ax,'figure');

% Go change all the existing image and texture-mapped surface 
% objects to truecolor, using the colormaps embedded in their
% parent axis objects.
h = [findobj(fig,'Type','image') ; 
    findobj(fig,'Type','surface','FaceColor','texturemap')];

for k = 1:length(h)
    
    X = get(h(k),'CData');
    if ismatrix(X)
        
        ax   = ancestor(h(k),'axes');
        clim = get(ax,'CLim');
        cm   = colormap(ax);

        if strcmp(get(h(k), 'CDataMapping'), 'scaled')
            X = scaledind2ind(X,cm,clim);
        end

        if strcmp(get(h(k),'Type'),'image')
            set(h(k), 'CData', matlab.images.internal.ind2rgb8(X,cm));
        else
            set(h(k), 'CData', ind2rgb(X, cm));
        end

    end
end

h = image(x, y, cdata);
axis image;

if (nargout == 1)
    hout = h;
end

%--------------------------------------------------------
% Subfunction PARSE_INPUTS
%--------------------------------------------------------
function [x,y,cdata] = parse_inputs(varargin)

x = [];
y = [];

scaled = 0;
binary = 0;

switch nargin
case 0
    error(message('images:subimage:notEnoughInputs'))
    
case 1
    % subimage(I)
    % subimage(RGB)
    
    if ((ndims(varargin{1}) == 3) && (size(varargin{1},3) == 3))
        % subimage(RGB)
        cdata = varargin{1};
        
    else
        % subimage(I)
        binary = islogical(varargin{1});
        cdata = cat(3, varargin{1}, varargin{1}, varargin{1});

    end
    
case 2
    % subimage(I,[a b])
    % subimage(I,N)
    % subimage(X,map)
    
    if (numel(varargin{2}) == 1)
        % subimage(I,N)
        binary = islogical(varargin{1});
        cdata = cat(3, varargin{1}, varargin{1}, varargin{1});
        
    elseif (isequal(size(varargin{2}), [1 2]))
        % subimage(I,[a b])
        clim = varargin{2};
        if (clim(1) == clim(2))
            error(message('images:subimage:aEqualsB'))
            
        else
            cdata = cat(3, varargin{1}, varargin{1}, varargin{1});
        end
        scaled = 1;
        
    elseif (size(varargin{2},2) == 3)
        % subimage(X,map);
        cdata = matlab.images.internal.ind2rgb8(varargin{1},varargin{2});
        
    else
        error(message('images:subimage:invalidInputs'))
        
    end
        
case 3
    % subimage(x,y,I)
    % subimage(x,y,RGB)
    
    if ((ndims(varargin{3}) == 3) && (size(varargin{3},3) == 3))
        % subimage(x,y,RGB)
        x = varargin{1};
        y = varargin{2};
        cdata = varargin{3};
    
    else
        % subimage(x,y,I)
        x = varargin{1};
        y = varargin{2};
        binary = islogical(varargin{3});
        cdata = cat(3, varargin{3}, varargin{3}, varargin{3});
        
    end
    
case 4
    % subimage(x,y,I,[a b])
    % subimage(x,y,I,N)
    % subimage(x,y,X,map)
    
    if (numel(varargin{4}) == 1)
        % subimage(x,y,I,N)
        x = varargin{1};
        y = varargin{2};
        binary = islogical(varargin{3});
        cdata = cat(3, varargin{3}, varargin{3}, varargin{3});
        
    elseif (isequal(size(varargin{4}), [1 2]))
        % subimage(x,y,I,[a b])
        scaled = 1;
        clim = varargin{4};
        if (clim(1) == clim(2))
            error(message('images:subimage:aEqualsB'))
        else            
            x = varargin{1};
            y = varargin{2};
            cdata = cat(3, varargin{3}, varargin{3}, varargin{3});
        end
        
    elseif (size(varargin{4},2) == 3)
        % subimage(x,y,X,map);
        x = varargin{1};
        y = varargin{2};
        cdata = matlab.images.internal.ind2rgb8(varargin{3},varargin{4});
        
    else
        error(message('images:subimage:invalidInputs'))
        
    end
    
otherwise
    error(message('images:subimage:tooManyInputs'))
    
end

if (scaled)
    if (isa(cdata,'double'))
        cdata = (cdata - clim(1)) / (clim(2) - clim(1));
        cdata = min(max(cdata,0),1);
        
    elseif (isa(cdata,'uint8'))
        cdata = im2double(cdata);
        clim = clim / 255;
        cdata = (cdata - clim(1)) / (clim(2) - clim(1));
        cdata = im2uint8(cdata);
        
    elseif (isa(cdata,'uint16'))
        cdata = im2double(cdata);
        clim = clim / 65535;
        cdata = (cdata - clim(1)) / (clim(2) - clim(1));
        cdata = im2uint8(cdata);
        
    else
        error(message('images:subimage:invalidClass'))
        
    end
    
elseif (binary)
    cdata = uint8(cdata);
    cdata(cdata ~= 0) = 255;
end

if (isempty(x))
    x = [1 size(cdata,2)];
    y = [1 size(cdata,1)];
end

% Regardless of the input type, at this point in the code,
% cdata represents an RGB image; atomatically clip double RGB images 
% to [0 1] range
if isa(cdata, 'double')

   cdata(cdata > 1) = 1;
   cdata(cdata < 0) = 0;
end
