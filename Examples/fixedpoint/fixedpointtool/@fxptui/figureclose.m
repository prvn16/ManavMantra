function figureclose(s,~,hfig)
%FIGURECLOSE   

%   Copyright 2006-2013 MathWorks, Inc.

if(~ishandle(hfig))
  delete(s);
  return;
end
set(hfig, 'Visible', 'off');
zoom(hfig, 'out');

% [EOF]
