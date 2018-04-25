function bfitsaveresults(datahandle)
% BFITSAVERESULTS Save evaluated results of a fit to the workspace. 
%
%   BFITSAVERESULTS(DATAHANDLE)saves the x values evaluated of current fit of 
%   data DATAHANDLE to the base workspace.  

%   Copyright 1984-2012 The MathWorks, Inc.

evalresults = getappdata(double(datahandle),'Basic_Fit_EvalResults');
xvalue = evalresults.x;
yvalue = evalresults.y;

checkLabels = {getString(message('MATLAB:graph2d:bfit:SaveXinVariable')), ...
               getString(message('MATLAB:graph2d:bfit:SaveFofXinVariable'))};

defaultNames = {'x', 'fx'};
items = {xvalue, yvalue};

export2wsdlg(checkLabels, defaultNames, items, getString(message('MATLAB:graph2d:bfit:SaveResultsToWorkspace')));
