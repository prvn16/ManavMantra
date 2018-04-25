function showProposeOptions(hdlg, htag, srcPanelTag)
% SHOWPROPOSEOPTIONS Controls the widgets to be shown for proposal options

% Copyright 2013 MathWorks, Inc.
%   this

    switch srcPanelTag
      case 'button_settings'
        switch htag
          case 'configure_button_settings'
            hdlg.setVisible('hide_button_settings',true);
            hdlg.setVisible('configure_button_settings',false);
            hdlg.setVisible('button_settings_group',true);
            
          case 'hide_button_settings'
            hdlg.setVisible('hide_button_settings',false);
            hdlg.setVisible('configure_button_settings',true);
            hdlg.setVisible('button_settings_group',false);
        end
        
      case 'run_settings'
        switch htag
          case 'configure_run_settings'
            hdlg.setVisible('hide_run_settings',true);
            hdlg.setVisible('configure_run_settings',false);
            hdlg.setVisible('run_settings_group',true);
            
          case 'hide_run_settings'
            hdlg.setVisible('hide_run_settings',false);
            hdlg.setVisible('configure_run_settings',true);
            hdlg.setVisible('run_settings_group',false);
        end
        
      case 'scl_settings'
        switch htag
          case 'configure_scl_settings'
            hdlg.setVisible('hide_scl_settings',true);
            hdlg.setVisible('configure_scl_settings',false);
            hdlg.setVisible('scl_settings_group',true);
            
          case 'hide_scl_settings'
            hdlg.setVisible('hide_scl_settings',false);
            hdlg.setVisible('configure_scl_settings',true);
            hdlg.setVisible('scl_settings_group',false);
        end
        
      case 'sys_pnl_vis'
        switch htag
          case 'sys_pnl_show_lnk'
            hdlg.setVisible('sys_pnl_hide_lnk',true);
            hdlg.setVisible('sys_pnl_show_lnk',false);
            hdlg.setVisible('sys_settings_grp',true);
            
          case 'sys_pnl_hide_lnk'
            hdlg.setVisible('sys_pnl_hide_lnk',false);
            hdlg.setVisible('sys_pnl_show_lnk',true);
            hdlg.setVisible('sys_settings_grp',false);
        end
    end
    hdlg.refresh;
end
