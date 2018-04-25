function type = findType( tree )
%FINDTYPE given a a fileTree determines
%
%   Copyright 2009-2015 The MathWorks, Inc.


if isa(tree, 'char')
    tree = mtree(tree,'-file');
end

if ~isa(tree,'mtree')
    error(message('MATLAB:codetools:NotATree'));
end

if isnull(tree)
    type = internal.matlab.codetools.reports.matlabType.Script;
    return
end

treeRoot = root(tree);
% skip over comments at the beginning of a file.
while (iskind(treeRoot, 'COMMENT') ...
    || iskind(treeRoot, 'BLKCOM') ...
    || iskind(treeRoot, 'CELLMARK'))
    treeRoot = Next(treeRoot);
end

if iskind(treeRoot,'FUNCTION')
    type = internal.matlab.codetools.reports.matlabType.Function;
elseif iskind(treeRoot,'CLASSDEF')
    type = internal.matlab.codetools.reports.matlabType.Class;
elseif iskind(treeRoot, 'ERR')
    type = internal.matlab.codetools.reports.matlabType.Unknown;
else
    type = internal.matlab.codetools.reports.matlabType.Script;
end
end


