function bfitreinitbfitdata(datahandle)
%BFITREINITBFITDATA is a utility function for the Basic Fitting GUI
%   BFITREINITBFITDATA is used to re initialize some Basic Fit appdata for
%   non-current lines. Other appdata is initialized in bfitlisten
%   See bfitsetup for more information.

%   Copyright 1984-2004 The MathWorks, Inc. 

emptycell = cell(12,1);
infarray = inf(1,12);
fitsShowing = false(1,12);
 
setappdata(double(datahandle),'Basic_Fit_Coeff', emptycell); % cell array of pp structures
setappdata(double(datahandle),'Basic_Fit_Handles', infarray); % array of handles of fits
setappdata(double(datahandle),'Basic_Fit_Showing', fitsShowing); % array of logicals: 1 if showing
setappdata(double(datahandle),'Basic_Fit_NumResults_',[]);
setappdata(double(datahandle),'Basic_Fit_EqnTxt_Handle', []);  
setappdata(double(datahandle),'Basic_Fit_ResidTxt_Handle', []); % norm of residuals txt
setappdata(double(datahandle),'Basic_Fit_Resid_Handles', infarray); % array of handles of residual plots
%keep the expression, delete the values;
evalresults = getappdata(double(datahandle),'Basic_Fit_EvalResults'); 
evalresults.x = []; % x values
evalresults.y = []; % f(x) values
evalresults.handle = [];
setappdata(double(datahandle),'Basic_Fit_EvalResults',evalresults);

    