function removeChild(this, child)
% REMOVECHILD removes a child from the tree hierarchy

%   Copyright 2012 MathWorks, Inc.

unpopulate(child);
disconnect(child);
children = this.Children;
for i = 1:numel(children)
    if isequal(children(i),child)
        children(i) = [];
        break;
    end
end
delete(child);
this.children = children;

% [EOF]
