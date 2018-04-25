
%   Copyright 2014 The MathWorks, Inc.

function resultPanel = getResultDetailsDialog(~)

me = fxptui.getexplorer;

if(isempty(me))
    return;
end
%web(applicationURL,'-browser');

resultPanel = [];

webbrowser.MinimumSize = [200 500];
webbrowser.Type = 'webbrowser';
webbrowser.Url = me.ResultInfoController.ApplicationURL;
webbrowser.WebKit = true;
webbrowser.EnableInspectorOnLoad = true;
webbrowser.Tag = 'Result_Details_Tag';

% dlgstruct.DialogTitle = fxptui.message('resultreportResultDetails') ;
% dlgstruct.DialogTag = 'Fixed_Point_Tool_Autoscale_Information_DockedDlg';
% dlgstruct.StandaloneButtonSet  = {''};
% dlgstruct.CloseCallback  = 'set(getaction(fxptui.getexplorer,''VIEW_AUTOSCALEINFO''),''on'',''off'');';
% dlgstruct.LayoutGrid  = [1 1];
% dlgstruct.RowStretch = 1;
% dlgstruct.ColStretch = 1;
% 
% %             dlgstruct.IsScrollable = false;
% 
% dlgstruct.Items = {webbrowser};

 % make the variable persistent to improve performance.
    % persistent sim_setting_txt;
    % if isempty(sim_setting_txt)
    %     sim_setting_txt = fxptui.message('resultreportResultDetails') ;
    % end
    % resultPanel.Name = sim_setting_txt;
    resultPanel.Type = 'panel';
    resultPanel.Tag = 'Fixed_Point_Tool_Autoscale_Information_DockedDlg';
    resultPanel.Items = {webbrowser};
    resultPanel.LayoutGrid = [1 1];
    
end
