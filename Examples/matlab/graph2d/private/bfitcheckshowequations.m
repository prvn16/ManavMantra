function bfitcheckshowequations(showeqnon, datahandle, digits)
%BFITCHECKSHOWEQUATIONS Shows the equations for the fits 
%   BFITCHECKSHOWEQUATIONS(SHOW,DATAHANDLE,DIGITS) shows or removes the 
%   equations according to SHOW, with DIGITS giving the number of digits to show.

%   Copyright 1984-2012 The MathWorks, Inc.

axesH = ancestor(datahandle,'axes'); % need this in case subplots in figure
figH = ancestor(axesH,'figure');

bfitlistenoff(figH)

fitsshowing = find(getappdata(double(datahandle),'Basic_Fit_Showing'));

eqnTxtH = double(getappdata(double(datahandle),'Basic_Fit_EqnTxt_Handle'));
if ishghandle(eqnTxtH)
    delete(eqnTxtH);
end

if showeqnon
    eqnTxtH = bfitcreateeqntxt(digits,axesH,datahandle,fitsshowing);
    if ~isempty(eqnTxtH)
        appdata.type = 'eqntxt';
        appdata.index = [];
        setappdata(eqnTxtH,'bfit',appdata);
        setappdata(eqnTxtH, 'Basic_Fit_Copy_Flag', 1);
    end
else % delete
    eqnTxtH = [];
end
setgraphicappdata(double(datahandle),'Basic_Fit_EqnTxt_Handle',eqnTxtH);
guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
guistate.equations = showeqnon;
guistate.digits = digits;
setappdata(double(datahandle),'Basic_Fit_Gui_State', guistate);

bfitlistenon(figH)
