function unpopulate(this)
%UNPOPULATE <short description>
%   OUT = UNPOPULATE(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.

children = this.Children;
for idx = 1:numel(children)
  child = children{idx};
  if ~isempty(child)
      disconnect(child);
      unpopulate(child);
      delete(child);
  end
end
this.Children = [];
delete(this.BlkListeners);
this.BlkListeners = [];
this.daobject = [];

% [EOF]
