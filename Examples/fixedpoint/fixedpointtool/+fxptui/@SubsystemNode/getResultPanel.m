function resultPanel = getResultPanel(~)
% GETRESULTPANEL Gets the widgets for results

% Copyright 2013-2015 The MathWorks, Inc.

me = fxptui.getexplorer;

if(isempty(me))
    resultPanel = [];
    return;
end

resultPanel = [];

webbrowser.MinimumSize = [200 500];
webbrowser.Type = 'webbrowser';

% create the nonced url - g1152652
webbrowser.Url = fxptui.Web.CreateNoncedURL(me.ResultInfoController.getApplicationURL);

webbrowser.WebKit = true;
%webbrowser.EnableInspectorOnLoad = true;
webbrowser.Tag = 'Result_Details_WebBrowser_Tag';
webbrowser.DisableContextMenu = true;

resultPanel.Type = 'panel';
resultPanel.Tag = 'Fixed_Point_Tool_Autoscale_Information_DockedDlg';
resultPanel.Items = {webbrowser};
resultPanel.LayoutGrid = [1 1];

end
% %-------------------------------------------------------------
%
