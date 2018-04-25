function T = newtree( o, varargin )
%NEWTREE  T = newtree(obj,varargin) make a tree out of a subtree
%  the arguments are the same as for TREE2STR

% Copyright 2006-2014 The MathWorks, Inc.

    if count(o) ~= 1
        error(message('MATLAB:mtree:newtree'));
    end
    % returns a new MTREE object based on subtree of the node o
    % for now, o must be a single node
    % TODO: add arguments to allow changes
    % for now, use tree2str to do this
    T = mtree( tree2str( o, 0, true, varargin{:} ) );
end
