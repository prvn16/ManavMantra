function btn = showdialog(msgtype,varargin)
%SHOWDIALOG(DLGTYPE, MSGTYPE)

%   Copyright 2006-2018 The MathWorks, Inc.

btn = '';
%define constants
TYPE_ERROR = 'Error';
TYPE_WARNING = 'Warning';
TYPE_QUESTION = '';
BTN_YES = fxptui.message('labelYes');
BTN_NO = fxptui.message('labelNo');
select = fxptui.message('labelEnableSignalLogging');
title = '';

% some messages require model name
% feature On/Off behaviors are different
me = fxptui.getexplorer;
rootModel = [];
if ~isempty(me)
    rootModel = me.getTopNode.getHighestLevelParent;    
else
    fptInstance = fxptui.FixedPointTool.getExistingInstance;
    if ~isempty(fptInstance)
        rootModel = fptInstance.getModel;
    end
end
if ~isempty(rootModel)
    appData = SimulinkFixedPoint.getApplicationData(rootModel);
    hndl = get_param(rootModel, 'Object');
end

switch msgtype
    case 'resultNotFound'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('noResultFoundTitle');
        msg = varargin{:};
    case 'importDataSet'
        dlgtype = TYPE_ERROR;
        [title, ~] = fxptui.message('errorImportDataSetError');
        msg = varargin{:};
    case 'exportDataSet'
        dlgtype = TYPE_ERROR;
        [title, ~] = fxptui.message('errorExportDataSetError');
        msg = varargin{:};
    case 'histploterror'
        dlgtype = TYPE_ERROR;
        [title, ~] = fxptui.message('errorTitleHistPlotError');
        msg = fxptui.message('msgHistPlotError');
        
    case 'proposedtinvalid'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('warningTitleProposedDT');
        msg = fxptui.message('msgProposedDTinvalid', varargin{:});
        
    case 'proposedtinvalidML'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('warningTitleProposedDT');
        msg = fxptui.message('msgProposedDTinvalidML', varargin{:});
        
    case 'proposedtinvalidSL'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('warningTitleProposedDT');
        msg = fxptui.message('msgProposedDTinvalidSL', varargin{:});
        
    case 'defaulttypesetting'
        dlgtype = TYPE_ERROR;
        [title, ~] = fxptui.message('errorTitleDefaultDT');
        msg = fxptui.message('msgDefaultTypeSetting', varargin{1},varargin{2});
        
    case 'defaulttypesettingEvalFail'
        dlgtype = TYPE_ERROR;
        [title, ~] = fxptui.message('errorTitleDefaultDT');
        msg = fxptui.message('DTResolveError', varargin{1},varargin{2});
        
    case 'defaulttypesettingMMODTO'
        dlgtype = TYPE_ERROR;
        [title, ~] = fxptui.message('errorTitleDefaultDT');
        msg = '';
        
    case 'scaleproposefailed'
        dlgtype = TYPE_ERROR;
        if ~appData.AutoscalerProposalSettings.isWLSelectionPolicy
            [title, ~] = fxptui.message('errorTitleScaleProposeFailed');
            msg = fxptui.message('msgScaleProposeFailed');
        else
            [title, ~] = fxptui.message('errorTitleScaleProposeWLFailed');
            msg = fxptui.message('msgWLProposeFailed');
        end
        
    case 'scaleproposeattention'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('titleProposeFLNeedsAttention');
        msg = fxptui.message('msgProposeFLNeedsAttention');
        
    case 'scaleapplyattention'
        dlgtype = TYPE_QUESTION;
        if slfeature('FPTWeb')
            [title, ~] = fxptui.message('titleApplyDTNeedsAttention');
            msg = fxptui.message('msgApplyDTNeedsAttention');
        else
            if ~appData.AutoscalerProposalSettings.isWLSelectionPolicy
                [title, ~] = fxptui.message('titleApplyFLNeedsAttention');
                msg = fxptui.message('msgApplyFLNeedsAttention');
            else
                [title, ~] = fxptui.message('titleApplyWLNeedsAttention');
                msg = fxptui.message('msgApplyWLNeedsAttention');
            end
        end
        
        questionId = 'scaleApplyAttention';
        BTN_IGNORE_AND_APPLY = fxptui.message('btnIgnoreAlertAndApply');
        BTN_CANCEL = fxptui.message('btnCancel');
        btns = {BTN_IGNORE_AND_APPLY,BTN_CANCEL};
        btndefault = BTN_CANCEL;
        btnObj = struct('btnText',BTN_CANCEL,'btnId', 2,'cancelBtn',BTN_CANCEL);
        if nargin > 1
            BTN_TEST = varargin{1}; %#ok<*NASGU>
        end
        
    case 'scaleapplyfailed'
        dlgtype = TYPE_ERROR;
        [title, ~] = fxptui.message('errorTitleScaleApplyFailed');
        if isempty(varargin)
            arg = '';
        else
            arg = varargin{1};
        end
        msg = fxptui.message('msgScaleApplyFailed', arg);
        
    case 'noselection'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('errorTitleNoSelection');
        msg = fxptui.message('msgNoSelection');
        
    case 'noselectionscaleinfo'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('errorTitleNoSelection');
        msg = fxptui.message('msgNoSelectionScaleInfo');
        
    case 'noselectionhighlight'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('errorTitleNoSelection');
        msg = fxptui.message('msgNoSelectionHighlight');
        
    case 'noselectionhighlightdtgroup'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('errorTitleNoSelection');
        msg = fxptui.message('msgNoSelectionHighlightDTGroup');
        
    case 'notplottable'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('errorTitleNotPlottableSDI');
        msg = fxptui.message('msgNotPlottableSDI', select);
        
    case 'notplottablediff'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('errorTitleNotPlottableDiffSDI');
        msg = fxptui.message('msgNotPlottableDiffSDI');
        
    case 'notcomparablerun'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('errorTitleCannotCompareRunsSDI');
        msg = fxptui.message('msgNotComparableRunsSDI');
        
    case 'diffplotmissingchannel'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('errorTitleNotPlottableDiffSDI');
        msg = fxptui.message('msgNotPlottableChannelDiffSDI');
        
    case 'histnotplottable'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('errorTitleHistNotPlottable');
        msg = fxptui.message('msgHistNotPlottable');
        
    case 'notacceptchecked'
        dlgtype = TYPE_WARNING;
        if ~appData.AutoscalerProposalSettings.isWLSelectionPolicy
            [title, ~] = fxptui.message('warningTitleApplyFL');
            msg = fxptui.message('msgNotAcceptChecked');
        else
            [title, ~] = fxptui.message('warningTitleApplyWL');
            msg = fxptui.message('msgWLNotAcceptChecked');
        end
        
    case 'noproposedfl'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('warningTitleApplyFL');
        msg = fxptui.message('msgNoProposedFL');
        
    case 'noproposeddt'
        dlgtype = TYPE_WARNING;
        if ~appData.AutoscalerProposalSettings.isWLSelectionPolicy
            [title, ~] = fxptui.message('warningTitleApplyFL');
        else
            [title, ~] = fxptui.message('warningTitleApplyWL');
        end
        msg = fxptui.message('msgNoProposedFL');
        
    case 'scalingfixdt'
        dlgtype = TYPE_QUESTION;
        if ~appData.AutoscalerProposalSettings.isWLSelectionPolicy
            [title, ~] = fxptui.message('warningTitleProposeFL');
            msg = fxptui.message('msgScalingFixdt');
        else
            [title, ~] = fxptui.message('warningTitleProposeWL');
            msg = fxptui.message('msgScalingWLFixdt');
        end
        questionId = 'scalingFixDT';
        btns = {BTN_YES  BTN_NO};
        btndefault = BTN_NO;
        btnObj = struct('btnText', BTN_NO, 'btnId', 2,'cancelBtn', BTN_NO);
        
    case 'proposedtsharedwarning'
        dlgtype = TYPE_QUESTION;
        [title, ~] = fxptui.message('warningTitleProposedDT');
        msg = fxptui.message('msgProposedDTshared');
        questionId = 'proposedDTSharedWarning';
        BTN_CHANGE_ALL = fxptui.message('btnProposedDTsharedChangeAll');
        BTN_CANCEL = fxptui.message('btnProposedDTsharedCancel');
        btns = {BTN_CHANGE_ALL BTN_CANCEL};
        btnObj = struct('btnText', BTN_CHANGE_ALL, 'btnId', 1,'cancelBtn', BTN_CANCEL);
        btndefault = BTN_CHANGE_ALL;
        
    case 'ignoreproposalsandsimwarning'
        dlgtype = TYPE_QUESTION;
        [title, ~] = fxptui.message('warningTitleIgnoreProposedDTAndSim');
        runName = varargin{1};
        questionId = 'ignoreProposalsSimWarning';
        BTN_SIM = fxptui.message('btnIgnoreandSimulate');
        BTN_CANCEL = fxptui.message('btnCancel');
        btns = {BTN_SIM BTN_CANCEL};
        btndefault = BTN_SIM;
        btnObj = struct('btnText',BTN_SIM,'btnId', 1,'cancelBtn',BTN_CANCEL);
        msg = fxptui.message('msgIgnoreProposedDTAndSim', runName);
        
    case 'ignoreApplySimWarning'
        dlgtype = TYPE_QUESTION;
        [title, ~] = fxptui.message('warningTitleIgnoreProposedDTAndSim');
        isWLPolicy = varargin{1};
        questionId = 'ignoreApplySimWarning';
        BTN_SIM = fxptui.message('btnIgnoreandSimulate');
        BTN_CANCEL = fxptui.message('btnCancel');
        btns = {BTN_SIM BTN_CANCEL};
        btndefault = BTN_CANCEL;
        btnObj = struct('btnText',BTN_SIM,'btnId', 2,'cancelBtn',BTN_CANCEL);
        if ~isWLPolicy
            msg = fxptui.message('msgIgnoreAppliedDTAndSimWL');
        else
            msg = fxptui.message('msgIgnoreAppliedDTAndSimFL');
        end
        
    case 'simmodewarning'
        dlgtype = TYPE_QUESTION;
        [title, ~] = fxptui.message('simmodewarning');
        msg = fxptui.message('msgsimmodewarning');
        questionId = 'simModeWarning';
        BTN_CHANGE_SIM_MODE = fxptui.message('btnChangeSimModeAndContinue');
        BTN_NO = fxptui.message('labelNo');
        BTN_CANCEL = fxptui.message('btnCancel');
        btns = {BTN_CHANGE_SIM_MODE  BTN_NO BTN_CANCEL};
        btndefault = BTN_CHANGE_SIM_MODE;
        btnObj = struct('btnText',BTN_CHANGE_SIM_MODE,'btnId',1,'cancelBtn',BTN_CANCEL);
        
    case 'proposedtsimmodewarning'
        dlgtype = TYPE_QUESTION;
        if ~appData.AutoscalerProposalSettings.isWLSelectionPolicy
            [title, ~] = fxptui.message('proposedtsimmodewarning');
            msg = fxptui.message('msgproposedtsimmodewarning');
        else
            [title, ~] = fxptui.message('proposeWLsimmodewarning');
            msg = fxptui.message('msgproposeWLsimmodewarning');
        end
        
        questionId = 'proposedDTSimModeWarning';
        BTN_CHANGE_SIM_MODE = fxptui.message('btnChangeSimModeAndContinue');
        BTN_CANCEL = fxptui.message('btnCancel');
        btns = {BTN_CHANGE_SIM_MODE BTN_CANCEL};
        btndefault = BTN_CHANGE_SIM_MODE;
        btnObj = struct('btnText',BTN_CHANGE_SIM_MODE,'btnId',1,'cancelBtn',BTN_CANCEL);
        
    case 'instrumentationsimmodewarning'
        dlgtype = TYPE_QUESTION;
        [title, ~] = fxptui.message('instrumentationsimmodewarning');
        msg = fxptui.message('msginstrumentationsimmodewarning');
        questionId = 'instrumentationsSimModeWarning';
        BTN_CHANGE_SIM_MODE = fxptui.message('btnChangeSimModeAndContinue');
        BTN_NO = fxptui.message('labelNo');
        questionId = 'instrumentationSimModeWarning';
        btns = {BTN_CHANGE_SIM_MODE  BTN_NO};
        btndefault = BTN_CHANGE_SIM_MODE;
        btnObj = struct('btnText',BTN_CHANGE_SIM_MODE,'btnId',1,'cancelBtn',BTN_NO);
        
    case 'launchFPAwithMdlRef'
        dlgtype = TYPE_QUESTION;
        [title, ~] = fxptui.message('warningTitleLaunchFPAwithMdlRef');
        questionId = 'launchFPAWithMdlRef';
        msg = fxptui.message('msgLaunchFPAwithMdlRef');
        btns = {BTN_YES  BTN_NO};
        btndefault = BTN_NO;
        btnObj = struct('btnText',BTN_YES,'btnId',1,'cancelBtn',BTN_NO);
        
    case 'staticrangefailed'
        % report as TYPE_ERROR
        [title, ~] = fxptui.message('errorTitleDeriveFailed');
        [errMsg,msgID] = fxptui.message('msgDeriveFailed');
        % Create a cell array of exceptions that need to be displayed in the
        % diagnostic viewer.
        msg = fxptui.FPTMException(msgID,errMsg, hndl);
        if (nargin > 1) && isa(varargin{1},'MException')
            msg = msg.addCause(varargin{1});
        end
        fxptui.showDerivedDiagnosticInMV(msg,title,hndl);
        return;
        
    case 'compileddesignminmaxfailed'
        % report as TYPE_ERROR
        [title, ~] = fxptui.message('errorTitleCompiledDesignFailed');
        [errMsg,msgID] = fxptui.message('msgCompiledDesignFailed');
        % Create a cell array of exceptions that need to be displayed in the
        % diagnostic viewer.
        
        msg = fxptui.FPTMException(msgID,errMsg, hndl);
        if (nargin > 1) && isa(varargin{1},'MException')
            msg = msg.addCause(varargin{1});
        end
        fxptui.showDerivedDiagnosticInMV(msg,title,hndl);
        return;
        
    case 'deleteBAE'
        dlgtype = TYPE_QUESTION;
        [title, ~] = fxptui.message('questionTitleBatchAction');
        BAEName = varargin{1};
        msg = fxptui.message('msgDeleteBAE',BAEName);
        questionId = 'deleteBAEDialog';
        btns = {BTN_YES  BTN_NO};
        btndefault = BTN_YES;
        btnObj = struct('btnText',BTN_YES,'btnId',1,'cancelBtn',BTN_NO);
        
    case 'deleteFactoryBAE'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('warningTitleBatchAction');
        msg = fxptui.message('msgDeleteFactoryBAE');
        
    case 'norunselectionfordel'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('errorTitleNoRunSelection');
        msg = fxptui.message('msgNoRunSelectionForDel');
        
    case 'launchfpafailed'
        dlgtype = TYPE_ERROR;
        [title, ~] = fxptui.message('errorTitleLaunchFPAFailed');
        msg = fxptui.message('msgLaunchFPAFailed');
        
    case 'emptyshortcutname'
        dlgtype = TYPE_ERROR;
        [title, ~] = fxptui.message('warningTitleBatchAction');
        msg = fxptui.message('msgShortcutNameError');
        
    case 'nofixptlicensederived'
        dlgtype = TYPE_ERROR;
        [title, ~] = fxptui.message('errorTitleDeriveFailed');
        msg = fxptui.message('msgnoslfxptlicense');
        
    case 'nofixptlicensepropose'
        dlgtype = TYPE_ERROR;
        if ~appData.AutoscalerProposalSettings.isWLSelectionPolicy
            [title, ~] = fxptui.message('errorTitleScaleProposeFailed');
        else
            [title, ~] = fxptui.message('errorTitleScaleProposeWLFailed');
        end
        msg = fxptui.message('msgnoslfxptlicense');
        
    case 'nofixptlicenseapply'
        dlgtype = TYPE_ERROR;
        [title, ~] = fxptui.message('errorTitleScaleApplyFailed');
        msg = fxptui.message('msgnoslfxptlicense');
        
    case 'nonuniquerunname'
        dlgtype = TYPE_ERROR;
        [title, ~] = fxptui.message('errorTitleRunNameError');
        msg = fxptui.message('msgRunNameError');
        
    case 'nofixptlicensefpa'
        dlgtype = TYPE_ERROR;
        [title, ~] = fxptui.message('errorTitleLaunchFPAFailed');
        msg = fxptui.message('msgnoslfxptlicense');
        
    case 'genericerror'
        dlgtype = TYPE_ERROR;
        [title, ~] = fxptui.message('errorTitleFPTGeneralError');
        msg = fxptui.message('msgFPTGeneralError');
        
    case 'modelnotfound'
        dlgtype = TYPE_ERROR;
        [title, ~] = fxptui.message('errorTitleFPTGeneralError');
        msg = fxptui.message('msgModelNotFoundError', varargin{1}.message);
        
    case 'generalnoselection'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('errorTitleNoSelection');
        msg = fxptui.message('msgNoSelectionGeneral');
        
    case 'emptyProposedDTError'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('warningTitleProposedDT');
        msg = fxptui.message('emptyProposedDTError');
        
    case 'hotrestartwarning'
        dlgtype = TYPE_WARNING;
        [title, ~] = fxptui.message('warnTitleFPT');
        msg = fxptui.message('msgNoRangeHotRestart');
        
    case 'invalidSUD'
        dlgtype = TYPE_ERROR;
        [title, ~] = fxptui.message('errorTitleFPTGeneralError');
        msg = fxptui.message('msgInvalidSUD');
        
	% To handle the model locked error while test harness is open
	case 'errorModelLocked'
		dlgtype = TYPE_ERROR;
		[title, ~] = fxptui.message('errorTitleFPTGeneralError');
		msg = fxptui.message('errorModelLocked');
