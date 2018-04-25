function bfitsavedatastats(datahandle)
% BFITSAVEDATASTATS Save x and y data statistics to the workspace. 
%
%   BFITSAVEDATASTATS(DATAHANDLE) sends the x stats and y stats of
%   the current data DATAHANDLE to the export2wsdlg function 
%   along with appropriate names for the checkbox labels and default
%   variable names.

%   Copyright 1984-2004 The MathWorks, Inc.

xvalue = getappdata(double(datahandle),'Data_Stats_X');
yvalue = getappdata(double(datahandle),'Data_Stats_Y');

checkLabels = {getString(message('MATLAB:graph2d:bfit:DlgSaveXStats')), ...
               getString(message('MATLAB:graph2d:bfit:DlgSaveYStats'))};
items = {xvalue, yvalue};
varNames = {'xstats', 'ystats'};

export2wsdlg(checkLabels, varNames, items, getString(message('MATLAB:graph2d:bfit:DlgSaveStatisticsToWorkspace')));


