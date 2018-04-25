function unpopulate(this)
%UNPOPULATE <short description>
%   OUT = UNPOPULATE(ARGS) <long description>

%   Copyright 2010-2012 The MathWorks, Inc.

children = this.Children;
for idx = 1:numel(children)
  child = children(idx);
  if ~isempty(child)
      disconnect(child);
      unpopulate(child);
  end
end

for i = 1:numel(this.Children)
    delete(this.Children(i));
end
    
this.Children = [];
% this root does not have block listeners
this.daobject = [];

% [EOF]
