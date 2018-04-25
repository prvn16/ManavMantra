classdef GraphPlot< matlab.graphics.primitive.Data & matlab.graphics.mixin.Legendable & matlab.graphics.mixin.AxesParentable & matlab.graphics.mixin.Selectable & matlab.graphics.chart.interaction.DataAnnotatable & matlab.graphics.internal.Legacy & matlab.graphics.mixin.UIAxesParentable
% GraphPlot   Graph plot object
%
%   GraphPlot methods:
%      highlight      - Highlight nodes and edges
%      labelnode      - Add text labels to nodes
%      labeledge      - Add text labels to edges
%      layout         - Change layout of graph plot
%
%   GraphPlot properties:
%      EdgeColor      - Color of edge lines
%      EdgeCData      - Color data of edge lines
%      EdgeLabel      - Edge labels
%      EdgeLabelMode  - Selection mode for edge labels
%      LineStyle      - Edge line style
%      LineWidth      - Edge line width
%      EdgeAlpha      - Edge transparency
%      ArrowSize      - Arrow size
%      ShowArrows     - Turn display of arrows on or off
%      NodeColor      - Color of node markers
%      NodeCData      - Color data of node markers
%      NodeLabel      - Node labels
%      NodeLabelMode  - Selection mode for node labels
%      Marker         - Node marker symbol
%      MarkerSize     - Node marker size
%      XData          - X locations of the nodes
%      YData          - Y locations of the nodes
%      ZData          - Z locations of the nodes
%
%   See also graph, digraph

     
    %   Copyright 2015-2017 The MathWorks, Inc.    

    methods
        function out=GraphPlot
            % GraphPlot   Graph plot object
            %
            %   GraphPlot methods:
            %      highlight      - Highlight nodes and edges
            %      labelnode      - Add text labels to nodes
            %      labeledge      - Add text labels to edges
            %      layout         - Change layout of graph plot
            %
            %   GraphPlot properties:
            %      EdgeColor      - Color of edge lines
            %      EdgeCData      - Color data of edge lines
            %      EdgeLabel      - Edge labels
            %      EdgeLabelMode  - Selection mode for edge labels
            %      LineStyle      - Edge line style
            %      LineWidth      - Edge line width
            %      EdgeAlpha      - Edge transparency
            %      ArrowSize      - Arrow size
            %      ShowArrows     - Turn display of arrows on or off
            %      NodeColor      - Color of node markers
            %      NodeCData      - Color data of node markers
            %      NodeLabel      - Node labels
            %      NodeLabelMode  - Selection mode for node labels
            %      Marker         - Node marker symbol
            %      MarkerSize     - Node marker size
            %      XData          - X locations of the nodes
            %      YData          - Y locations of the nodes
            %      ZData          - Z locations of the nodes
            %
            %   See also graph, digraph
        end

    end
    methods (Abstract)
    end
    properties
        % ArrowSize - Arrow size
        %    Arrow size, specified as a positive value in point units.
        %    ArrowSize is only used for directed graphs, and has no effect
        %    on undirected graphs.
        %    Default value is 7 for graphs with 100 or fewer nodes, and 4 for 
        %    graphs with more than 100 nodes.
        ArrowSize;

        % EdgeAlpha - Edge transparency
        %    Scalar between 0 and 1 inclusive, which specifies the
        %    transparency of the edges. A value of 1 means fully opaque
        %    and 0 means completely transparent. Default value is 0.5.
        EdgeAlpha;

        % EdgeCData - Color data of edge lines
        %    Use a different color for each edge. EdgeCData is a numeric 
        %    vector with length equal to the number of edges.  Linearly map 
        %    the values in the vector to the colors in the current colormap.
        EdgeCData;

        % EdgeColor - Color of edge lines
        %    EdgeColor can be one of the following:
        %       'flat' - The edge line colors are determined by the value
        %                of the EdgeCData property.
        %       'none' - The edge lines are not displayed.
        %       RGB triplet or color string - The edge lines use
        %                the specified color.
        EdgeColor;

        % EdgeLabel - Edge labels
        %    Specifies the labels to be displayed along each edge. 
        %    EdgeLabel can be a cell array of strings or a numeric vector
        %    with length equal to the number of edges. By default,
        %    EdgeLabel is an empty cell array, indicating labels are not
        %    displayed.
        EdgeLabel;

        % EdgeLabelMode - Selection mode for edge labels
        %    Selection mode for edge labels, specified as one of these
        %    values:
        %      'auto' - Set EdgeLabel to edge weights if available, otherwise
        %               set to edge indices.
        %    'manual' - (default) Use manually specified labels. To specify the
        %               labels, set the EdgeLabel property.
        EdgeLabelMode;

        % LineStyle - Edge line style
        %    Specifies the style of the edge lines. Default is solid lines.        
        LineStyle;

        % LineWidth - Edge line width
        %    Positive scalar specifying the width of the edge lines. Default 
        %    value is 0.5.         
        LineWidth;

        % Marker - Node marker symbol
        %    Specifies the node marker symbol. Default is circle.         
        Marker;

        % MarkerSize - Node marker size
        %    Marker size, specified as a positive value in point units.
        %    Default value is 4 for graphs with 100 or fewer nodes, and 2 for 
        %    graphs with more than 100 nodes.
        MarkerSize;

        % NodeCData - Color data of node markers   
        %    Use a different color for each node marker. NodeCData is a numeric 
        %    vector with length equal to the number of nodes.  Linearly map 
        %    the values in the vector to the colors in the current colormap.
        NodeCData;

        % NodeColor - Color of node markers
        %    NodeColor can be one of the following:
        %       'flat' - The node marker colors are determined by the value
        %                of the NodeCData property.
        %       'none' - The node markers are not displayed.
        %       RGB triplet or color string - The node markers use
        %                the specified color.        
        NodeColor;

        % NodeLabel - Node labels
        %    Specifies the labels to be displayed next to the node markers. 
        %    NodeLabel can be a cell array of strings or a numeric vector
        %    with length equal to the number of nodes. For graphs with 100
        %    or fewer nodes, NodeLabel contains the node IDs or names (if
        %    present) of the graph nodes. Otherwise NodeLabel is an empty
        %    cell array, indicating that labels are not displayed.
        NodeLabel;

        % NodeLabelMode - Selection mode for node labels
        %    Selection mode for node labels, specified as one of these
        %    values:
        %      'auto' - (default) Set NodeLabel to node names if available, 
        %               otherwise set to node indices.
        %    'manual' - Use manually specified labels. To specify the
        %               labels, set the NodeLabel property.
        NodeLabelMode;

        % ShowArrows - Turn display of arrows on or off
        %    'on' or 'off', specifies whether arrows are displayed. 
        %    Default value is 'on' for directed graphs. For undirected
        %    graphs, ShowArrows is always 'off'.
        ShowArrows;

        % XData - X locations of the nodes
        %    Specified as a numeric vector with length equal to the number of
        %    nodes.
        XData;

        % YData - Y locations of the nodes
        %    Specified as a numeric vector with length equal to the number of
        %    nodes.
        YData;

        % ZData - Z locations of the nodes
        %    Specified as a numeric vector with length equal to the number of
        %    nodes.
        ZData;

    end
end
