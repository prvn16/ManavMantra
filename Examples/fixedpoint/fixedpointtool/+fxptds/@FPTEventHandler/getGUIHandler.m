function guiHandler = getGUIHandler
%% GETGUIHANDLER method sets the guiHandler to appropriate GUIhandler 
% instance depending upon the 'FPTWeb' feature
% If on, JS GUI based handler is initialized
% If off, ME GUI based handler is intialized

%   Copyright 2016 The MathWorks, Inc.

   if slfeature('FPTWeb')
       guiHandler = fxptds.FPTWebHandler.getInstance();
   else
       guiHandler = fxptds.GUIHandler.getInstance();
   end
end