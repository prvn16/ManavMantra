function a = mtfind( o, varargin )
%MTFIND a = MTFIND( obj, args )  sets a to the subset of obj nodes
%  that match all the patterns specified in args.  The patterns are
%  specified by pairs.  The first part of the pair begins with a
%  path, which may be empty, and then contains a test to be run on
%  the nodes that result from following that path.  The second
%  member of the pair gives the acceptable results of this test.
%  Only those nodes that pass all the tests are included in the
%  output a.  Tests that take a string argument may also take
%  a cell array of strings as argument -- the test passes if the
%  indicated string matches one of the strings in the cell array.
%      'Kind', str    passes if the node Kind is str
%      'Fun', str     passes if the node is a function named str
%      'Var', str     passes if the node is a variable named str
%      'SameID', x    passes if the node is the same variable as x
%      'IsVar', b     passes if the node being a variable matches b
%      'IsFun', b     passes if the node being a function matches b
%      'String', str  passes if the string value of the node is str
%      'Null', b      passes if the nullness of the node is b
%      'Member', x    passes if the node is in the set x
%      'Nonmember', x passes if the node is not in the set x

% Copyright 2006-2014 The MathWorks, Inc.

    na = nargin - 1;
    a = o;
    % chk(a);
    for i=1:2:na
        if( i+1 > na )
            error(message('MATLAB:mtree:find'));
        end
        a = restrict( a, varargin{i}, varargin{i+1} );
        % chk(a);
        if any( a.IX & ~o.IX )
            error(message('MATLAB:mtree:internal10'));
        end
    end
end
