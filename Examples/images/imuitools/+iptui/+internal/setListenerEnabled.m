function setListenerEnabled(h,TF)
%setListenerEnabled  Enable a graphics listener in an appropriate way.

% Copyright 2013 The MathWorks, Inc.

for i = 1:numel(h)
    h(i).Enabled = TF;
end
