function [ok, errmsg] = setPropertyValues(this, hdlg)
%SETPROPERTIES Set the Properties
%   OUT = SETPROPERTIES(ARGS) <long description>

%   Copyright 2015-2016 The MathWorks, Inc.

ok = true;
errmsg = '';
activeTab = hdlg.getActiveTab('shortcut_editor_tabs');
switch activeTab
    case 0
        bae = fxptui.BAExplorer.getBAExplorer;
        if isempty(bae); return; end
        rootModel = bae.getRoot.daobject.getFullName;
        
        if (this.isDominantSystemForSetting('MinMaxOverflowLogging'))
            try
                value = hdlg.getWidgetValue('cbo_log');
                this.setParameterValue('MinMaxOverflowLogging',value);
                if ~slfeature('FPTWeb')
                    mmoVal = this.getParameterValue('MinMaxOverflowLogging');
                    if ~strcmpi(get_param(rootModel,'SimulationMode'),'Normal') && (~strcmpi(mmoVal,'UseLocalSettings') && ~strcmpi(mmoVal,'ForceOff'))
                        BTN_TEST = this.PropertyBag.get('BTN_TEST');
                        BTN_CHANGE_SIM_MODE = fxptui.message('btnChangeSimModeAndContinue');
                        btn = fxptui.showdialog('instrumentationsimmodewarning', BTN_TEST);
                        switch btn
                            case BTN_CHANGE_SIM_MODE
                                set_param(rootModel,'SimulationMode','normal');
                            otherwise
                        end
                    end
                end
                
            catch e
                %if an invalid index is passed in don't set MinMaxOverflowLogging and
                %consume the error.
                ok = false;
                error = e;
            end
            
        end
        
        if (this.isDominantSystemForSetting('DataTypeOverride'))
            try
                value_dto = hdlg.getWidgetValue('cbo_dt');
                this.setParameterValue('DataTypeOverride', value_dto);
                
                value_dtoappliesto = hdlg.getWidgetValue('cbo_dt_appliesto');
                this.setParameterValue('DataTypeOverrideAppliesTo', value_dtoappliesto);
                
            catch e
                %if an invalid value is passed in don't set DataTypeOverride and
                %consume the error.
                ok = false;
                error = e;
            end
        end
        
        if ~ok
            fxptui.showdialog('defaulttypesettingMMODTO', error);
            ok = true;
        end
        me = fxptui.getexplorer;
        if ~isempty(me)
            me.getFPTRoot.fireHierarchyChanged;
        end
        bae.getRoot.firehierarchychanged;
        hdlg.refresh;
    case 1
        this.setProperties(hdlg);
end

% LocalWords:  btn instrumentationsimmodewarning defaulttypesetting MMODTO
