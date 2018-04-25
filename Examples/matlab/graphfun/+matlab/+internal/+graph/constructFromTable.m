function [G, EdgeProps, NodeProps] = constructFromTable(...
    underlyingCtor, msgFlag, ETable, varargin)
% CONSTRUCTFROMTABLE Construct graph/digraph from tables

% Copyright 2015-2016 The MathWorks, Inc.

if nargin > 5
    error(message('MATLAB:maxrhs'));
end
if ~strcmp(ETable.Properties.VariableNames{1}, 'EndNodes')
    error(message(['MATLAB:graphfun:' msgFlag ':InvalidTableFormat']));
end
EndNodes = ETable.EndNodes;
if ~ismatrix(EndNodes) || size(EndNodes,2) ~= 2 || ...
        ~(isnumeric(EndNodes) || iscellstr(EndNodes))
    error(message(['MATLAB:graphfun:' msgFlag ':InvalidTableSize']));
end
% Peel off back argument and check for 'OmitSelfLoops'
omitFlag = {};
if numel(varargin) > 0
    flag = varargin{end};
    if (ischar(flag) && isrow(flag)) || (isstring(flag) && isscalar(flag))
        omitLoops = startsWith("OmitSelfLoops", flag, 'IgnoreCase', true) && strlength(flag) > 0;
        if ~omitLoops
            error(message(['MATLAB:graphfun:' msgFlag ':InvalidFlag']));
        end
        varargin(end) = [];
        omitFlag = {flag};
    elseif nargin == 5
        error(message(['MATLAB:graphfun:' msgFlag ':InvalidFlag']));
    end
end
NTable = {};
if numel(varargin) > 0
    NTable = varargin(1);
    if ~istable(NTable{1})
        error(message(['MATLAB:graphfun:' msgFlag ':SecondNotTable']));
    end
end
[G, EdgeProps, NodeProps] = matlab.internal.graph.constructFromEdgeList(...
        underlyingCtor, msgFlag, ...
        EndNodes(:,1), EndNodes(:,2), ETable(:,2:end), NTable{:}, omitFlag{:});