end

%cache away the titles of the dialogs so that we can destroy them later if they are still open.
if ~isempty(me)
    me.cachedWarningTitles{end+1} = title;
end

%if we're calling showdialog from MATLAB and not the UI make sure we show
%the dialogs
switch dlgtype
    case TYPE_ERROR
        %if we're testing don't launch modal dialog, output to command window
        %launch error dialog
        if (nargin > 1) && isa(varargin{1},'MException')
            msg = sprintf('%s %s\n', msg,varargin{1}.message);
        end
        if slfeature('FPTWeb')
            msgObj.Title = title;
            msgObj.Message = msg;
            message.publish('/fpt/dialog/error',msgObj);
        end
        if ~isempty(me)
            errordlg(msg, title, 'modal');
        end
        
    case TYPE_WARNING
        %if we're testing don't launch modal dialog, output to command window
        %launch warning dialog
        if slfeature('FPTWeb')
            msgObj.Title = title;
            msgObj.Message = msg;
            message.publish('/fpt/dialog/warning',msgObj);
        end
        if ~isempty(me)
            warndlg(msg, title, 'modal');
        end
        
    case TYPE_QUESTION
        if slfeature('FPTWeb')
            msgObj.Title = title;
            msgObj.Message = msg;
            msgObj.questionId = questionId;
            msgObj.QuestionOptions = btns;
            msgObj.DefaultAction = btnObj;
            if ~strcmp(msgObj.questionId,'deleteBAEDialog')
                message.publish('/fpt/dialog/question',msgObj);
            else
                btn = questdlg(msg, title, btns{:}, btndefault);
                drawnow;
            end
        end
        if ~isempty(me)
            btn = questdlg(msg, title, btns{:}, btndefault);
            drawnow;
        end
end

%-----------------------------------------------------------
% [EOF]

% LocalWords:  instrumentations
