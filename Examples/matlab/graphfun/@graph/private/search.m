function [t, edgeindex] = search(isBFS, G, s, varargin)
%SEARCH Private utility function for BFSEARCH and DFSEARCH
%
%
%    See also DFSEARCH, BFSEARCH

%   Copyright 2014-2017 The MathWorks, Inc.

if isBFS
    internalFunc = @breadthFirstSearch;
    errStr = 'MATLAB:graphfun:bfsearch:';
else
    internalFunc = @depthFirstSearch;
    errStr = 'MATLAB:graphfun:dfsearch:';
end

searchLabels = {'discovernode', 'finishnode', ...
    'edgetonew', 'edgetodiscovered', 'edgetofinished', 'startnode'};

[labelVector, restart] = parseFlags(errStr, varargin{:});

formatTable = nnz(labelVector) ~= 1;

% Second output only supported when the only event selected is an edge event
if nargout > 1 && ~(nnz(labelVector([1 2 6])) == 0 && nnz(labelVector([3 4 5])) == 1)
    error(message([errStr 'SecondOutputEdgeOnly']));
end

src = validateNodeID(G, s);

if ~isscalar(src)
    error(message([errStr 'InvalidStartNode']));
end

t = internalFunc(G.Underlying, src, labelVector, restart, formatTable);

if formatTable
    if ischar(s) && hasNodeNames(G)
        nodeind = ~isnan(t(:, 2));
        
        nodes = cell(size(t, 1), 1);
        nodes(nodeind) = G.Nodes.Name(t(nodeind, 2));
        
        edges = cell(size(t, 1), 2);
        edges(~nodeind, :) = G.Nodes.Name(t(~nodeind, [3 4]));
    else
        nodes = t(:, 2);
        edges = t(:, [3 4]);
    end
    
    edgeindex = t(:, 5);
    
    t = table(categorical(t(:, 1), 1:6, searchLabels), nodes, edges, edgeindex, ...
        'VariableNames', {'Event', 'Node', 'Edge', 'EdgeIndex'});
    
else
    if nnz(labelVector([3 4 5])) == 1 % edge event
        edgeindex = t(:, 3);
        t(:, 3) = [];
    end
    if ischar(s) && hasNodeNames(G)
        t = G.Nodes.Name(t);
    end
end


function [labelVector, restart] = parseFlags(errStr, varargin)
% Possible syntaxes: bfsearch(G, s, 'Restart', RESTART)
%                    bfsearch(G, s, EVENTS, 'Restart', RESTART)
%                    bfsearch(G, s, EVENTS)

restart = false;
labelVector = [true, false(1, 5)];

if numel(varargin) == 0
    return;
end

% Check if first argument is 'Restart'
name = varargin{1};

if graph.isvalidoption(name) && graph.partialMatch(name, "Restart")
    setEvents = false;
else
    setEvents = true;
    events = name;
    varargin(1) = [];
end


if setEvents
    % Evaluate variable events and set labelVector accordingly
    
    if ischar(events)
        events = {events};
    elseif ~(iscellstr(events) || isstring(events)) || isempty(events)
        error(message([errStr 'InvalidEventType']));
    end
    searchLabelsExt = ["discovernode", "finishnode", "edgetonew", ...
        "edgetodiscovered", "edgetofinished", "startnode", "allevents"];
    
    labelVector = false(1, 7);
    for ii=1:numel(events)
        eventid = graph.partialMatch(events{ii}, searchLabelsExt);
        labelVector(eventid) = true;
        
        if sum(eventid) ~= 1
            error(message([errStr 'InvalidEvent'], events{ii}));
        end
    end
    
    if labelVector(end) == true
        labelVector(:) = true;
    end
    labelVector(end) = [];
end

if numel(varargin) > 0
    % Evaluate name-value pairs in varargin and set restart accordingly
    
    for ii=1:2:numel(varargin)
        name = varargin{ii};
        
        if graph.isvalidoption(name) && graph.partialMatch(name, "Restart")
            if ii+1 > numel(varargin)
                error(message([errStr 'KeyWithoutValue']));
            end
            value = varargin{ii+1};
            
            if isscalar(value)
                restart = logical(value);
            else
                error(message([errStr 'ParseRestart']));
            end
        else
            error(message([errStr 'ParseFlags']));
        end
    end
    
end
