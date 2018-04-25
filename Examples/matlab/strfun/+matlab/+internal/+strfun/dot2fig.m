function dot2fig(graphText, title, nodeClickFcn)
    %DOT2FIG Plot dot graph in a Handle Graphics figure
    
    if nargin < 3
        nodeClickFcn = [];
        if nargin < 2
            title = '';
        end
    end
    
    inFilename = [tempname '.dot'];
    
    [fid, msg] = fopen(inFilename,'w');
    
    if fid < 0
        error(message('MATLAB:internal:dot2fig:fopen', msg));
    end
    
    fprintf(fid, '%s', graphText);
    
    fclose(fid);
    
    outFilename = regexprep(inFilename,'.dot$','_out.dot');

    callgraphviz('dot','-Tdot',inFilename,'-o',outFilename,'-v');
    
    graphText = fileread(outFilename);
    
    delete(outFilename)
    delete(inFilename)
    
    graphText = regexprep(graphText, '\\\n', '');

    nodes = regexp(graphText, '^\s*(?<name>\w+)\s+\[(?<attributes>.*)\];\s*$', 'names', 'lineanchors', 'dotexceptnewline');
    links = regexp(graphText, '^\s*(?<node1>\w+)\s*->\s*(?<node2>\w+)\s+\[(?<attributes>.*)\];\s*$', 'names', 'lineanchors', 'dotexceptnewline');
    
    graph = regexp(graphText, '^\s*graph\s*\[bb="(?<pos>[\d,]+)"\];\s*$', 'names', 'lineanchors');
    subgraph = regexp(graphText, '^\s*graph\s*\[label=(?<lq>")?(?<label>(?(lq)[^"]*|\w+))(?(lq)")\];\s*$', 'names', 'lineanchors');
    
    header = regexp(graphText, '^(?<type>\w+) (?<title>.*) {', 'dotexceptnewline', 'names');

    if isempty(header)
        figTitle = 'Dot Graph';
    else
        figTitle = header.title;
    end
    
    graphPos = str2num(graph(1).pos); %#ok<ST2NM>
    graphDim = graphPos(3:4);
    
    screenUnits = get(0, 'Units');
    set(0, 'Units', 'points');
    screenSizePoints = get(0, 'ScreenSize');
    set(0, 'Units', 'inches');
    screenSizeInches = get(0, 'ScreenSize');
    set(0, 'Units', screenUnits);

    pointsPerInch = screenSizePoints(3)/screenSizeInches(3);
    
    screenSize = get(0, 'ScreenSize');
    screenDim = screenSize(3:4);
        
    fig = figure('Name', figTitle);
    figDressingDiff = get(fig, 'OuterPosition')-get(fig, 'Position');
    figDressingDiff = figDressingDiff(3:4)-figDressingDiff(1:2);
    margin = 40;
    figDim = min(screenDim, graphDim+2*margin+figDressingDiff);
    set(fig, 'OuterPosition', [(screenDim-figDim)/2, figDim]);
    border = margin./graphDim;
    axLim = [-border; 1+border];
    ax = axes('Parent',fig, 'Units','normalized', 'Position', [0 0 1 1], 'XLim', axLim(:,1), 'YLim', axLim(:,2));
    set(ax,'XTick',[],'YTick',[],'Box','on');
    
    colorOrder = get(ax,'ColorOrder');

    if ~isempty(title)
        titlePos = [.5, 1+margin/2/graphDim(2)];
        text(titlePos(1), titlePos(2), title, ...
            'FontSize', 10, ...
            'HorizontalAlignment','center', ...
            'EdgeColor', 'black', ...
            'Margin', 5, ...
            'Interpreter', 'none', ...
            'Parent', ax);
    end
    
    for i = 1:length(subgraph)
        graphPos = str2num(graph(i+1).pos); %#ok<ST2NM>
        graphPos(3:4) = graphPos(3:4) - graphPos(1:2);
        rectangle('Position',graphPos./[graphDim, graphDim], ...
            'Curvature', [.05 .05], ...
            'LineStyle', ':', ...
            'Parent', ax);
        buffer = 5;
        text((graphPos(1)+buffer)/graphDim(1), (graphPos(2)+graphPos(4)-buffer)/graphDim(2), subgraph(i).label, ...
            'FontSize', 8, ...
            'VerticalAlignment','top', ...
            'Interpreter', 'none', ...
            'Parent', ax);
    end

    for link = links
        pv = makePV(link.attributes);
        if ~(isfield(pv, 'style') && strcmp(pv.style,'invis'))
            splineData = str2num(regexprep(pv.pos(3:end), '\s+', ';')); %#ok<ST2NM>
            if pv.pos(1) == 'e'
                splineData = circshift(splineData, [-1, 0]);
            else
                splineData = flipud(splineData);
            end
            if isfield(pv, 'color')
                color = getColorForIndex(colorOrder, str2double(pv.color));
            else
                color = 'black';
            end
            line(splineData(:,1)/graphDim(1), splineData(:,2)/graphDim(2), 'Color', color, 'Parent', ax);
            Xdiff = splineData(end-1,1)-splineData(end,1);
            Ydiff = splineData(end-1,2)-splineData(end,2);
            approachAngle = atan2(Ydiff,Xdiff);
            arrowAngle = .4;
            arrowLength = 12;
            arrowHeadAngle = approachAngle+[arrowAngle, -arrowAngle];
            xd = ([0 cos(arrowHeadAngle)]*arrowLength+splineData(end,1))/graphDim(1);
            yd = ([0 sin(arrowHeadAngle)]*arrowLength+splineData(end,2))/graphDim(2);
            patch(xd, yd, color, 'EdgeColor', color, 'Parent', ax);
            rectangle('Position', [(splineData(1,:)-2)./graphDim 4./graphDim], 'Curvature', [1 1], 'FaceColor', color, 'EdgeColor', color, 'Parent', ax);
            if isfield(pv, 'label')
                textPos = splineData(2,:)./graphDim;
                text(textPos(1), textPos(2), pv.label, 'BackgroundColor', 'white', 'EdgeColor', color, 'Interpreter', 'none', 'FontSize', 8, 'Parent', ax, 'HorizontalAlignment', 'center');
            end
        end
    end
    
    for node = nodes
        pv = makePV(node.attributes);
        if isfield(pv, 'pos') && ~(isfield(pv, 'style') && strcmp(pv.style,'invis'))
            centerPos = str2num(pv.pos); %#ok<ST2NM>
            nodePos = centerPos ./ graphDim;
            if isfield(pv, 'label')
                label = pv.label;
            else
                label = node.name;
            end
            nodeSize = floor([str2double(pv.width), str2double(pv.height)]*pointsPerInch);
            rectangle('Position',[(centerPos-nodeSize./2)./graphDim nodeSize./graphDim], ...
                'Curvature', [1 1], ...
                'FaceColor', 'white', ...
                'EdgeColor', 'black', ...
                'ButtonDownFcn', nodeClickFcn, ...
                'UserData', node.name, ...
                'Parent', ax);
            text(nodePos(1), nodePos(2), label, ...
                'FontSize', 8, ...
                'HorizontalAlignment','center', ...
                'Interpreter', 'none', ...
                'ButtonDownFcn', nodeClickFcn, ...
                'UserData', node.name, ...
                'Parent', ax);
        end
    end
end

function pv = makePV(attributeList)
    % TODO: handle escaped "s
    pv = regexp(attributeList, '(?<param>\w+)=(?<lq>")?(?<value>(?(lq)[^"]*|\w+))(?(lq)")', 'names');
    pv = {pv.param; pv.value};
    pv = struct(pv{:});
end

function color = getColorForIndex(colorOrder, index)
    index = mod(index-1, size(colorOrder,1))+1;
    color = colorOrder(index,:);
end