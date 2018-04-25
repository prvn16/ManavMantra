classdef ExplorerRoot < fxptui.AbstractRoot
% EXPLORERROOT Class definition for the root node in the explorer
% tree. This is a MCOS wrapper for the UDD ExplorerRoot class

% Copyright 2013-2014 The MathWorks, Inc.

    methods
        function cm = getContextMenu(~,~)
            cm = [];
        end
        
        function this = ExplorerRoot(modelName)
            this@fxptui.AbstractRoot;
            if nargin == 0
                return;
            end
            modelObj = get_param(modelName,'Object');
            this.populate(modelObj);
            this.DAObject = modelObj;
            this.TopChild = findobj([this.Children{:}],'-isa','fxptui.ModelNode','-and','DAObject',modelObj);
        end
        
        function topChildren = getTopChild(this)
            topChildren = this.TopChild;
        end
        
        function children = getChildren(~)
        % Get the children to be rendered in the list view
            children = [];
        end
        
        function childNodes = getModelNodes(this)
            childNodes = [this.Children{:}];
        end
        
        function dlgStruct =  getDialogSchema(~, ~)
        %Get the dialog information to be rendered for this node
            r = 1;
            %========= useShortcut ===========%
            txt1 = ModelAdvisor.Text(fxptui.message('titleFPTool'),{'bold'});
            txt2 = ModelAdvisor.Text(fxptui.message('txtUseFPT'));
            txt3 = ModelAdvisor.Text(fxptui.message('txtFPTCapability'),{'bold'});

            list = ModelAdvisor.List;
            list.addItem(ModelAdvisor.Text(fxptui.message('txtFPTCap1')));
            list.addItem(ModelAdvisor.Text(fxptui.message('txtFPTCap2')));
            list.addItem(ModelAdvisor.Text(fxptui.message('txtFPTCap3')));
            list.addItem(ModelAdvisor.Text(fxptui.message('txtFPTCap4')));
            list.addItem([ModelAdvisor.Text(fxptui.message('txtFPTCap5')), ModelAdvisor.LineBreak]);
            
            table=ModelAdvisor.Table(4,1);
            table.setBorder(0);
            table.setEntry(1,1,[txt1, ModelAdvisor.LineBreak]);
            table.setEntry(2,1,[txt2,ModelAdvisor.LineBreak]);
            table.setEntry(3,1,[txt3,ModelAdvisor.LineBreak]);
            table.setEntry(4,1,list);
            
            doc=ModelAdvisor.Document;
            doc.addItem({table});
            
            r = r+1;
            txtUseFPT.Text  = doc.emitHTML;
            txtUseFPT.Type  = 'textbrowser';
            txtUseFPT.Tag   = 'textbrowser_FPT_Root';
            txtUseFPT.RowSpan = [r r];
            txtUseFPT.ColSpan = [1 5];
            
            %=================
            % Shortcuts group
            %=================
            % Main dialog
            dlgStruct.DialogTitle = '';
            dlgStruct.DialogTag = 'FPT_Root_Dialog';
            dlgStruct.LayoutGrid  = [2 2]; 
            dlgStruct.ColStretch = [0 1];% 0 0 1];
            dlgStruct.Items = {txtUseFPT};
            dlgStruct.EmbeddedButtonSet = {'Help'};
            dlgStruct.HelpMethod = 'doc';
            dlgStruct.HelpArgs =  {'fxptdlg'};
        end
        
        function parent = getHighestLevelParent(this)
            parent = this.TopChild.DAObject.getFullName;
        end
    end
    
    methods(Hidden)
        function child = findChildNode(this, daObject)
            % Finds teh model node that corresponds to the specified
            % daObject
           child = [];
           if ~isa(daObject,'DAStudio.Object'); return; end
           child = findobj([this.Children{:}],'-isa','fxptui.ModelNode','-and','DAObject',daObject);
        end
        
        function treenode = findNodeInCompleteHierarchy(this, daObject)
            % Finds the node that corresponds to the daObject within the
            % child models
            treenode = [];
            modelNodes = this.getModelNodes;
            for i = 1:length(modelNodes)
                treenode = findobj(modelNodes(i),'DAObject',daObject);
                if(~isempty(treenode))
                    break;
                end
            end
        end
        
        function unpopulate(this)
            % Unpopulates the root
            children = this.Children;
            for idx = 1:numel(children)
                child = children{idx};
                if ~isempty(child) && isvalid(child)
                    disconnect(child);
                    unpopulate(child);
                    delete(child);
                end
            end
            for idx = 1:numel(this.TopChild)
                child = this.TopChild(idx);
                if ~isempty(child) && isvalid(child)
                    disconnect(child);
                    unpopulate(child);
                    delete(child);
                end
            end
            this.Children = [];
            this.DAObject = [];
            this.TopChild = [];
        end
  
        function populate(this, varargin)
            % Populates the root node
            if nargin == 1
                return;
            end
            mdlname = varargin{1}.getFullName;
            child = fxptui.ModelNode(get_param(mdlname,'Object'));
            if isempty(this.Children)
                this.Children = {child};
            else
                this.Children{end+1} = child;
            end
            try
                [refMdls, ~] = find_mdlrefs(mdlname);
            catch mdl_not_found_exception % Model not on path.
                fxptui.showdialog('modelnotfound',mdl_not_found_exception);
                return;
            end
            for idx = 1:(length(refMdls)-1)
                refMdlName = refMdls{idx};
                load_system(refMdlName);
                refMdlObj = get_param(refMdlName,'Object');
                % Check if the node already exists
                refMdlNode = findobj([this.Children{:}],'DAObject',refMdlObj);
                if isempty(refMdlNode)
                    child = fxptui.ModelNode(refMdlObj);
                    this.Children{end+1} = child;
                end
            end
        end
        
        function removeChild(this, child)
            % Removes a child from the tree hierarchy
            children = this.Children;
            for i = 1:numel(children)
                if isequal(children{i},child)
                    this.Children{i} = [];
                    break;
                end
            end
            unpopulate(child);
            disconnect(child);
            ed = DAStudio.EventDispatcher;
            ed.broadcastEvent('HierarchyChangedEvent', this);
        end
        
        function removeModelNodes(this, modelName)
            isLoaded =  ~isempty(find_system(0, 'type', 'block_diagram', 'Name', modelName));
            if ~isLoaded; return; end
            bd = get_param(modelName,'Object');
            mdlNode = this.findChildNode(bd); %#ok<*GTARG>
            if isempty(mdlNode)
                return;
            end
            
            children = mdlNode.getHierarchicalChildren;
            modelNames = {};
            for i = 1:length(children)
                modelNames = [modelNames, getModelNames(this, children(i))]; %#ok<AGROW>
            end
            if ~isempty(mdlNode)
                removeChild(this, mdlNode);
            end
            for i = 1:length(modelNames)
                mdlObj = get_param(modelNames{i},'Object');
                mdlNode = findChildNode(this,mdlObj);
                if ~isempty(mdlNode)
                    removeChild(this, mdlNode);
                end
            end
        end
        
        function isModelInUse = checkModelInUse(this, modelName)
            isModelInUse = false; 
            
            allChildren = this.Children;
            for idx = 1:numel(allChildren)
                % find model reference used in the modelNode
                modelNameList = getModelNames(this, allChildren{idx}); 
                if ~isempty(modelNameList) && any(ismember(modelNameList, modelName))
                    isModelInUse = true;
                    return;
                end
            end           
        end
    end
    
    methods (Access=private)
        function modelNames = getModelNames(this, child)
            modelNames = {};
            if isempty(child)
                return;
            end
            if isa(child.DAObject,'Simulink.ModelReference')
                modelNames = {child.DAObject.ModelName};
                try
                    mdlObj = get_param(modelNames{1},'Object');
                    child = findChildNode(this,mdlObj);
                catch
                    % this model has been closed or invalid
                    % no additional information can be identified any more
                    % return empty here
                    modelNames = {};
                    return;
                end
            end
            ch = child.getHierarchicalChildren;
            for i = 1:length(ch)
                modelNames = [modelNames, getModelNames(this, ch(i))]; %#ok<AGROW>
            end
        end
    end
end
