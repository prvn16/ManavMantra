function b = isParentLinked(this)
% ISPARENTLINKED True if the parent of this subsystem is linked

% Copyright 2013 MathWorks, Inc.

    try
        parent = this.DAObject.getParent;
    catch e %#ok<NASGU>
        parent = [];
    end
    b = ~isempty(parent) && parent.isLinked;
end
