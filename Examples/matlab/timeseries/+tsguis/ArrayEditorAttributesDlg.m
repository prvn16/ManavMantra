function ArrayEditorAttributesDlg(varName,attributesDlg)

% Copyright 2006-2017 The MathWorks, Inc.

%% Open the Attribute dialog from the Variable Editor
thisTs = evalin('base',sprintf('%s;',varName));
tsguis.attributesdlg(struct('Timeseries',thisTs,'VarName',varName),attributesDlg);