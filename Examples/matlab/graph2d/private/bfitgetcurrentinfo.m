function [axesCount,fitschecked,bfinfo, ...
        evalresultsstr,evalresultsxstr,evalresultsystr,currentfit,coeffresidstrings] = ...
    bfitgetcurrentinfo(datahandle)
% BFITGETCURRENTINFO

%   Copyright 1984-2014 The MathWorks, Inc.
%     


% connection between datahandle and figure might have been lost.
fighandle  = findobj(groot, 'Type', 'figure', '-function', @(x)any(double(getappdata(x, 'Basic_Fit_Data_Handles' )) == datahandle));  
axesCount = getappdata(fighandle,'Basic_Fit_Fits_Axes_Count');
fitschecked = getappdata(double(datahandle),'Basic_Fit_Showing');

evalresults = getappdata(double(datahandle),'Basic_Fit_EvalResults');
format = '%10.3g';
if isempty(evalresults)
    evalresultsstr = '';
    evalresultsxstr = '';
    evalresultsystr = '';
else
    evalresultsstr = evalresults.string;
    if isempty(evalresults.x)
        evalresultsxstr = '';
    else
        evalresultsxstr = cellstr(num2str(evalresults.x,format));
    end
    if isempty(evalresults.y)
        evalresultsystr = '';
    else
        evalresultsystr = cellstr(num2str(evalresults.y,format));
    end
end

currentfit = getappdata(double(datahandle),'Basic_Fit_NumResults_');

allcoeff = getappdata(double(datahandle),'Basic_Fit_Coeff');
allresids = getappdata(double(datahandle),'Basic_Fit_Resids');

if ~isempty(currentfit)
    resid = allresids{currentfit+1};
    % Ignore NaNs when calculating norm of resids
    coeffresidstrings = ...
      bfitcreateeqnstrings(datahandle,currentfit, ...
      allcoeff{currentfit+1},norm(resid(~isnan(resid))));
else
    coeffresidstrings = '';
end

guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
if isempty(guistate)
    bfinfo = [];
else
    guistatecell = struct2cell(guistate);
    bfinfo = [guistatecell{:}];
end