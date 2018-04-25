function b = isNotSupportedDTOMMO(this)
% ISNOTSUPPORTEDDTOMMO If this is a ModelReference, LinkedLibrary or a system under a linked library disable mmo and dto

% Copyright 2015 The MathWorks, Inc.

b = this.daobject.isModelReference || this.daobject.isLinked || this.TreeNode.isUnderLinkedLibrary;
end
