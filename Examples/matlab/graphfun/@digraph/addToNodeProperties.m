function [nodeProperties, newnodes] = addToNodeProperties(G, N, checkN)
%ADDTONODEPROPERTIES Private utility function for ADDNODE and ADDEDGE
%
%    See also ADDNODE, ADDEDGE

%   Copyright 2017 The MathWorks, Inc.

if nargin < 3
    checkN = true;
end

nodeProperties = G.NodeProperties;
if digraph.isvalidstring(N)
    if ~iscellstr(N), N = {N}; end
    newnodes = numel(N);
    if ~hasNodeNames(G)
        nodeProperties.Name = makeNodeNames(numnodes(G), 0);
    end
    if checkN
        N = digraph.validateName(N(:));
        if any(ismember(N, nodeProperties.Name))
            error(message('MATLAB:graphfun:digraph:NonUniqueNames'));
        end
    else
        N = N(:);
    end
    nodeProperties.Name(end+1:end+newnodes,1) = N;
elseif isnumeric(N) && isscalar(N)
    if ~isreal(N) || fix(N) ~= N || N < 0
        error(message('MATLAB:graphfun:addnode:InvalidNrNodes'));
    end
    if hasNodeNames(G)
        nodeProperties.Name(end+1:end+N,1) = makeNodeNames(N, numnodes(G));
    else
        if isempty(nodeProperties)
            nodeProperties = table.empty(numnodes(G)+N,0);
        else
            % Copy in the first row of Node Props to get expansion behavior
            % then delete it!
            nodeProperties(end+N+1,:) = nodeProperties(1,:);
            nodeProperties(end,:) = [];
        end
    end
    newnodes = N;
elseif istable(N)
    N = digraph.validateNodeProperties(N);
    if hasNodeNames(G) && any(strcmp(N.Properties.VariableNames, 'Name'))
        if any(ismember(N.Name, nodeProperties.Name))
            error(message('MATLAB:graphfun:digraph:NonUniqueNames'));
        end
    end
    nodeProperties = [nodeProperties; N];
    newnodes = size(N,1);
else
    error(message('MATLAB:graphfun:addnode:SecondInput'));
end

function C = makeNodeNames(numNodes, firstVal)
if numNodes > 0
    C = cellstr([repmat('Node', numNodes, 1) ...
        num2str(firstVal+(1:numNodes)', '%-d')]);
else
    C = cell(0,1);
end
