function A = updatemenu(A)
%AXISOBJ/UPDATEMENU Update menu for axisobj
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2011 The MathWorks, Inc.

HG = get(A,'MyHGHandle');

menu = get(A,'UIContextMenu');
movemenu = findall(menu,'Tag','ScribeAxisObjMoveResizeMenu');

checked = {'off' 'on'};
legendLabel = {getString(message('MATLAB:uistring:axisobj:ShowLegend2')), getString(message('MATLAB:uistring:axisobj:HideLegend'))};
lockLabel =  {getString(message('MATLAB:uistring:axisobj:UnlockAxesPos')), getString(message('MATLAB:uistring:axisobj:LockAxesPos'))};
set(movemenu,...
        'Checked','off',...
        'Label',lockLabel{get(A,'Draggable')+1})

% look for a legend on this axis
% any children?
legendmenu = findall(menu,'Tag','ScribeAxisObjShowLegendMenu');
if ~isempty(get(HG,'Children'))
   set(legendmenu,...
           'Enable',checked{0+1},...
           'Label',legendLabel{0+1});   
else
   set(legendmenu,...
           'Enable',checked{1+1},...
           'Label',legendLabel{islegendon(HG)+1});
end

   

