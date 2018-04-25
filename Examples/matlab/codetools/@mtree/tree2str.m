function s = tree2str( S, varargin )
%TREE2STR  s = TREE2STR( obj, args )  Converts a tree into a string
%   By default, this function converts the subtree of every node
%   in obj to a string.  Two optional arguments may be supplied:
%      An amount to indent each line of the output.  Default is 0.
%      true if only subtrees should be done, false if full subtrees
%          should be done.  Default is true
%   As a special case, if a full tree obj is supplied as argument, 
%   it is treated as List(root(T))
%   A final argument may be a cell array consisting of pairs of
%   arguments.  The first member of each pair is an Mtree object
%   that specifies certain nodes in the tree.  The second member
%   of each pair is a string.  TREE2STR will replace the subtree
%   headed by each node in the first member of a pair by the
%   string when it generates output.

% Copyright 2006-2014 The MathWorks, Inc.

    % return if tree was in error
    if count(S)==0
        s = '';
        return;
    elseif count(S)==1 && iskind(S, 'ERR' )
         warning(message('MATLAB:mtree:tree2str:errtree', string( S )));
        s = '';
        return;
    end 
    if iswhole(S)
        S = List(root(S));
    end
    
    if nargin==2 && iscell( varargin{1} )
        s = tt2ss( S, 0, true, varargin{1} );
    else
        s = tt2ss( S, varargin{:} );
    end

end
