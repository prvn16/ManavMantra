% plot Alpha shape plot
%    plot(SHP) plots the alpha shape in a figure window.
%
%    H = plot(...) returns a handle to a patch.
%
%    plot(SHP, 'Name1',Value1, 'Name2',Value2, ...) allows name/value
%    pairs to be specified when creating the patch object.
%
%    Example: Compute the alpha shape of a set of 2D points
%             then plot illustrating various plot styles.
%      % Create a set of points (x,y)
%      th = (pi/12:pi/12:2*pi)';
%      x1 = [reshape(cos(th)*(1:5), numel(cos(th)*(1:5)),1); 0];
%      y1 = [reshape(sin(th)*(1:5), numel(sin(th)*(1:5)),1); 0];
%      x = [x1; x1+15;];
%      y = [y1; y1];
%      % Use alphaShape to create a polygon that envelops the points.
%      % An alpha value of 2 works well for this data set.
%      shp = alphaShape(x,y,2)
%      % Plot the alpha shape
%      h = plot(shp)
%      % Change the face color to yellow
%      set(h,'FaceColor','yellow')
%      % Turn off the triangulation edges
%      set(h,'EdgeColor','none')
%
%    See also alphaShape, patch

% Copyright 2013-2017 The MathWorks, Inc.
function hh = plot(varargin)
    if nargin > 0
        [varargin{:}] = convertStringsToChars(varargin{:});
    end
    [parent,varargin] = axescheck(varargin{:});
    shp = varargin{1};
    % Note: axes as first input does not work here, because this is a method of class alphaShape,
    % and axes is not declared as inferior to it. Only the syntax plot(shp, ..., 'Parent', ax) works.
    
    if isempty(parent) || ishghandle(parent,'axes')
        parent = newplot(parent);
        ax = parent;
    else
        ax = ancestor(parent,'axes');
    end
    
    % olivedrab = [hex2dec('6B')/255, hex2dec('8E')/255, hex2dec('23')/255];
    yellowgreen = [hex2dec('9A')/255, hex2dec('CD')/255, hex2dec('32')/255];
    if size(shp.Points,2) == 3
        [tri, P] = shp.boundaryFacets();
        hPatch = patch('Faces',tri, 'Vertices', P, 'FaceColor', yellowgreen, 'Parent', parent, varargin{2:end});      
        axis(ax, 'equal');
        if any(strcmp(ax.NextPlot, {'replaceall','replace'}))
            grid(ax,'on')
        end
        if ~strcmp(ax.NextPlot, 'add')
            view(ax,3)
        end
    else
        [tri, P] = shp.alphaTriangulation();           
        hPatch = patch('Faces',tri, 'Vertices', P, 'FaceColor', yellowgreen, 'Parent', parent, varargin{2:end}); 
        axis(ax, 'equal');
        if any(strcmp(ax.NextPlot, {'replaceall','replace'}))        
            box(ax,'on')
        end  
    end   
    if nargout==1
        hh = hPatch; 
    end
end
