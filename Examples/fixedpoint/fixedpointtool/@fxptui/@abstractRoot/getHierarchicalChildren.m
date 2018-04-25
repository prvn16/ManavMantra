function children = getHierarchicalChildren(h)
%GETHIERARCHICALCHILDREN returns tree nodes

%   Copyright 2006-2012 The MathWorks, Inc.

if(~isa(h, 'DAStudio.Object'))
  return;
end
children = [];
if(isempty(h.Children))
  return;
end

children = h.Children(:);


% EOF
