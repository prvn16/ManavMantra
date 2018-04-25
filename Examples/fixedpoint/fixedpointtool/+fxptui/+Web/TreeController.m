classdef TreeController < handle
    % TREECONTROLLER Manages communication between MATLAB server and
    % application
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties (SetAccess = private, GetAccess = private)
        ReadySubscribeChannel = '/fpt/treedata/ready';
        TreeDataSubscribeChannel = '/fpt/treedata/getTreeNodeChildren'
        PublishChannel = '/fpt/model/hierarchy';
        PublishTreeDataChannel = '/fpt/model/treeupdate';
        TreeSelectionSubscription = '/fpt/treedata/currentSelection';
        TreeNotSelectableChannel = '/fpt/treedata/treeSelectionFailed';
        PublishTreeSelectionChannel = '/fpt/treedata/makeSelection';
        TreeInfoPublishChannel = '/fpt/data/scopingData';
        TreeNotSelectableSubscription
        TreeDataHandler
        Subscriptions
        ShowAllConstructs
        CurrentTreeNode
        ResultSelectionFunction
        ModelHierarchy
    end
    
    methods
        function this = TreeController(uniqueID, showAllConstructs, modelHierarchy)
            connector.ensureServiceOn;
            this.ModelHierarchy = modelHierarchy;
            this.TreeDataHandler = fxptui.TreeData;
            this.ReadySubscribeChannel = sprintf('%s/%s',this.ReadySubscribeChannel,uniqueID);
            this.TreeDataSubscribeChannel = sprintf('%s/%s',this.TreeDataSubscribeChannel,uniqueID);
            this.TreeSelectionSubscription = sprintf('%s/%s',this.TreeSelectionSubscription,uniqueID);
            this.TreeInfoPublishChannel = sprintf('%s/%s',this.TreeInfoPublishChannel,uniqueID);

            this.initializeSubscriptions;
            
            this.TreeNotSelectableChannel = sprintf('%s/%s',this.TreeNotSelectableChannel, uniqueID);
            this.PublishChannel = sprintf('%s/%s',this.PublishChannel, uniqueID);
            this.PublishTreeDataChannel = sprintf('%s/%s',this.PublishTreeDataChannel, uniqueID);
            this.PublishTreeSelectionChannel = sprintf('%s/%s',this.PublishTreeSelectionChannel, uniqueID);
            % Flag to show stateflow and model blocks that are not
            % supported nodes for conversion in the workflow.
            this.ShowAllConstructs = showAllConstructs;
        end
        
        function varargout = sendModelHierarchy(this, varargin)
            if nargin > 1
                data = varargin{1};
                level = data.treeDepth;
            else
                level = inf;
            end
            treeData = this.TreeDataHandler.getHierarchyData(level, this.ShowAllConstructs, this.ModelHierarchy);
            message.publish(this.PublishChannel, treeData);
            if nargout > 0
                varargout{1} = treeData;
            end
        end
        
        function sendAddedTree(this, addedTree)
            message.publish(this.TreeInfoPublishChannel, struct('addedTreeInfo',addedTree));
        end
        
        function setModel(this, modelName)
            if ~isequal(this.TreeDataHandler.getModel, modelName)
                this.TreeDataHandler = [];
                this.TreeDataHandler = fxptui.TreeData;
                this.TreeDataHandler.setModel(modelName);
            end
        end
        
        function delete(this)
            for i = 1:numel(this.Subscriptions)
                message.unsubscribe(this.Subscriptions{i});
            end
            message.unsubscribe(this.TreeNotSelectableSubscription);
            this.TreeDataHandler = [];
            this.ModelHierarchy = [];
        end
    end
    
    methods(Hidden)
        function model = getModel(this)
            model = this.TreeDataHandler.getModel;
        end
        
        function selection = getSelectedTreeNode(this)
            selection = this.CurrentTreeNode;
        end
        
        function selectTreeNode(this, treeObject)
            if ischar(treeObject)
                 treeSelectionID.identifier = treeObject;
            else
                this.initializeTreeSubscription(treeObject);
                dh = fxptds.SimulinkDataArrayHandler;
                uniqueID = dh.getUniqueIdentifier(struct('Object', treeObject));
                treeSelectionID.identifier = uniqueID.UniqueKey;
            end
            message.publish(this.PublishTreeSelectionChannel, treeSelectionID);

        end
        
        function selectParentTreeNode(this, treeObject)
            blockObject = treeObject.getParent;
            this.selectTreeNode(blockObject);
        end        
        
        function updateChannels(this, clientData)
            for i = 1:numel(this.Subscriptions)
                message.unsubscribe(this.Subscriptions{i});
            end
            this.ReadySubscribeChannel = strrep(this.ReadySubscribeChannel, clientData.oldUniqueID, clientData.startupTreeUniqueID);
            this.TreeDataSubscribeChannel = strrep(this.TreeDataSubscribeChannel, clientData.oldUniqueID, clientData.startupTreeUniqueID);
            this.TreeSelectionSubscription = strrep(this.TreeSelectionSubscription, clientData.oldUniqueID, clientData.startupTreeUniqueID);
            this.initializeSubscriptions;
            
            this.PublishChannel = strrep(this.PublishChannel, clientData.oldUniqueID, clientData.startupTreeUniqueID);
            this.PublishTreeDataChannel = strrep(this.PublishTreeDataChannel, clientData.oldUniqueID, clientData.startupTreeUniqueID);
            this.TreeNotSelectableChannel = strrep(this.TreeNotSelectableChannel, clientData.oldUniqueID, clientData.startupTreeUniqueID);
            this.PublishTreeSelectionChannel = strrep(this.PublishTreeSelectionChannel, clientData.oldUniqueID, clientData.startupTreeUniqueID);
        end
    end
    
    methods(Hidden)
        function treeData = getTreeData(this, data)
            sysPath = fxptds.getBlockPathFromIdentifier(data.identifier, data.class);
            if strfind(data.class,'Stateflow')
                sysObj = fxptds.getSFObjFromPath(sysPath);
            else
                sysObj = get_param(sysPath,'Object');
            end
            if fxptds.isSFMaskedSubsystem(sysObj)
                sysObj = fxptds.getSFChartObject(sysObj);           
            end
            treeData = this.TreeDataHandler.getChildren(sysObj, data.level, this.ShowAllConstructs, this.ModelHierarchy);
            idsToCheck = {data.identifier};
            if ~isempty(treeData)
                idsToCheck = [idsToCheck {treeData.identifier}];
            end
            if isfield(data, 'targetNode') && ~isequal(data.identifier, data.targetNode.identifier)               
                foundTarget = any(cellfun(@(x)strcmp(x,data.targetNode.identifier), idsToCheck));
                if ~foundTarget
                    % This situation is encountered when the target is
                    % within chart. In the SUD tree, the stateflow states
                    % are not shown as they are not valid systems for
                    % conversion. However, the main tree will display them.
                    % We will need to go deeper than the levels that was
                    % sent from the client.
                    if data.targetNode.isWithinStateflow
                        [~, chartObj] = fxptds.getBlockPathFromIdentifier(data.targetNode.chartID, 'Stateflow');
                        additionalData = this.TreeDataHandler.getChildren(chartObj, inf, this.ShowAllConstructs, this.ModelHierarchy);
                        treeData = [treeData additionalData];
                    end
                end
            end
            message.publish(this.PublishTreeDataChannel, treeData);
        end
        
    end
    
    methods(Access = 'private')        
        function updateCurrentSelection(this, clientData)
            if isfield(clientData,'class') 
                if strcmpi(clientData.class, 'MATLABFunction')
                    this.CurrentTreeNode = clientData.MATLABIDForHighlight;
                else
                    try
                        [~, treeObj] = fxptds.getBlockPathFromIdentifier(clientData.identifier, clientData.class);
                        if ~isempty(treeObj)
                            this.CurrentTreeNode = treeObj;
                        end
                    catch
                        % The tree object could not be resolved. Do not
                        % cache selection.
                        % fxptds.getBlockPathFromIdentifier can error out
                        % when resolving Simulink blocks.
                    end
                end
            else
                this.CurrentTreeNode = clientData.id;
            end            
            % If a result selection function handle is valid then select
            % the result in the UI
            if isa(this.ResultSelectionFunction, 'function_handle')
                this.ResultSelectionFunction();
                this.ResultSelectionFunction = [];
            end
        end
        
         function initializeTreeSubscription(this, treeObject)
            if ~isempty(this.TreeNotSelectableSubscription)
                message.unsubscribe(this.TreeNotSelectableSubscription);
                this.TreeNotSelectableSubscription = [];
            end
            this.TreeNotSelectableSubscription = message.subscribe(this.TreeNotSelectableChannel, @(msg)this.selectParentTreeNode(treeObject));          
        end
        
        function initializeSubscriptions(this)
            this.Subscriptions{1} = message.subscribe(this.ReadySubscribeChannel, @(data)this.sendModelHierarchy(data));
            this.Subscriptions{2} = message.subscribe(this.TreeDataSubscribeChannel, @(data)this.getTreeData(data));
            this.Subscriptions{3} = message.subscribe(this.TreeSelectionSubscription, @(data)this.updateCurrentSelection(data));
        end
    end
end

% LocalWords:  fpt treedata treeupdate
