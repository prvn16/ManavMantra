classdef SubsystemNode < fxptds.AbstractObject & matlab.mixin.internal.TreeNode & matlab.mixin.Heterogeneous
% SUBSYSTEMNODE Class definition for subsystem components in a model to be shown in the FPT
    
% Copyright 2013-2017 The MathWorks, Inc.

    properties(SetAccess=protected, GetAccess=protected)
        Identifier;
        Name;
        ChildrenMap;
        CachedFullName;                %Store the fullname of daobject so that we can retrieve the object if it is
                                       %a linked subsystem and the link is lost
        SFObjectBeingAddedListeners;   %Used in objectadded to temporarily listen to a Stateflow masked subsystem
                                       %until it's chart has been added. We want to display the chart not the
                                       %subsystem.
        ScaleUsing = message('Simulink:Models:labelActive').getString();
        SafetyMarginForSimMinMax;
        MMODominantSystem
        MMODominantParam
        DTODominantSystem
        DTODominantParam
        SLListeners
        ActionHandler
        
    end
    properties(SetAccess=protected, GetAccess=public, Hidden)
        DAObject;
        PropertyBag;
    end
    
    methods
        function this = SubsystemNode(blkObj)
            this.ChildrenMap = Simulink.sdi.Map(double(0),?handle);
            this.PropertyBag = java.util.LinkedHashMap;
            if nargin > 0 && isa(blkObj,'DAStudio.Object')
                blkObj.getChildren; % create the children if necessary
                this.initialize(blkObj)
                this.addListeners;
            end
        end
        
        function obj = getDAObject(this)
            obj = this.DAObject;
        end
        
        function identifier = getUniqueIdentifier(this)
            identifier = this.Identifier;
        end
        
        function b = isValid(this)
            b = this.Identifier.isValid;
        end

        function b = isHierarchical(~)
            b = true;
        end
        
        function parent = getHighestLevelParent(this)
            parent = this.Identifier.getHighestLevelParent;
        end
        
        function actionHandler = getActionHandler(this)
            actionHandler = this.ActionHandler;
            if isempty(actionHandler)
                this.createActionHandler;
                actionHandler = this.ActionHandler;
            end
            
        end
        
        function hilite(this)
        % Hilite the system in editor
            this.Identifier.hiliteInEditor;
        end
        
        function openSystem(this)
        % Open the system in editor
            this.Identifier.openInEditor;
        end
        
        function fireHierarchyChanged(this)
          ed = DAStudio.EventDispatcher;
          ed.broadcastEvent('HierarchyChangedEvent', this);
        end
        
        function firePropertyChanged(this)
            ed = DAStudio.EventDispatcher;
            ed.broadcastEvent('PropertyChangedEvent', this)
        end
        
        children = getChildren(this);
        cm = getContextMenu(this, selectedHandles);
        dlgStruct = getDialogSchema(this, name);
        icon = getDisplayIcon(this);
        label = getDisplayLabel(this);
        children = getHierarchicalChildren(this);
    end
    
    methods(Hidden)
        function b = isNotSupportedDTOMMO(this)
            %If this is a ModelReference, LinkedLibrary or a system under a linked library disable mmo and dto
            b = this.DAObject.isModelReference || this.DAObject.isLinked || this.isUnderLinkedLibrary;
        end
        unpopulate(this);
        results = getModelReferenceResults(this, varargin);
        results = getRootResults(this, varargin);
        [runNames, selection] = getRunsWithProposals(this);
        [runNames, selection] = getRunsForProposal(this);
        setRunSelectionForApply(this, dlg, tag);
        setRunSelectionForProposal(this, dlg, tag);
        b = isRemoveable(this);
        setLogging(this, state, scope, depth);
        node = getSupportedParentTreeNode(this);
        [status, error] = setProperties(this, dlg);
        node = findNodeInHierarchyForObject(this, daobject);
        [sys, param] = getDominantSystem(this, param);
        b = isDominantSystem(this, prop);
        [selection, list] = getDTO(this);
        [selection, list] = getDTOAppliesTo(this);
        [selection, list] = getMMO(this);
        
        function val = getParameterValue(this, param)
            % Get the parameter value of the selected subsysnode.
            val = get_param(this.DAObject.getFullName,param);
        end

        function view(this)
            % Required callback for "Contents of" hyperlink in ME
            if ~isempty(this.getUniqueIdentifier)
                this.getUniqueIdentifier.openInEditor;
            end
        end
        
        
        function child = findHierarchicalChild(this, node, depth)
            child = [];
            ch = this.getFilteredHierarchicalChildren;
            if ~isempty(ch)
                child = ch.find('-Depth',depth,'Path',node.getDAObject.Path,'-and','Name',node.getDAObject.Name);
                if isempty(child)
                    child = ch.find('-Depth',depth,'Path',node.getDAObject.getFullName,'-and','Name',node.getDAObject.Name);
                end
            end
        end
        
        function b = isParentLinked(this)
            %ISPARENTLINKED True if the parent of the daobject for this node is linked
            try
                parent = this.DAObject.getParent;
            catch e %#ok<*NASGU>
                parent = [];
            end
            b = ~isempty(parent) && parent.isLinked;
        end
        
        function b = isLinked(this)
            b = this.DAObject.isLinked;
        end
        
        function b = isUnderLinkedLibrary(this)
            b = false;
            % If h is a model node, then return.
            curParent = this.DAObject.parent;
            if isempty(curParent); return; end
            % If a block is under a library link or is a library link, then the LinkStatus will be
            % either implicit or resolved. When the link is disabled, the LinkStatus will be either none or inactive.
            if any(strcmp(get_param(this.DAObject.getFullName,'LinkStatus'), {'resolved','implicit'}))
                b = true;
            end
        end
        
        function b = isOutportEnabled(this)
            b = false;
            if ~isa(this.DAObject,'Stateflow.SLFunction')
                b = numel(this.DAObject.PortHandles.Outport) > 0;
            end
        end
        
        function b = isNodeSupported(~)
            b = true;
        end
        
        function name = getFullName(this)
        % API required by ME to display the "Contents of" hyperlink in FPT
            name = this.getDisplayLabel;
        end
    end
    
    methods(Access=private)
        dlgStruct = getRunSelectionDialogSchema(this, name);
        dlgStruct = getShortcutEditorPanel(this);
        fpaStruct = getFPAPanel(this);
        proposeOptionPanel = getProposeOptionPanel(this);
        proposeOptionPanel = getSimplifiedProposeOptionPanel(this, isenabled);
        resPanel = getResultPanel(this);
        dtPanel = getProposeDTPanel(this);
        dtPanel = getSimplifiedProposalPanel(this, isenabled, isApplyEnabled);
        settingsPanel = getSettingsPanel(this);
        simPanel = getSimPanel(this);
        sudPanel = getSUDPanel(this);
        verifyPanel = getVerificationPanel(this);
        applyPanel = getApplyPanel(this);
        resultDetailsDialog = getResultDetailsDialog(this);
    end
    
    methods(Access=protected)
        function createActionHandler(this)
            this.ActionHandler = fxptui.SubsystemNodeActions(this);
        end
        
        function b = clearMATLABResultIfNotValid(~, child)
        %Deletes the MATLAB result if it doesn't belong to a valid compile for a given run. Return true if result was deleted
            b = false;
            me = fxptui.getexplorer;
            
            % check to see if the child (MATLAB result) is invalid    
            % if the result is invalid, remove from the data set
            if fxptds.Utils.isMATLABResultInvalid(child)
                if me.HasCompletedDataCollection
                    child.getRunObject.clearResultFromRun(child);
                    delete(child);
                    b = true;
                end
            end
        end
    end
    
    methods(Access=protected)
        populate(this);
        child = addChild(this, blkObj);
        setLoggingOnOutports(this, state);
        objectAdded(this, event);
        objectRemoved(this, event);
        b = isWithinHierarchy(this, daobject);
        isMasked = isUnderMaskedSubsystem(this);
    end
    
    methods(Access=protected)
        function initialize(this, slObj)
            this.DAObject = slObj;
            this.Name = slObj.Path;
            handler = fxptds.SimulinkDataArrayHandler;
            this.Identifier = handler.getUniqueIdentifier(struct('Object',slObj));
            this.CachedFullName = fxptui.getPath(slObj.getFullName);
        end
        
        function addListeners(this)
            % Simulink block and block property event listeners
            this.SLListeners = handle.listener(this.DAObject, 'NameChangeEvent', @(s,e)fireHierarchyChanged(this));
            this.SLListeners(2) = handle.listener(this.DAObject, findprop(this.DAObject, 'MinMaxOverflowLogging'),...
                'PropertyPostSet', @(s,e)firePropertyChanged(this));
            this.SLListeners(3) = handle.listener(this.DAObject, findprop(this.DAObject, 'DataTypeOverride'),...
                'PropertyPostSet', @(s,e)firePropertyChanged(this));
            this.SLListeners(4) = handle.listener(this.DAObject, 'ObjectChildAdded', @(s,e)objectAdded(this,e));
            this.SLListeners(5) = handle.listener(this.DAObject, 'ObjectChildRemoved', @(s,e)objectRemoved(this,e));
        end
        
        function children = getFilteredHierarchicalChildren(this)
            children = this.DAObject.getHierarchicalChildren;
            children = fxptui.filter(children);
        end
        
        function key = getKeyAsDoubleType(this)
        % returns the handle to the Simulink object as a double to be used as a key on the maps.
            key = this.DAObject.Handle;
        end
    end
    
    methods(Hidden)
        function setParameterValue(this, param, paramVal)
            strVal = paramVal;
            if ~ischar(paramVal)
                strVal = fxptui.convertEnumToParamValue(param, paramVal);
            end
            try
                set_param(this.DAObject.getFullName,param,strVal);
            catch paramException
                msg =  fxptui.message('MMODTOError');
                paramMsgException = MException('Simulink:Data:DataTypeSetting', msg).addCause(paramException); %create an exception and add cause 
                throw(paramMsgException); 
            end
            this.firePropertyChanged;
        end
    end
    
    methods(Static, Hidden)
        showProposeOptions(hdlg, htag, srcPanelTag);
        updateDTOAppliesToControl(hdlg);
        setIsUsingDerivedMinMax(dlg, tag, source);
        setIsUsingSimMinMax(dlg, tag, source);
        setCollectedRange(hDlg, hTag, source);
        setDefaultContainerForFloatOrInherit(hDlg, hTag, source);
        setProposeForFloatingPoint(hDlg, hTag, source);
        setProposeForInherited(hDlg, hTag, source);
        setIsAutoSignedness(hDlg, hTag, source);
    end
end
