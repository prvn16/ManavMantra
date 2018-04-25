function h = saveobj(s)
% LOADOBJ Overload load command

%   Copyright 2006 The MathWorks, Inc.

if ~isempty(s.Storage_)
    s.Data_ = [];
end
h = s;
  