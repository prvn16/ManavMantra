function bfitsavefit(datahandle, fit)
% BFITSAVEFIT Save a fit, as a struct, and the norm of resids to the workspace. 
%
%   BFITSAVEFIT(DATAHANDLE, FIT) saves the coefficients and type of FIT for data 
%   DATAHANDLE 

%   Copyright 1984-2011 The MathWorks, Inc.

coeff = getappdata(double(datahandle),'Basic_Fit_Coeff');
bfresids = getappdata(double(datahandle),'Basic_Fit_Resids');
resids = bfresids{fit+1};

% ignore NaNs when calculating norm of resids
normvalue = norm(resids(~isnan(resids)));
fitvalue.type = fittype(fit);
fitvalue.coeff = coeff{fit+1};

checkLabels = {getString(message('MATLAB:graph2d:bfit:MsgSaveSaveFitAsStruct')), ...
               getString(message('MATLAB:graph2d:bfit:MsgSaveNormOfResiduals')), ...
               getString(message('MATLAB:graph2d:bfit:MsgSaveResiduals'))};
defaultNames = {'fit','normresid','resids'};
items = {fitvalue, normvalue, resids};
export2wsdlg(checkLabels, defaultNames, items, getString(message('MATLAB:graph2d:bfit:MsgSaveFitToWorkspace')));

%------------------------------------------------------
function s = fittype(fit)
% FITTYPE Create fit type string.

switch fit
case 0
    s = 'spline';
case 1
    s = 'shape-preserving';
otherwise
    s = sprintf('polynomial degree %s',num2str(fit-1));
end
