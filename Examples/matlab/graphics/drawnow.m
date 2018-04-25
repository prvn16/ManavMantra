% DRAWNOW Update figure windows and process callbacks
%     
% drawnow updates figures and processes any pending callbacks. Use this
% command if you modify graphics objects and want to see the updates on the
% screen immediately.
% 
% drawnow limitrate updates figures, but limits the number of updates to 20
% times per second (20 fps). If it has been less than 50 milliseconds since
% the last update, or if the graphics renderer is busy with the previous
% change, then the new updates are discarded. Use this command if you are
% updating graphics objects in a loop and do not need to see every update
% on the screen. Skipping updates can create faster animations. Pending 
% callbacks are processed, so you can interact with the figure during
% animations.
% 
% drawnow nocallbacks updates figures, but defers callbacks such as
% uicontrol clicks until the next full drawnow command. Use this option if
% you want to prevent callbacks from interrupting your code.
% 
% drawnow limitrate nocallbacks limits the number of updates, skips updates
% if the renderer is busy, and defers callbacks.
% 
% drawnow update skips updates if the renderer is busy and defers
% callbacks.
%   Note: This syntax is not recommended. Use the limitrate option
%         instead.
%
% drawnow expose updates figures, but defers callbacks.
%   Note: This syntax is not recommended. Use the nocallbacks option
%         instead.
%  
%    See also pause, refreshdata, waitfor

%   Copyright 1984-2014 The MathWorks, Inc.
%   Built-in function.
