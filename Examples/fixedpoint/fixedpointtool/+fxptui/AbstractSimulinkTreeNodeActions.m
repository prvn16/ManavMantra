classdef AbstractSimulinkTreeNodeActions < fxptui.AbstractTreeNodeActions
%  ABSTRACTSIMULINKTREENODEACTIONS Defines the actions that are common to many simulink elements
    
% Copyright 2013-2016 The MathWorks, Inc.
    
    properties(GetAccess = protected, SetAccess = private)
        ActionMap;
    end
    
    methods
        function this = AbstractSimulinkTreeNodeActions(node)
            this@fxptui.AbstractTreeNodeActions(node)
            this.ActionMap = Simulink.sdi.Map(char('a'),?handle);
            this.createActionMap;
        end
        
        function delete(this)
            count = this.ActionMap.getCount;
            for i = 1:count
                key = this.ActionMap.getKeyByIndex(i);
                action = this.ActionMap.getDataByKey(key);
                delete(action);
            end
            this.ActionMap.Clear;
        end
    end
    
    methods (Abstract, Access = protected)
        actions = getSupportedActions(this);
        actions = getSignalLoggingActions(this);
    end
    
    methods (Access=private)
        function createActionMap(this)                                
            action = fxptds.Action('', ...
                                    fxptui.message('actionLOGALL'), ...
                                    'FPT_simulink_logall',...
                                    'fxptui.AbstractTreeNodeActions.selectAndInvoke(''logAllSignals'');', ...
                                    fxptui.message('menuEnableLogging'));
            this.ActionMap.insert('LOG_ALL', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('actionLOGNAMED'), ...
                                   'FPT_simulink_lognamed',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''logAllNamedSignals'');',...
                                   fxptui.message('menuEnableLogging'));
            this.ActionMap.insert('LOG_NAMED', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('actionLOGUNNAMED'), ...
                                   'FPT_simulink_logunnamed',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''logAllUnNamedSignals'');',...
                                   fxptui.message('menuEnableLogging'));
            this.ActionMap.insert('LOG_UNNAMED', action);
            
            action = fxptds.Action('',...
                                   fxptui.message('actionLOGALLSYS'), ...
                                   'FPT_simulink_logallsys',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''logAllSignalsInSystem'');',...
                                   fxptui.message('menuEnableLogging'));
            this.ActionMap.insert('LOG_ALL_SYS', action);
            
            action = fxptds.Action('',...
                                   fxptui.message('actionLOGNAMEDSYS'), ...
                                   'FPT_simulink_lognamedsys',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''logAllNamedSignalsInSystem'');',...
                                   fxptui.message('menuEnableLogging'));
            this.ActionMap.insert('LOG_NAMED_SYS', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('actionLOGUNNAMEDSYS'), ...
                                   'FPT_simulink_logunnamedsys',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''logAllUnNamedSignalsInSystem'');',...
                                   fxptui.message('menuEnableLogging'));
            this.ActionMap.insert('LOG_UNNAMED_SYS', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('actionLOGALL'), ...
                                   'FPT_simulink_lognone',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''logNoneSignals'');',...
                                   fxptui.message('menuDisableLogging'));
            this.ActionMap.insert('LOG_NONE', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('actionLOGNAMED'), ...
                                   'FPT_simulink_lognonenamed',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''logNoneNamedSignals'');',...
                                   fxptui.message('menuDisableLogging'));
            this.ActionMap.insert('LOG_NO_NAMED', action);

            action = fxptds.Action('', ...
                                   fxptui.message('actionLOGUNNAMED'), ...
                                   'FPT_simulink_lognoneunnamed',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''logNoneUnNamedSignals'');',...
                                   fxptui.message('menuDisableLogging'));
            this.ActionMap.insert('LOG_NO_UNNAMED', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('actionLOGALLSYS'), ...
                                   'FPT_simulink_lognonesys',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''logNoneSignalsInSystem'');',...
                                   fxptui.message('menuDisableLogging'));
            this.ActionMap.insert('LOG_NONE_SYS', action);

            action = fxptds.Action('', ...
                                   fxptui.message('actionLOGNAMEDSYS'), ...
                                   'FPT_simulink_lognonenamedsys',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''logNoneNamedSignalsInSystem'');',...
                                   fxptui.message('menuDisableLogging'));
            this.ActionMap.insert('LOG_NO_NAMED_SYS', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('actionLOGUNNAMEDSYS'), ...
                                   'FPT_simulink_lognoneunnamedsys',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''logNoneUnNamedSignalsInSystem'');',...
                                   fxptui.message('menuDisableLogging'));
            this.ActionMap.insert('LOG_NO_UNNAMED_SYS', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('actionLOGOUTPORTSYS'), ...
                                   'FPT_simulink_logoutport',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''logOutportsInSystem'');',...
                                   fxptui.message('menuEnableLogging'));
            this.ActionMap.insert('LOG_OUTPORT_SYS', action);

            action = fxptds.Action('', ...
                                   fxptui.message('actionLOGOUTPORTSYS'), ...
                                   'FPT_simulink_lognoneoutport',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''logNoneOutportsInSystem'');',...
                                   fxptui.message('menuDisableLogging'));
            this.ActionMap.insert('LOG_NO_OUTPORT_SYS', action);
            
            action = fxptds.Action('',...
                                   fxptui.message('actionHILITESYSTEM'),...
                                   'FPT_simulink_hilitesys',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''hiliteSystem'')');
            this.ActionMap.insert('HILITE_SYSTEM',action);
            
            action = fxptds.Action('',...
                fxptui.message('actionHILITECLEAR'),...
                'FPT_simulink_hiliteclear',...
                'fxptui.AbstractTreeNodeActions.selectAndInvoke(''unhiliteSystem'')');
            this.ActionMap.insert('HILITE_CLEAR',action);
            
            
            action = fxptds.Action('', ...
                                   fxptui.message('actionOPENBLOCKDIALOG'), ...
                                   'FPT_simulink_openblkdlg_tree',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''openDialog'')');
            this.ActionMap.insert('OPEN_SYSTEMDIALOG',action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('actionOPENSIGNALDIALOG'), ...
                                   'FPT_simulink_opensignaldlgsys_tree',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''openSignalDialog'')'); 
            this.ActionMap.insert('OPEN_SIGLOGDIALOG_SYS', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('labelUseLocalSettings'), ...
                                   'FPT_dto_uselocal',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeDTO'',''UseLocalSettings'');', ...
                                   fxptui.message('labelDataTypeOverride'));
            this.ActionMap.insert('DTO_USELOCAL', action);
            
            action = fxptds.Action('', ...
                                   sprintf('%s %s','->',fxptui.message('labelUseLocalSettings')), ...
                                   'FPT_dto_uselocal_current',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeDTO'',''UseLocalSettings'');', ...
                                   fxptui.message('labelDataTypeOverride'));
            this.ActionMap.insert('DTO_USELOCAL_CURRENT', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('labelScaledDoubles'), ...
                                   'FPT_dto_scaleddouble',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeDTO'',''ScaledDouble'');', ...
                                   fxptui.message('labelDataTypeOverride'));
            this.ActionMap.insert('DTO_SCALEDDOUBLE', action);
            
            action = fxptds.Action('', ...
                                   sprintf('%s %s %s','->',fxptui.message('labelScaledDoubles'),'(scl)'), ...
                                   'FPT_dto_scaleddouble_current',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeDTO'',''ScaledDouble'');', ...
                                   fxptui.message('labelDataTypeOverride'));
            this.ActionMap.insert('DTO_SCALEDDOUBLE_CURRENT', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('labelTrueDoubles'), ...
                                   'FPT_dto_double',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeDTO'',''Double'');', ...
                                   fxptui.message('labelDataTypeOverride'));
            this.ActionMap.insert('DTO_DOUBLE', action);
            
            action = fxptds.Action('', ...
                                   sprintf('%s %s %s','->',fxptui.message('labelTrueDoubles'),'(dbl)'), ...
                                   'FPT_dto_double_current',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeDTO'',''Double'');', ...
                                   fxptui.message('labelDataTypeOverride'));
            this.ActionMap.insert('DTO_DOUBLE_CURRENT', action);
            
            
            action = fxptds.Action('', ...
                                   fxptui.message('labelTrueSingles'), ...
                                   'FPT_dto_single',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeDTO'',''Single'');', ...
                                   fxptui.message('labelDataTypeOverride'));
            this.ActionMap.insert('DTO_SINGLE', action);
            
            action = fxptds.Action('', ...
                                   sprintf('%s %s %s','->',fxptui.message('labelTrueSingles'),'(sgl)'), ...
                                   'FPT_dto_single_current',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeDTO'',''Single'');', ...
                                   fxptui.message('labelDataTypeOverride'));
            this.ActionMap.insert('DTO_SINGLE_CURRENT', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('labelForceOff'), ...
                                   'FPT_dto_forceoff',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeDTO'',''Off'');', ...
                                   fxptui.message('labelDataTypeOverride'));
            this.ActionMap.insert('DTO_FORCEOFF', action);
            
            action = fxptds.Action('', ...
                                   sprintf('%s %s %s','->',fxptui.message('labelForceOff'), '(off)'),...
                                   'FPT_dto_forceoff_current',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeDTO'',''Off'');', ...
                                   fxptui.message('labelDataTypeOverride'));
            this.ActionMap.insert('DTO_FORCEOFF_CURRENT', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('labelDisabledDatatypeOverride'), ...
                                   'FPT_dto_disable',...
                                   '',...
                                   fxptui.message('labelDataTypeOverride'));
            this.ActionMap.insert('DTO_DISABLE', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('labelControlledBy',''), ...
                                   'FPT_dto_parentcontrol',...
                                   '',...
                                   fxptui.message('labelDataTypeOverride'));
            this.ActionMap.insert('DTO_PARENTCONTROL', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('labelAllNumericTypes'), ...
                                   'FPT_dtoappliesto_all',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeDTOAppliesTo'',''AllNumericTypes'');', ...
                                   fxptui.message('labelDataTypeOverrideAppliesTo'));
            this.ActionMap.insert('DTOAPPLIESTO_ALL', action);
            
            action = fxptds.Action('', ...
                                   sprintf('%s %s','->',fxptui.message('labelAllNumericTypes')), ...
                                   'FPT_dtoappliesto_all_current',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeDTOAppliesTo'',''AllNumericTypes'');', ...
                                   fxptui.message('labelDataTypeOverrideAppliesTo'));
            this.ActionMap.insert('DTOAPPLIESTO_ALL_CURRENT', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('labelFloatingPoint'), ...
                                   'FPT_dtoappliesto_float',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeDTOAppliesTo'',''Floating-point'');', ...
                                   fxptui.message('labelDataTypeOverrideAppliesTo'));
            this.ActionMap.insert('DTOAPPLIESTO_FLOAT', action);
            
            action = fxptds.Action('', ...
                                   sprintf('%s %s','->',fxptui.message('labelFloatingPoint')), ...
                                   'FPT_dtoappliesto_float_current',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeDTOAppliesTo'',''Floating-point'');', ...
                                   fxptui.message('labelDataTypeOverrideAppliesTo'));
            this.ActionMap.insert('DTOAPPLIESTO_FLOAT_CURRENT', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('labelFixedPoint'), ...
                                   'FPT_dtoappliesto_fixed',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeDTOAppliesTo'',''Fixed-point'');', ...
                                   fxptui.message('labelDataTypeOverrideAppliesTo'));
            this.ActionMap.insert('DTOAPPLIESTO_FIXED', action);
            
            action = fxptds.Action('', ...
                                   sprintf('%s %s','->',fxptui.message('labelFixedPoint')), ...
                                   'FPT_dtoappliesto_fixed_current',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeDTOAppliesTo'',''Fixed-point'');', ...
                                   fxptui.message('labelDataTypeOverrideAppliesTo'));
            this.ActionMap.insert('DTOAPPLIESTO_FIXED_CURRENT', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('labelUseLocalSettings'), ...
                                   'FPT_mmo_uselocal',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeMMO'',''UseLocalSettings'');', ...
                                   fxptui.message('labelLoggingMode'));
            this.ActionMap.insert('MMO_USELOCAL', action);
            
            action = fxptds.Action('', ...
                                   sprintf('%s %s','->',fxptui.message('labelUseLocalSettings')), ...
                                   'FPT_mmo_uselocal_current',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeMMO'',''UseLocalSettings'');', ...
                                   fxptui.message('labelLoggingMode'));
            this.ActionMap.insert('MMO_USELOCAL_CURRENT', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('labelMinimumsMaximumsAndOverflows'), ...
                                   'FPT_mmo_on',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeMMO'',''MinMaxAndOverflow'');', ...
                                   fxptui.message('labelLoggingMode'));
            this.ActionMap.insert('MMO_ON', action);
            
            action = fxptds.Action('', ...
                                   sprintf('%s %s %s','->',fxptui.message('labelMinimumsMaximumsAndOverflows'),'(mmo)'), ...
                                   'FPT_mmo_on_current',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeMMO'',''MinMaxAndOverflow'');', ...
                                   fxptui.message('labelLoggingMode'));
            this.ActionMap.insert('MMO_ON_CURRENT', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('labelOverflowsOnly'), ...
                                   'FPT_mmo_ovf',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeMMO'',''OverflowOnly'');', ...
                                   fxptui.message('labelLoggingMode'));
            this.ActionMap.insert('MMO_OVERFLOW', action);
            
            action = fxptds.Action('', ...
                                   sprintf('%s %s %s','->',fxptui.message('labelOverflowsOnly'),'(o)'), ...
                                   'FPT_mmo_ovf_current',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeMMO'',''OverflowOnly'');', ...
                                   fxptui.message('labelLoggingMode'));
            this.ActionMap.insert('MMO_OVERFLOW_CURRENT', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('labelMMOForceOff'), ...
                                   'FPT_mmo_forceoff',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeMMO'',''ForceOff'');', ...
                                   fxptui.message('labelLoggingMode'));
            this.ActionMap.insert('MMO_FORCEOFF', action);
            
             action = fxptds.Action('', ...
                                   sprintf('%s %s %s','->',fxptui.message('labelMMOForceOff'),'(off)'), ...
                                   'FPT_mmo_forceoff_current',...
                                   'fxptui.AbstractTreeNodeActions.selectAndInvoke(''changeMMO'',''ForceOff'');', ...
                                   fxptui.message('labelLoggingMode'));
            this.ActionMap.insert('MMO_FORCEOFF_CURRENT', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('labelNoControl'), ...
                                   'FPT_mmo_disable',...
                                   '',...
                                   fxptui.message('labelLoggingMode'));
            this.ActionMap.insert('MMO_DISABLE', action);
            
            action = fxptds.Action('', ...
                                   fxptui.message('labelControlledBy',''), ...
                                   'FPT_mmo_parentcontrol',...
                                   '',...
                                   fxptui.message('labelLoggingMode'));
            this.ActionMap.insert('MMO_PARENTCONTROL', action);
            
            if fxptui.isMATLABFunctionBlockConversionEnabled()
                action = fxptds.Action(coder.internal.mlfb.gui.MlfbUtils.getCodeViewActionIcon(), ...
                                       coder.internal.mlfb.gui.message('actionOpenCodeView'), ...
                                       'FPT_tree_code_view', ...
                                       'coder.internal.mlfb.gui.fxptToolOpenCodeView;');
                this.ActionMap.insert('TREE_OPEN_CODE_VIEW', action);
            end
        end
        
        function EnableSignalLog(~)
            me =  fxptui.explorer;  
            if ~isempty(me) 
                me.getTopNode.enableSignalLog;
            end
        end
    end
    
    methods(Access=protected)
        function action = getAction(this, tag)
            action = [];
            if this.ActionMap.isKey(tag)
                action = this.ActionMap.getDataByKey(tag);
            end
        end
        
        function [dto_actions, dto_applies_actions] = getDTOActions(this)
            controllingSys  = this.TreeNode.getDominantSystem('DataTypeOverride');
            currDTOSetting = this.TreeNode.getParameterValue('DataTypeOverride');
            currDTOAppliesTo = this.TreeNode.getParameterValue('DataTypeOverrideAppliesTo');
            if this.TreeNode.isDominantSystem('DataTypeOverride')
                dto_actions(1) = this.getAction('DTO_USELOCAL');
                dto_actions(2) = this.getAction('DTO_SCALEDDOUBLE');
                dto_actions(3) = this.getAction('DTO_DOUBLE');
                dto_actions(4) = this.getAction('DTO_SINGLE');
                dto_actions(5) = this.getAction('DTO_FORCEOFF');
                dto_applies_actions(1) = this.getAction('DTOAPPLIESTO_ALL');
                dto_applies_actions(2) = this.getAction('DTOAPPLIESTO_FLOAT');
                dto_applies_actions(3) = this.getAction('DTOAPPLIESTO_FIXED');
                switch currDTOAppliesTo
                    case 'AllNumericTypes'
                        dto_applies_actions(1) = this.getAction('DTOAPPLIESTO_ALL_CURRENT');
                    case 'Floating-point'
                        dto_applies_actions(2) = this.getAction('DTOAPPLIESTO_FLOAT_CURRENT');
                    case 'Fixed-point'
                        dto_applies_actions(3) = this.getAction('DTOAPPLIESTO_FIXED_CURRENT');

                end
                switch currDTOSetting
                    case 'UseLocalSettings'
                        dto_applies_actions = []; % Not active in this mode
                        dto_actions(1) = this.getAction('DTO_USELOCAL_CURRENT');
                    case {'ScaledDoubles', 'ScaledDouble'}
                        dto_actions(2) = this.getAction('DTO_SCALEDDOUBLE_CURRENT');
                    case {'TrueDoubles', 'Double'}
                        dto_actions(3) = this.getAction('DTO_DOUBLE_CURRENT');
                    case {'TrueSingles', 'Single'}
                        dto_actions(4) = this.getAction('DTO_SINGLE_CURRENT');
                    case {'ForceOff', 'Off'}
                        dto_applies_actions = []; % Not active in this mode
                        dto_actions(5) = this.getAction('DTO_FORCEOFF_CURRENT');
                    otherwise
                end
            else
                dto_applies_actions = [];
                if isempty(controllingSys) || this.TreeNode.isNotSupportedDTOMMO
                    dto_actions = this.getAction('DTO_DISABLE');
                    dto_actions.disableAction;
                else
                    dto_actions = this.getAction('DTO_PARENTCONTROL');
                    dto_actions.disableAction;
                    sysName = fxptui.getPath(controllingSys.Name);
                    this.updateDTOMMOActionLabel('DTO_PARENTCONTROL',sysName);
                end
            end
        end
        
        function actions = getMMOActions(this)
            controllingSys  = this.TreeNode.getDominantSystem('MinMaxOverflowLogging');
            currSetting = this.TreeNode.getParameterValue('MinMaxOverflowLogging');
            if this.TreeNode.isDominantSystem('MinMaxOverflowLogging')
                actions(1) = this.getAction('MMO_USELOCAL');
                actions(2) = this.getAction('MMO_ON');
                actions(3) = this.getAction('MMO_OVERFLOW');
                actions(4) = this.getAction('MMO_FORCEOFF');
                switch currSetting
                    case 'UseLocalSettings'
                        actions(1) = this.getAction('MMO_USELOCAL_CURRENT');
                    case 'MinMaxAndOverflow'
                        actions(2) = this.getAction('MMO_ON_CURRENT');
                    case 'OverflowOnly'
                        actions(3) = this.getAction('MMO_OVERFLOW_CURRENT');
                    case 'ForceOff'
                        actions(4) = this.getAction('MMO_FORCEOFF_CURRENT');
                end
            else
                if isempty(controllingSys) || this.TreeNode.isNotSupportedDTOMMO
                    actions = this.getAction('MMO_DISABLE');
                    actions.disableAction;
                else
                    actions = this.getAction('MMO_PARENTCONTROL');
                    actions.disableAction;
                    sysName = fxptui.getPath(controllingSys.Name);
                    this.updateDTOMMOActionLabel('MMO_PARENTCONTROL',sysName);
                end
            end
            
        end
        
        function updateDTOMMOActionLabel(this, tag, dominantSys)
            action = this.getAction(tag);
            if ~isempty(action)
                action.Label = fxptui.message('labelControlledBy',dominantSys);
            end
        end
        
        function actions = getCodeViewActions(this)
            if fxptui.isMATLABFunctionBlockConversionEnabled() && coder.internal.mlfb.gui.fxptToolIsCodeViewEnabled('tree')
                actions = this.getAction('TREE_OPEN_CODE_VIEW');
            else
                actions = [];
            end   
        end
        
        function logAllSignals(this)
            this.EnableSignalLog;
            this.TreeNode.setLogging('On', 'All', Inf);
        end
        
        function logAllNamedSignals(this)
            this.EnableSignalLog;
            this.TreeNode.setLogging('On', 'NAMED', Inf);
        end
        
        function logAllUnNamedSignals(this)
            this.EnableSignalLog;
            this.TreeNode.setLogging('On', 'UNNAMED', Inf);
        end
        
        function logAllSignalsInSystem(this)
            this.EnableSignalLog;
            this.TreeNode.setLogging('On', 'ALL', 1);
        end
        
        function logAllNamedSignalsInSystem(this)
            this.EnableSignalLog;
            this.TreeNode.setLogging('On', 'NAMED', 1);
        end
        
        function logAllUnNamedSignalsInSystem(this)
            this.TreeNode.setLogging('On', 'UNNAMED', 1);
        end
        
        function logNoneSignals(this)
            this.EnableSignalLog;
            this.TreeNode.setLogging('Off', 'All', Inf);
        end
        
        function logNoneNamedSignals(this)
            this.EnableSignalLog;
            this.TreeNode.setLogging('Off', 'NAMED', Inf);
        end
        
        function logNoneUnNamedSignals(this)
            this.EnableSignalLog;
            this.TreeNode.setLogging('Off', 'UNNAMED', Inf);
        end
        
        function logNoneSignalsInSystem(this)
            this.EnableSignalLog;
            this.TreeNode.setLogging('Off', 'ALL', 1);
        end
        
        function logNoneNamedSignalsInSystem(this)
            this.EnableSignalLog;
            this.TreeNode.setLogging('Off', 'NAMED', 1);
        end
        
        function logNoneUnNamedSignalsInSystem(this)
            this.EnableSignalLog;
            this.TreeNode.setLogging('Off', 'UNNAMED', 1);
        end
        
        function logOutportsInSystem(this)
            this.EnableSignalLog;
            this.TreeNode.setLogging('On', 'OUTPORT', 1);
        end
        
        function logNoneOutportsInSystem(this)
            this.EnableSignalLog;
            this.TreeNode.setLogging('Off', 'OUTPORT', 1);
        end
        
        function hiliteSystem(this)
            this.TreeNode.getUniqueIdentifier.hiliteInEditor;
        end
        
        function unhiliteSystem(this)
            this.TreeNode.getUniqueIdentifier.unhilite;
        end
            
        function openDialog(this)
            this.TreeNode.getUniqueIdentifier.openDialog;
        end
        
        function openSignalDialog(this)
            this.TreeNode.getUniqueIdentifier.openSignalPropertiesDialog;
        end
        
        function changeDTO(this, paramValue)
            try
                this.TreeNode.setParameterValue('DataTypeOverride',paramValue);
            catch error
                fxptui.showdialog('defaulttypesettingMMODTO', error);
            end
        end
        
        function changeDTOAppliesTo(this, paramValue)
            try
                this.TreeNode.setParameterValue('DataTypeOverrideAppliesTo',paramValue);
            catch error
                fxptui.showdialog('defaulttypesettingMMODTO', error);
            end
        end
        
        function changeMMO(this, paramValue)
            try
                this.TreeNode.setParameterValue('MinMaxOverflowLogging',paramValue);
                me = fxptui.getexplorer;
                if isempty(me); return; end
                rootModel = me.getFPTRoot.getDAObject.getFullName;
                mmoVal = this.TreeNode.getParameterValue('MinMaxOverflowLogging');
                if ~strcmpi(get_param(rootModel,'SimulationMode'),'Normal') && (~strcmpi(mmoVal,'UseLocalSettings') && ~strcmpi(mmoVal,'ForceOff'))
                    BTN_TEST = this.TreeNode.PropertyBag.get('BTN_TEST');
                    BTN_CHANGE_SIM_MODE = fxptui.message('btnChangeSimModeAndContinue');
                    btn = fxptui.showdialog('instrumentationsimmodewarning', BTN_TEST);
                    switch btn
                        case BTN_CHANGE_SIM_MODE
                            set_param(rootModel,'SimulationMode','normal');
                        otherwise
                    end
                end
            catch error
                fxptui.showdialog('defaulttypesettingMMODTO', error);
            end
            
        end
        
        function setSUD(this)
           me = fxptui.getexplorer;
           if isempty(me); return; end
           sysObj = this.TreeNode.getDAObject;
           me.isSUDVerified = me.setSystemForConversion(sysObj.getFullName, class(sysObj));
           me.updateWorkflowActions;
           dlg = me.getDialog;
           if isa(dlg, 'DAStudio.Dialog')
               dlg.refresh;
           end
        end
        
    end
end
