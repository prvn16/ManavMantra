function bfitdatastatcleanup(fighandle)
% BFITDATASTATCLEANUP clean up anything needed for the Data Statistics GUI.

%   Copyright 1984-2010 The MathWorks, Inc.

if ishghandle(fighandle) % if figure still open or in the process of being deleted
    if ~isempty(bfitFindProp(fighandle,'Data_Stats_GUI_Object'))
        set(handle(fighandle), 'Data_Stats_GUI_Object',[]);
    end
end
% reset normalized?

