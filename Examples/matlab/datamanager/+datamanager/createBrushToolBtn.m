function createBrushToolBtn(toolbtn,~)

% Copyright 2011 The MathWorks, Inc.

% Add building splash screen menu. This function will be called once 
% by uitoolfactory in figuretools.
strBuilding = getString(message('MATLAB:datamanager:createBrushToolBtn:Building'));
uimenu('Label',strBuilding,'parent',toolbtn, 'HandleVisibility','off');
set(toolbtn,'CreateFcn','')