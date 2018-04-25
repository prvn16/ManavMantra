function p = plot(varargin)
% PLOT  Plots a directed graph.
%
%   PLOT(G) plots the directed graph G.
%
%   PLOT(G,LINESPEC) plots the directed graph G using the color, marker
%   and line style specified by the character string LINESPEC. For example,
%   use 'ro--' to plot red circles as nodes and red dashed lines as edges.
%
%   PLOT(G,...,'Layout',L) plots the graph G using the layout method
%   specified by the string L, which must be one of the following:
%       'auto'      (Default) Automatic choice of layout method based on
%                   the structure of the graph.
%       'circle'    Circular layout.
%       'force'     Force-directed layout. Uses attractive and repulsive
%                   forces on nodes.
%       'layered'   Layered layout. Places nodes in a set of layers.
%       'subspace'  Subspace embedding layout. Uses projection onto an
%                   embedded subspace.
%       'force3'    3-D force-directed layout.
%       'subspace3' 3-D Subspace embedding layout.
%
%   PLOT(G,...,'XData',X,'YData',Y) plots the graph G by placing nodes at
%   the coordinates specified by the vectors X and Y of length NUMNODES(G).
%
%   PLOT(G,...,'XData',X,'YData',Y,'ZData',Z) plots the graph G in 3-D, by
%   placing nodes at the coordinates specified by the vectors X, Y and Z of
%   length NUMNODES(G).
%
%   PLOT(AX,...) plots into the axes with handle AX.
%
%   H = plot(...) also returns a GraphPlot object. Use the methods and
%   properties of this object to inspect and adjust the plotted graph.
%
%   The previous syntaxes can also contain one or more Name-Value pair
%   arguments that specify additional properties of the GraphPlot object.
%
%   Example:
%       % Construct and plot a directed graph.
%       G = digraph([1 3 2 2 4 5 1 2],[2 2 4 5 6 6 6 6])
%       plot(G)
%
%   Example:
%       % Construct and plot a digraph. Use Name-Value pair arguments to
%       % set the color of the nodes and edges.
%       G = digraph([1 3 2 2 4 5 1 2],[2 2 4 5 6 6 6 6])
%       plot(G,'NodeColor','red','EdgeColor',[0 0.5 0])
%
%   Example:
%       % Construct and plot a digraph. Return the GraphPlot object H.
%       % Adjust the plotted digraph by changing different properties of H.
%       G = digraph([1 3 2 2 4 5 1 2],[2 2 4 5 6 6 6 6])
%       H = plot(G)
%       H.NodeColor = 'red'
%       H.EdgeColor = [0 0.5 0]
%
%   See also DIGRAPH, matlab.graphics.chart.primitive.GraphPlot

%   Copyright 2015-2017 The MathWorks, Inc.

% Parse plot(G,Name,Value) or plot(AX,G,Name,Value)
[cax,args] = axescheck(varargin{:});
nameOffset = 1 + ~isempty(cax); % used in error messages
G = args{1};
validateattributes(G,{'digraph'},{},nameOffset);
args = args(2:end); % discard AX and G

% Parse plot(G,LINESPEC,...) or plot(AX,G,LINESPEC,...)
if ~isempty(args)
    [l,c,m,tmsg] = colstyle(args{1});
    if isempty(tmsg)
        args = args(2:end); % discard LINESPEC
        nameOffset = nameOffset + 1 + numel(args);
        if ~isempty(l)
            args = [{'LineStyle',l},args];
        end
        if ~isempty(c)
            args = [{'NodeColor',c,'EdgeColor',c},args];
        end
        if ~isempty(m)
            args = [{'Marker',m},args];
        end
        nameOffset = nameOffset - numel(args);
    end
end
[args, is3D] = checkinputnames(args,nameOffset);

if isempty(cax) || ishghandle(cax,'axes')
    cax = newplot(cax);
    parent = cax;
else
    parent = cax;
    cax = ancestor(cax,'axes');
end

if ~isempty(cax) % if cax is empty, we'll error in the GraphPlot constructor...
    [~,nextColor,~] = specgraphhelper('nextstyle',cax,true,true,false);
    args = [{'AutoColor',nextColor},args];
end

% Grab node names if they exist
if hasNodeNames(G)
    args = [{'NodeNames', G.NodeProperties.Name}, args];
end
if hasEdgeWeights(G)
    args = [{'EdgeWeights', G.EdgeProperties.Weight}, args];
end

% Plot
hObj = matlab.graphics.chart.primitive.GraphPlot('BasicGraph', ...
        G.Underlying, 'Parent', parent, args{:});

% disable brushing, basic fit, and data statistics
hbrush = hggetbehavior(hObj,'brush');  
hbrush.Enable = false;
hbrush.Serialize = true;
hdatadescriptor = hggetbehavior(hObj,'DataDescriptor');
hdatadescriptor.Enable = false;
hdatadescriptor.Serialize = true;

if any(strcmp(cax.NextPlot, {'replaceall','replace'}))
    cax.Box = 'on';
end
if is3D && ~strcmp(cax.NextPlot,'add')
    view(cax,3);
end
if nargout > 0
    p = hObj;
end
end

%--------------------------------------------------------------------------
function [plotargin, is3D] = checkinputnames(plotargin,nameoffset)
% Checks input option names. All trailing inputs must be name-value pairs.
is3D = false;
if rem(length(plotargin),2) ~= 0
    error(message('MATLAB:graphfun:plot:ArgNameValueMismatch'));
end
names = [setdiff(properties('matlab.graphics.chart.primitive.GraphPlot'),...
        {'Children','Annotation','BeingDeleted','Type'}); ...
        {'Layout';'Dimension';'Iterations';'XStart';'YStart';'ZStart';...
        'Direction';'Sources';'Sinks';'AssignLayers';'WeightEffect';...
        'UseGravity';'Center'}];
for i = 1:2:numel(plotargin)
    plotargin{i} = validatestring(plotargin{i},names,nameoffset+i);
    if strcmp(plotargin{i}, 'ZData')
        is3D = true;
    elseif strcmp(plotargin{i}, 'Layout')
        is3D = strcmp(plotargin{i+1}, 'force3') || strcmp(plotargin{i+1}, 'subspace3');
    end
    if strcmp(plotargin{i}, 'Parent') && (~isscalar(plotargin{i+1}) || ~ishghandle(plotargin{i+1}))
       error(message('MATLAB:graphfun:plot:InvalidParent'));
    end
end
end
