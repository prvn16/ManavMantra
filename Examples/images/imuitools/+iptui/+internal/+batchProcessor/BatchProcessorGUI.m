% Copyright 2014-2017 The MathWorks, Inc.


classdef BatchProcessorGUI < handle
    
    properties (Hidden)
        GroupName
        
        % TODO - expose only those required
        %     end
        %     properties (Access = private)
        
        %% Toolstrip
        ToolGroup
        MainTab
        
        % Load
        LoadSection
        LoadButton
        
        % Batch Function
        BatchFunctionSection
        BatchFunctionNameComboBox
        BatchFunctionCreateButton
        BatchFunctionOpenInEditorButton
        BatchFunctionBrowseButton
        
        % Parallel
        ParallelSection
        ProcessInParallelLabel
        ProcessInParallelToggle
        
        % Process
        ProcessPanel
        ProcessSection
        ProcessStopButton
        
        % Zoom Pan
        ZoomPanSection
        ZoomInButton
        ZoomOutButton
        PanButton
        LinkAxesButton
        
        % Default Layout
        LayoutSection
        DefaultLayoutButton
        
        % Export
        ExportSection
        ExportButton
        
        
        %% Handles
        imageStrip    = [];
        
        hExceptionDisplay = [];
        hInputImage       = [];
        hBatchThumbnails       = [];
        hResultDisplay    = [];
        hResultDisplayPanel = [];
        hResultsVerticalSlider = [];
        hResultsVerticalSliderPersistentValue = inf;
        
        resutNamesToShowAsOutputImages = {};
        hOutputImages     = matlab.graphics.primitive.Image.empty();
        
        batchFunctionTextChangedListner;
        
        helpButtonListner;
        
        %% Computation
        imageBatchDataStore
        batchFunctionName
        batchFunctionFullFile
        batchFunctionHandle
        batchProcessor
        
        
        %% Java
        
        jProgressLabel = [];
        jProgressBar   = [];
        dataBrowserPanel = [];
        
        
        %% State
        
        
        selectedImgInds     = [];
        currentlyProcessing = false;
        currentlyClosing    = false;
        stopRequested       = false;
        
        numberOfTodoImages    = 0;
        numberOfQueuedImages  = 0;
        numberOfDoneImages    = 0;
        numberOfErroredImages = 0;
        
        createdFunctionDocument = [];
        
        settingsObj;
        maxMemory = 5; % as specified in images.settings
        temporaryResultsFolder;
        
        resultsExistToExport   = false;
        unexportedResultsExist = false;
        lastProcessedInd      = [];
        
        fieldsSelectedForWS   = {};
        fileNameFieldSelected = false;
        fieldsSelectedForFile = {};
    end
    
    
    %% API
    methods
        function tool = BatchProcessorGUI()
            narginchk(0,2);
            
            imageslib.internal.apputil.manageToolInstances('add', 'imageBatchProcessor', tool);
            tool.settingsObj = settings;
            
            % Toolstrip
            tool.GroupName  = matlab.lang.makeValidName(tempname);
            tool.ToolGroup = toolpack.desktop.ToolGroup(tool.GroupName,...
                getString(message('images:imageBatchProcessor:appName')));
            tool.MainTab = tool.ToolGroup.addTab('MainTab', ...
                getString(message('images:imageBatchProcessor:mainTabName')));
            
            % Add DDUX logging to Toolgroup
            images.internal.app.utilities.addDDUXLogging(tool.ToolGroup,'Image Processing Toolbox','Image Batch Processor');
            
            addlistener(tool.ToolGroup, 'GroupAction',@tool.userClosed);
            addlistener(tool.ToolGroup, 'GroupAction',@tool.gainedFocus);
            
            % Load
            tool.LoadSection = tool.MainTab.addSection('Load',...
                getString(message('images:imageBatchProcessor:loadSectionLabel')));
            tool.layoutLoadSection();
            % Batch Function
            tool.BatchFunctionSection = tool.MainTab.addSection('BatchFunction',...
                getString(message('images:imageBatchProcessor:batchFunctionSectionLabel')));
            tool.layoutBatchFunctionSection();
            % Parallel
            if(images.internal.isPCTInstalled())
                tool.ParallelSection = tool.MainTab.addSection('Parallel',...
                    getString(message('images:imageBatchProcessor:processInParallelLabel')));
                tool.layoutParallelSection();
            else
                tool.ProcessInParallelToggle.Selected = false;
            end
            % Process
            tool.ProcessSection = tool.MainTab.addSection('Process',...
                getString(message('images:imageBatchProcessor:processSectionLabel')));
            tool.layoutProcessSection();
            % Zoom/Pan
            tool.ZoomPanSection = tool.MainTab.addSection('Zoom',...
                getString(message('images:commonUIString:zoomAndPan')));
            tool.layoutZoomPanSection();
            % Layout
            tool.LayoutSection = tool.MainTab.addSection('Layout',...
                getString(message('images:commonUIString:layout')));
            tool.layoutLayoutSection();
            % Export
            tool.ExportSection = tool.MainTab.addSection('Export',...
                getString(message('images:imageBatchProcessor:exportSectionLabel')));
            tool.layoutExportSection();
            
            group = tool.ToolGroup.Peer.getWrappedComponent;
            % Remove View tab
            group.putGroupProperty(...
                com.mathworks.widgets.desk.DTGroupProperty.ACCEPT_DEFAULT_VIEW_TAB,...
                false);
            
            % Disable drag-drop
            dropListener = com.mathworks.widgets.desk.DTGroupProperty.IGNORE_ALL_DROPS;
            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.DROP_LISTENER, dropListener);
                        
            % Help button
            action = com.mathworks.toolbox.shared.controllib.desktop.TSUtils.getAction('My Help', javax.swing.ImageIcon);
            tool.helpButtonListner = addlistener(action.getCallback, 'delayed', 'doc(''imageBatchProcessor'')');
            ctm = com.mathworks.toolstrip.factory.ContextTargetingManager;
            ctm.setToolName(action, 'help')           
            ja = javaArray('javax.swing.Action', 1);
            ja(1) = action;            
            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.CONTEXT_ACTIONS, ja);
            
            tool.ToolGroup.setClosingApprovalNeeded(true);

            tool.ToolGroup.open();
            
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            md.removeClient('DataBrowserContainer',tool.GroupName);
            
            tool.ToolGroup.open();
            
            imageslib.internal.apputil.ScreenUtilities.setInitialToolPosition(tool.GroupName);                        
                        
            % Setup space to report progress
            frame = md.getFrameContainingGroup(tool.GroupName);
            sb = javaObjectEDT('com.mathworks.mwswing.MJStatusBar');
            javaMethodEDT('setSharedStatusBar', frame, sb);
            tool.jProgressBar = javaObjectEDT('javax.swing.JProgressBar');
            tool.jProgressBar.setVisible(false);
            sb.add(tool.jProgressBar);
            
            tool.jProgressLabel = javaObjectEDT('javax.swing.JLabel','');
            tool.jProgressLabel.setName('progressLabel');
            sb.add(tool.jProgressLabel);
            
            % Folder to save results before they get exported
            tool.temporaryResultsFolder = tempname;
            tool.createDirOrDie(tool.temporaryResultsFolder);
            
            tool.setState('notReady');
            
        end
        
        function loadImages(tool, imageDataStore_)
            assert(isa(imageDataStore_,'iptui.internal.batchProcessor.ImageBatchDataStore'));
            tool.imageBatchDataStore = imageDataStore_;
            tool.refreshimageStripAndAppState();
            tool.setReadyIfPossible();
        end
        
        function setBatchFunction(tool, fullFunctionFileName)
            assert(exist(fullFunctionFileName,'file')==2);
            [~, fileName]  = fileparts(fullFunctionFileName);
            tool.tryToUpdateBatchFunction(fullFunctionFileName, fileName);
        end
        
        function showThisResultImage(tool, resultName)
            if ~any(strcmp(tool.resutNamesToShowAsOutputImages, resultName))
                tool.resutNamesToShowAsOutputImages{end+1} = resultName;
            end
            
            % Find if its already been created
            hFig = [];
            for hind = 1:numel(tool.hOutputImages)
                if strcmp(tool.hOutputImages(hind).Name, resultName)
                    hFig = tool.hOutputImages(hind);
                    break;
                end
            end
            
            if isempty(hFig)
                % Create
                tool.updateAllFigures();
            else
                % Focus
                figure(hFig);
            end
        end
        
        function delete(tool)
            imageslib.internal.apputil.manageToolInstances('remove', 'imageBatchProcessor', tool);
            tool.ToolGroup.setClosingApprovalNeeded(false);
            tool.ToolGroup.approveClose();
            tool.currentlyClosing = true;
            delete(tool.imageStrip);
            delete(tool.hBatchThumbnails);
            delete(tool.hResultDisplay);
            delete(tool.hInputImage);
            tool.cleanUpTemporaryResults();
            tool.ToolGroup.close();
        end
        
    end
    
    %% Helpers
    methods (Access=private)
        function createDirOrDie(tool,newDirName)
            [dirCreated, creationMessage] = mkdir(newDirName);
            if(~dirCreated)
                % Drastic, but the app cant go on.
                tool.delete();
                error(message('images:imageBatchProcessor:unableToCreateDir',...
                    newDirName,...
                    creationMessage));
            end
        end
        
        function gainedFocus(tool, varargin)
            if strcmp(varargin{2}.EventData.EventType, 'ACTIVATED')
                % App came into focus.
                tool.checkIfUserBatchFunctionWasSaved();
            end
        end
        
        function userClosed(tool, varargin)
            if strcmp(varargin{2}.EventData.EventType, 'CLOSING')
                tool.checkAndClose();
            end
        end
        
        function checkAndClose(tool, varargin)
            if(~isvalid(tool) || tool.currentlyClosing)
                % Already in the process of closing
                return;
            end
            
            if(tool.currentlyProcessing)
                noStr  = getString(message('images:commonUIString:no'));
                yesStr = getString(message('images:commonUIString:yes'));
                
                selectedStr = questdlg(...
                    getString(message('images:imageBatchProcessor:closeWhenRunning')),...
                    getString(message('images:imageBatchProcessor:closeWhenRunningTitle')),...
                    yesStr, noStr, noStr);
                if(strcmp(selectedStr, noStr))
                    tool.ToolGroup.vetoClose();
                    return;
                end
            end
                        
            canContinue = tool.unexportedResultsDialog();
            if(~canContinue)
                tool.ToolGroup.vetoClose();
                return;
            end        
            
            tool.delete();
        end
        
        function canContinue = unexportedResultsDialog(tool)
            canContinue = true;
            if(tool.unexportedResultsExist)
                noStr  = getString(message('images:commonUIString:no'));
                yesStr = getString(message('images:commonUIString:yes'));
                selectedStr = questdlg(...
                    getString(message('images:imageBatchProcessor:unexportedResults')),...
                    getString(message('images:imageBatchProcessor:unexportedResultsTitle')),...
                    yesStr, noStr, noStr);
                if(strcmp(selectedStr, noStr))
                    canContinue = false;
                end
            end
        end
        
        function cleanUpTemporaryResults(tool)
            if(isempty(tool.temporaryResultsFolder))
                return;
            end
            [cleanedUp, failMessage] = rmdir(tool.temporaryResultsFolder,'s');
            if(~cleanedUp)
                warning(message('images:imageBatchProcessor:failedToCleanUp',...
                    tool.temporaryResultsFolder,...
                    failMessage));
            end
        end
    end
    
    %% Layout and Toolstrip Callbacks
    
    % Load
    methods (Access=private)
        function layoutLoadSection(tool)
            loadPanel = toolpack.component.TSPanel('f:p','f:p');
            loadPanel.Name = 'panelLoad';
            tool.LoadSection.add(loadPanel);
            
            tool.LoadButton = toolpack.component.TSButton(...
                getString(message('images:imageBatchProcessor:loadButtonText')),...
                toolpack.component.Icon.IMPORT_24);
            tool.LoadButton.Name = 'LoadButton';
            iptui.internal.utilities.setToolTipText(...
                tool.LoadButton,...
                getString(message('images:imageBatchProcessor:loadButtonTextToolTip')));
            tool.LoadButton.Orientation = toolpack.component.ButtonOrientation.VERTICAL;
            
            addlistener(tool.LoadButton, 'ActionPerformed',...
                @tool.loadDirectory);
            loadPanel.add(tool.LoadButton,'xy(1,1)');
        end
        
        function loadDirectory(tool, varargin)
            if(~tool.unexportedResultsDialog())
                return;
            end
            [cancelled, newBatchDataStore] = ...
                iptui.internal.batchProcessor.loadInputBatchFolderDialog(tool.GroupName);
            if(~cancelled)
                tool.imageBatchDataStore = newBatchDataStore;
                tool.refreshimageStripAndAppState();
                tool.setReadyIfPossible();
            end
        end
        
    end
    
    % Batch Function
    methods (Access=private)
        
        function layoutBatchFunctionSection(tool)
            batchPanel = toolpack.component.TSPanel(...
                '70px,80px,f:p',... %columns
                '1dlu, f:p, 1dlu, f:p, 2dlu, f:p:g, 1dlu');
            batchPanel.Name = 'panelBatch';
            tool.BatchFunctionSection.add(batchPanel);
            
            % Top row
            batchLabel = toolpack.component.TSLabel(...
                getString(message('images:imageBatchProcessor:batchFunctionLabel')));
            batchPanel.add(batchLabel,'xyw(1,2,2)');
            
            
            % Middle row - text box
            tool.BatchFunctionNameComboBox = toolpack.component.TSComboBox();
            tool.BatchFunctionNameComboBox.Name = 'BatchFunctionName';
            tool.BatchFunctionNameComboBox.Editable = true;
            
            tool.batchFunctionTextChangedListner = ...
                addlistener(tool.BatchFunctionNameComboBox,'ActionPerformed',...
                @tool.batchNameInTextBoxChanged);
            batchPanel.add(tool.BatchFunctionNameComboBox,'xyw(1,4,2)');
            
            % Middle row - open
            tool.BatchFunctionBrowseButton = toolpack.component.TSButton(...
                '',...
                toolpack.component.Icon.OPEN);
            tool.BatchFunctionBrowseButton.Name = 'FunctionBrowseButton';
            iptui.internal.utilities.setToolTipText(...
                tool.BatchFunctionBrowseButton,...
                getString(message('images:imageBatchProcessor:batchFunctionAddToolTip')));
            
            addlistener(tool.BatchFunctionBrowseButton, 'ActionPerformed',...
                @tool.batchFileBrowse);
            batchPanel.add(tool.BatchFunctionBrowseButton,'xy(3,4)');
            
            
            % Bottom row - create
            tool.BatchFunctionCreateButton = toolpack.component.TSButton(...
                getString(message('images:imageBatchProcessor:createLabel')),...
                toolpack.component.Icon.NEW);
            tool.BatchFunctionCreateButton.Name = 'CreateBatchFunctionButton';
            iptui.internal.utilities.setToolTipText(...
                tool.BatchFunctionCreateButton ,...
                getString(message('images:imageBatchProcessor:createToolTip')));
            
            addlistener(tool.BatchFunctionCreateButton, 'ActionPerformed',...
                @tool.createBatchFunctionInEditor);
            batchPanel.add(tool.BatchFunctionCreateButton,'xy(1,6)');
            
            % Bottom row - edit
            ei = com.mathworks.common.icons.ApplicationIcon.EDITOR.getIcon();
            icon = toolpack.component.Icon(ei);
            
            tool.BatchFunctionOpenInEditorButton = toolpack.component.TSButton(...
                getString(message('images:imageBatchProcessor:openInEditorLabel')),...
                icon);
            tool.BatchFunctionOpenInEditorButton.Name = 'OpenInEditorButton';
            iptui.internal.utilities.setToolTipText(...
                tool.BatchFunctionOpenInEditorButton ,...
                getString(message('images:imageBatchProcessor:openInEditorToolTip')));
            
            addlistener(tool.BatchFunctionOpenInEditorButton, 'ActionPerformed',...
                @tool.openBatchFunctionInEditor);
            batchPanel.add(tool.BatchFunctionOpenInEditorButton,'xy(2,6)');
            
            
            % Initialize
            tool.updateBatchFunctionComboBoxFromHistory();
        end
        
        function batchNameInTextBoxChanged(tool, varargin)
            selectedText = tool.BatchFunctionNameComboBox.SelectedItem;
            
            if(~tool.unexportedResultsDialog())
                % reset
                tool.batchFunctionInvalid(selectedText);
                return;
            end            
            
            if(strcmp(selectedText,getString(message('images:imageBatchProcessor:batchFunctionInitialText'))))
                % No action if the initial helper text is selected
                return;
            end
            
            if(any(filesep == selectedText))
                % / or \ found, treat as absolute path
                fullFcnFile = selectedText;
                [~, fileName] = fileparts(fullFcnFile);
            else
                fileName = selectedText;
                fullFcnFile = tool.findPathGivenFunctionFileName(fileName);
            end
            
            tool.tryToUpdateBatchFunction(fullFcnFile, fileName);
        end
        
        function fullFcnFile = findPathGivenFunctionFileName(tool, fileName)
            fullFcnFile = '';
            
            % Check if we have full path for this function in history
            fullFcnPaths = tool.settingsObj.images.imagebatchprocessingtool.BatchFunctions.ActiveValue;
            for ind = numel(fullFcnPaths):-1:1
                [~, rFileName] = fileparts(fullFcnPaths{ind}); % remembered file name
                if(strcmp(fileName,rFileName))
                    fullFcnFile = fullFcnPaths{ind};
                    break;
                end
            end
            
            if(isempty(fullFcnFile))
                % See if its on path
                try
                    fullFcnFile = which(fileName);
                catch ALL %#ok<NASGU>
                    % will fail for bad strings (or function handles)
                    fullFcnFile ='';
                end
                if(isempty(fullFcnFile))
                    % Not on path
                    fullFcnFile = fileName;
                end
            end
        end
        
        function batchFileBrowse(tool, varargin)
            if(~tool.unexportedResultsDialog())
                return;
            end
            [fileName, filePath]  = uigetfile('*.m',...
                getString(message('images:imageBatchProcessor:selectBatchFunction')));
            if(fileName == 0)
                return;
            end
            tool.tryToUpdateBatchFunction([filePath, filesep, fileName], fileName);
        end
        
        function tryToUpdateBatchFunction(tool, fullFcnFile, fileName)
            [fcnPath, ~, fcnExt] = fileparts(fullFcnFile);
            
            if(~strcmpi(fcnExt, '.m') || ~exist(fullFcnFile,'file'))
                errordlg(getString(message('images:imageBatchProcessor:invalidFunctionFile', fullFcnFile)),...
                    getString(message('images:imageBatchProcessor:invalidFunctionFileTitle')),...
                    'modal');
                tool.batchFunctionInvalid(fullFcnFile);
                return;
            end
            
            % Get a clean file name
            % e.g. cleans up ../folder//file.m to .../folder/file.m
            fid = fopen(fullFcnFile,'r');
            closeFile = onCleanup(@()fclose(fid));
            fullFcnFile = fopen(fid);
            clear closeFile;
            
            if(isempty(fcnPath))
                errordlg(getString(message('images:imageBatchProcessor:pathNotFoundError', fullFcnFile)),...
                    getString(message('images:imageBatchProcessor:pathNotFoundTitle')),...
                    'modal');
                tool.batchFunctionInvalid(fullFcnFile);
                return;
            end
            
            % Cross check with WHICH
            whichPath = which(fileName);
            
            if(isempty(whichPath))
                % Not on path - cd or add path?
                cancelButton    = getString(message('images:commonUIString:cancel'));
                addToPathButton = getString(message('images:imageBatchProcessor:addToPath'));
                cdButton        = getString(message('images:imageBatchProcessor:cdFolder'));
                buttonName = questdlg(getString(message('images:imageBatchProcessor:notOnPathQuestion', fcnPath)),...
                    getString(message('images:imageBatchProcessor:notOnPathTitle')),...
                    cdButton, addToPathButton, cancelButton, cdButton);
                switch buttonName
                    case cdButton
                        cd(fcnPath);
                    case addToPathButton
                        addpath(fcnPath);
                    otherwise
                        % cancel
                        tool.batchFunctionInvalid(fullFcnFile);
                        return
                end
            elseif(~strcmpi(whichPath, fullFcnFile))
                % Clash. No clean way to handle this, so error out.
                errordlg(getString(message('images:imageBatchProcessor:nameClash', fileName, whichPath)),...
                    getString(message('images:imageBatchProcessor:nameClashTitle')),'modal');
                tool.batchFunctionInvalid(fullFcnFile);
                return;
            end
            
            tool.validBatchFunctionPathDefined(fullFcnFile);
        end
        
        function validBatchFunctionPathDefined(tool, fullFcnFile)
            [~, fcnName] = fileparts(fullFcnFile);
            
            if(strcmpi(fullFcnFile, tool.batchFunctionFullFile)...
                    && strcmpi(fcnName, tool.BatchFunctionNameComboBox.SelectedItem))
                % Change already registered.
                return;
            end
            
            tool.batchFunctionFullFile = fullFcnFile;
            tool.batchFunctionName     = fcnName;
            
            tool.batchFunctionHandle   = str2func(tool.batchFunctionName);
            
            tool.rememberBatchFunction();
            tool.updateBatchFunctionComboBoxFromHistory();
            
            % refresh imageStrip history if this results folder
            % already contains some results.
            tool.refreshStateOnFunctionChange();
            
            % A function was specified, forget about any generated user
            % batch code.
            tool.createdFunctionDocument = [];
            tool.BatchFunctionNameComboBox.Enabled = true;
            
            % Saved field names no longer mean the same
            tool.fieldsSelectedForWS = {};
            tool.fieldsSelectedForFile = {};
            
            tool.setReadyIfPossible();
        end
        
        function rememberBatchFunction(tool)
            fullFcnPaths = tool.settingsObj.images.imagebatchprocessingtool.BatchFunctions.ActiveValue;
            if(isempty(fullFcnPaths)||isempty(fullFcnPaths{1}))
                fullFcnPaths = {};
            end
            
            inds = strcmp(tool.batchFunctionFullFile, fullFcnPaths);
            if(any(inds))
                % Already remembered, move to head of list
                fullFcnPaths = [{tool.batchFunctionFullFile}, fullFcnPaths];
                lind = find(inds);
                fullFcnPaths(lind+1) = [];
            else
                % Not previously remembered.
                numNewFunctions = min(tool.maxMemory, numel(fullFcnPaths)+1);
                newFunctions = cell(1,numNewFunctions);
                newFunctions(1:numel(fullFcnPaths)) = fullFcnPaths;
                % Shift down
                newFunctions(2:end) = newFunctions(1:end-1);
                newFunctions{1} = tool.batchFunctionFullFile;
                fullFcnPaths = newFunctions;
            end
            curMemory = min(tool.maxMemory, numel(fullFcnPaths));
            functionNamesToSave = fullFcnPaths(1:curMemory);
            tool.settingsObj.images.imagebatchprocessingtool.BatchFunctions.PersonalValue = functionNamesToSave;
        end
        
        function updateBatchFunctionComboBoxFromHistory(tool)                        
            tool.BatchFunctionNameComboBox.removeAllItems();
            
            functionNames = tool.settingsObj.images.imagebatchprocessingtool.BatchFunctions.ActiveValue;
                        
            if(isempty(functionNames)||isempty(functionNames{1}))
                % Initialize
                tool.BatchFunctionNameComboBox.addItem(...
                    getString(message('images:imageBatchProcessor:batchFunctionInitialText')));
                iptui.internal.utilities.setToolTipText(...
                    tool.BatchFunctionNameComboBox,...
                    getString(message('images:imageBatchProcessor:batchFunctionNameToolTip')));
            else
                % Load from history
                for ind = 1:numel(functionNames)
                    [~, fcnName] = fileparts(functionNames{ind});
                    tool.BatchFunctionNameComboBox.addItem(fcnName);
                end
                tool.BatchFunctionNameComboBox.SelectedIndex = 1;
                iptui.internal.utilities.setToolTipText(...
                    tool.BatchFunctionNameComboBox,functionNames{1});
                tool.BatchFunctionOpenInEditorButton.Enabled = true;
            end           
        end
        
        function batchFunctionInvalid(tool, fullFcnFile)
            % Forget bad file
            tool.batchFunctionTextChangedListner.Enabled = false;
            
            previousFunctions = tool.settingsObj.images.imagebatchprocessingtool.BatchFunctions.ActiveValue;
            badIndex = strcmp(fullFcnFile, previousFunctions);
            previousFunctions(badIndex) = [];
            tool.settingsObj.images.imagebatchprocessingtool.BatchFunctions.PersonalValue = previousFunctions;
            % Reinitialize
            tool.updateBatchFunctionComboBoxFromHistory();
            
            % Required to ensure combo box is settled before the listner is
            % enabled below (else results in an infinte loop).
            drawnow;
            
            tool.batchFunctionTextChangedListner.Enabled = true;           
        end
        
        function createBatchFunctionInEditor(tool, varargin)
            if(~tool.unexportedResultsDialog())
                return;
            end
            templateFile = fullfile(matlabroot, 'toolbox','images','imuitools','+iptui','+internal','+batchProcessor','userBatchFunction.template');
            codeString = fileread(templateFile);
            tool.createdFunctionDocument = matlab.desktop.editor.newDocument(codeString);
        end
        
        function checkIfUserBatchFunctionWasSaved(tool)
            if(isvalid(tool) && ~isempty(tool.createdFunctionDocument))
                % A user batch function was generated
                if(tool.createdFunctionDocument.Opened)
                    if(tool.createdFunctionDocument.Modified)
                        tool.BatchFunctionNameComboBox.Enabled = false;
                        iptui.internal.utilities.setToolTipText(...
                            tool.BatchFunctionNameComboBox,...
                            getString(message('images:imageBatchProcessor:saveGeneratedUserBatchCode', ...
                            tool.createdFunctionDocument.Filename)))
                    else
                        % Generated code was saved, update with full file
                        % name and update the short name
                        tool.BatchFunctionNameComboBox.Enabled = true;
                        fullFcnPath = tool.createdFunctionDocument.Filename;
                        [~, fileName] = fileparts(fullFcnPath);
                        tool.tryToUpdateBatchFunction(fullFcnPath, fileName);
                        % Forget about the generated code
                        tool.createdFunctionDocument = [];
                    end
                    
                else
                    % User closed before saving. Forget about generated
                    % code. Go back.
                    tool.BatchFunctionNameComboBox.Enabled = true;
                    tool.createdFunctionDocument = [];
                    tool.updateBatchFunctionComboBoxFromHistory();
                end
            end
        end
        
        function openBatchFunctionInEditor(tool, varargin)
            matlab.desktop.editor.openDocument(tool.batchFunctionFullFile);
        end
        
    end
    
    % Parallel
    methods (Access=private)
        function layoutParallelSection(tool)
            parallelPanel = toolpack.component.TSPanel(...
                '80px',... % columns
                'f:p');
            parallelPanel.Name = 'panelParallel';
            tool.ParallelSection.add(parallelPanel);
            
            tool.ProcessInParallelToggle = toolpack.component.TSToggleButton(...
                getString(message('images:imageBatchProcessor:useParallelLabel')),...
                toolpack.component.Icon(fullfile(matlabroot, 'toolbox/images/icons/desktop_parallel_large.png')));
            tool.ProcessInParallelToggle.Name = 'ParallelModeToggleButton';
            tool.ProcessInParallelToggle.Orientation = toolpack.component.ButtonOrientation.VERTICAL;
            iptui.internal.utilities.setToolTipText(...
                tool.ProcessInParallelToggle ,...
                getString(message('images:imageBatchProcessor:processInParallelToolTip')));
            
            tool.ProcessInParallelToggle.Enabled = false;
            addlistener(tool.ProcessInParallelToggle,'ItemStateChanged',...
                @tool.toggleParallelProcessing);
            parallelPanel.add(tool.ProcessInParallelToggle,'xy(1,1)');
        end
        
        function toggleParallelProcessing(tool, varargin)
            if(tool.ProcessInParallelToggle.Selected)
                % Toggling on
                tool.setState('locked');
                tool.ProcessInParallelToggle.Text = ...
                    getString(message('images:imageBatchProcessor:connecting'));
                iptui.internal.utilities.setStatusBarText(tool.GroupName,...
                    getString(message('images:imageBatchProcessor:connectingToPoolStatus')));
                
                ppool = tool.connectToALocalCluster();
                if(isempty(ppool))
                    % Dont toggle on the switch
                    tool.ProcessInParallelToggle.Selected = false;
                end
                
                iptui.internal.utilities.setStatusBarText(tool.GroupName,'');
                tool.ProcessInParallelToggle.Text = ...
                    getString(message('images:imageBatchProcessor:useParallelLabel'));
                tool.setState('ready');
            end
            
            % else, if toggling off, nothing to do.
        end
        
        function ppool = connectToALocalCluster(tool)
            ppool = gcp('nocreate');
            if(isempty(ppool))
                ppool = tool.tryToCreateLocalPool();
            else
                % A pool was already open, verify its on a local
                % cluster
                if(~isa(ppool.Cluster,'parallel.cluster.Local'))
                    ppool = [];
                    errordlg(...
                        getString(message('images:imageBatchProcessor:poolNotLocalString')),...
                        getString(message('images:imageBatchProcessor:poolNotLocalTitle')),...
                        'modal');
                end
            end
        end
        
        function ppool = tryToCreateLocalPool(~)
            defaultProfile = ...
                parallel.internal.settings.ProfileExpander.getClusterType(parallel.defaultClusterProfile());
            
            if(defaultProfile == parallel.internal.types.SchedulerType.Local)
                % Inform the user of the wait time
                noStr  = getString(message('images:commonUIString:no'));
                yesStr = getString(message('images:commonUIString:yes'));
                selectedStr = questdlg(...
                    getString(message('images:imageBatchProcessor:createParallelPool')),...
                    getString(message('images:imageBatchProcessor:createParallelPoolTitle')),...
                    yesStr, noStr, yesStr);
                
                if(strcmp(selectedStr, noStr))
                    ppool = [];
                else
                    % Create the default pool (ensured local)
                    ppool = parpool;
                    if(isempty(ppool))
                        errordlg(...
                            getString(message('images:imageBatchProcessor:nopoolString')),...
                            getString(message('images:imageBatchProcessor:nopoolTitle')),...
                            'modal');
                    end
                end
            else
                % Default profile not local
                ppool = [];
                errordlg(...
                    getString(message('images:imageBatchProcessor:profileNotLocalString',parallel.defaultClusterProfile())),...
                    getString(message('images:imageBatchProcessor:poolNotLocalTitle')),...
                    'modal');
            end
        end
        
    end
    
    % Process
    methods (Access=private)
        function layoutProcessSection(tool)
            tool.ProcessPanel = toolpack.component.TSPanel(...
                'f:p',... % columns
                'f:p');
            tool.ProcessPanel.Name = 'panelProcess';
            tool.ProcessSection.add(tool.ProcessPanel);
            
            tool.changeToProcessButton();
            tool.ProcessStopButton.Enabled = false;
        end
        
        function changeToProcessButton(tool)
            tool.ProcessPanel.removeAll;
            tool.ProcessStopButton = toolpack.component.TSSplitButton(...
                getString(message('images:imageBatchProcessor:processSelectedButton')));
            tool.ProcessStopButton.Name = 'ProcessStopButton';
            tool.ProcessStopButton.Orientation = toolpack.component.ButtonOrientation.VERTICAL;
            
            iptui.internal.utilities.setToolTipText(...
                tool.ProcessStopButton,...
                getString(message('images:imageBatchProcessor:processSelectedToolTip')));
            
            tool.ProcessStopButton.Icon = toolpack.component.Icon.RUN_24;
            tool.ProcessStopButton.Text = getString(message('images:imageBatchProcessor:processSelectedButton'));
            tool.ProcessStopButton.Popup       = toolpack.component.TSDropDownPopup(...
                tool.getProcessStopButtonOptions(),'icon_text');
            tool.ProcessStopButton.Popup.Name  = 'ProcessStopButtonDropDown';
            
            addlistener(tool.ProcessStopButton.Popup, 'ListItemSelected',...
                @tool.ProcessStopButtonCallback);
            addlistener(tool.ProcessStopButton, 'ActionPerformed',...
                @tool.processSelected);
            
            tool.ProcessPanel.add(tool.ProcessStopButton,'xy(1,1)');
        end
        
        function changeToStopButton(tool)
            tool.ProcessPanel.removeAll;
            tool.ProcessStopButton = toolpack.component.TSButton(...
                getString(message('images:imageBatchProcessor:processSelectedButton')));
            tool.ProcessStopButton.Name = 'ProcessStopButton';
            tool.ProcessStopButton.Orientation = toolpack.component.ButtonOrientation.VERTICAL;
            
            iptui.internal.utilities.setToolTipText(...
                tool.ProcessStopButton,...
                getString(message('images:imageBatchProcessor:stopButtonToolTip')));
            
            tool.ProcessStopButton.Icon = toolpack.component.Icon.END_24;
            tool.ProcessStopButton.Text = getString(message('images:imageBatchProcessor:stopButton'));
            addlistener(tool.ProcessStopButton, 'ActionPerformed',...
                @tool.stopProcessing);
            
            tool.ProcessPanel.add(tool.ProcessStopButton,'xy(1,1)');
        end
        
        function items = getProcessStopButtonOptions(~)
            items(1) = struct(...
                'Title', getString(message('images:imageBatchProcessor:processSelectedButton')), ...
                'Description', '', ...
                'Icon', toolpack.component.Icon.RUN_16, ...
                'Help', [], ...
                'Header', false);
            items(2) = struct(...
                'Title', getString(message('images:imageBatchProcessor:processAllButton')), ...
                'Description', '', ...
                'Icon', toolpack.component.Icon.RUN_16, ...
                'Help', [], ...
                'Header', false);
        end
        
        function ProcessStopButtonCallback(tool, src,~)
            if src.SelectedIndex == 1
                tool.processSelected();
            elseif src.SelectedIndex == 2
                tool.processAll();
            end
        end
        
        function processSelected(tool, varargin)
            tool.processDelegate(tool.selectedImgInds);
        end
        
        function processAll(tool, varargin)
            tool.processDelegate(1:tool.imageBatchDataStore.NumberOfImages);
        end
        
        function processDelegate(tool, processInds)
            if(tool.currentlyProcessing || tool.stopRequested)
                % Running, or in the processing of stopping
                return;
            end
            
            if(tool.ProcessInParallelToggle.Selected)
                % Ensure pool is still open
                if(isempty(tool.connectToALocalCluster()))
                    tool.ProcessInParallelToggle.Selected = false;
                    return;
                end
            end
            
            tool.imageBatchDataStore.WriteLocation = ...
                tool.temporaryResultsFolder;
            
            tool.currentlyProcessing = true;
            tool.setState('processing');
            
            tool.numberOfTodoImages = numel(processInds);
            
            tool.numberOfQueuedImages = 0;
            tool.numberOfDoneImages = 0;
            tool.numberOfErroredImages = 0;
            
            tool.indicateProgress();
            tool.jProgressBar.setVisible(true);
            
            tool.batchProcessor.UseParallel = ...
                tool.ProcessInParallelToggle.Selected;
            
            tool.imageStrip.markAllProcessedAsStale();
            
            try
                % Use onCleanup to reset the App in case of CTRL+C
                % issued when in this TRY block
                setDoneWhenDone = onCleanup(@()tool.doneProcessing);
                tool.batchProcessor.processSelected(processInds);
                tool.jProgressBar.setVisible(false);
                clear setDoneWhenDone;
            catch ALL
                % Unexpected
                rethrow(ALL);
            end
        end
        
        function doneProcessing(tool)
            if(~isvalid(tool))
                % tool was closed
                return;
            end
            
            if(tool.numberOfDoneImages)
                % At least one result exists
                tool.resultsExistToExport = true;
                tool.unexportedResultsExist = true;
            else
                % Without at least one successfully completed output, we
                % cant populate the result fields in the export menu.
                tool.resultsExistToExport = false;
            end
            
            tool.setState('ready');
            tool.currentlyProcessing = false;
            tool.stopRequested       = false;
        end
        
        function stopProcessing(tool, varargin)
            if(tool.currentlyProcessing)
                tool.stopRequested = true;
            end
        end
        
    end
    
    % Zoom/pan
    methods (Access=private)
        function layoutZoomPanSection(tool)
            zoomPanPanel = toolpack.component.TSPanel( ...
                'f:p, f:p', ...              % columns
                'f:p,f:p,f:p');   % rows
            zoomPanPanel.Name = 'panelZoomPan';
            tool.ZoomPanSection.add(zoomPanPanel);
            
            tool.ZoomInButton = toolpack.component.TSToggleButton(...
                getString(message('images:commonUIString:zoomInTooltip')),...
                toolpack.component.Icon.ZOOM_IN_16);
            tool.ZoomInButton.Enabled = false;
            addlistener(tool.ZoomInButton, 'ItemStateChanged', @tool.zoomIn);
            tool.ZoomInButton.Orientation = toolpack.component.ButtonOrientation.HORIZONTAL;
            iptui.internal.utilities.setToolTipText(tool.ZoomInButton,...
                getString(message('images:commonUIString:zoomInTooltip')));
            tool.ZoomInButton.Name = 'btnZoomIn';
            
            tool.ZoomOutButton = toolpack.component.TSToggleButton(...
                getString(message('images:commonUIString:zoomOutTooltip')),...
                toolpack.component.Icon.ZOOM_OUT_16);
            tool.ZoomOutButton.Enabled = false;
            addlistener(tool.ZoomOutButton, 'ItemStateChanged', @tool.zoomOut);
            tool.ZoomOutButton.Orientation = toolpack.component.ButtonOrientation.HORIZONTAL;
            iptui.internal.utilities.setToolTipText(tool.ZoomOutButton,...
                getString(message('images:commonUIString:zoomOutTooltip')));
            tool.ZoomOutButton.Name = 'btnZoomOut';
            
            tool.PanButton = toolpack.component.TSToggleButton(...
                getString(message('images:commonUIString:pan')),...
                toolpack.component.Icon.PAN_16 );
            tool.PanButton.Enabled = false;
            addlistener(tool.PanButton, 'ItemStateChanged', @tool.panImage);
            tool.PanButton.Orientation = toolpack.component.ButtonOrientation.HORIZONTAL;
            iptui.internal.utilities.setToolTipText(tool.PanButton,...
                getString(message('images:commonUIString:pan')));
            tool.PanButton.Name = 'btnPan';
            
            
            tool.LinkAxesButton = toolpack.component.TSCheckBox(...
                getString(message('images:imageBatchProcessor:linkAxes')));
            tool.LinkAxesButton.Name = 'LinkAxes';
            tool.LinkAxesButton.Enabled = true;
            tool.LinkAxesButton.Selected = true;
            iptui.internal.utilities.setToolTipText(tool.LinkAxesButton,...
                getString(message('images:imageBatchProcessor:linkAxesToolTip')));
            
            drawnow; % ensure listener doesnt fire during initialization.
            
            addlistener(tool.LinkAxesButton, 'ItemStateChanged', @(varargin)tool.updateAllFigures);
            
            zoomPanPanel.add(tool.ZoomInButton, 'xy(1,1)' );
            zoomPanPanel.add(tool.ZoomOutButton,'xy(1,2)' );
            zoomPanPanel.add(tool.PanButton,'xy(1,3)' );
            zoomPanPanel.add(tool.LinkAxesButton,'rchw(1,2,1,1)');
        end
                        
        function zoomIn(tool,hToggle,~)
            if hToggle.Selected
                tool.ZoomOutButton.Selected = false;
                tool.PanButton.Selected = false;
                
                for hFig = [tool.hInputImage, tool.hOutputImages]
                    if isvalid(hFig)
                        zoom(hFig,'off');
                        hZoomPan = zoom(hFig);
                        hZoomPan.Direction = 'in';
                        hZoomPan.Enable = 'on';
                    end
                end
            else
                if(~tool.ZoomOutButton.Selected)
                    for hFig = [tool.hInputImage, tool.hOutputImages]
                        if isvalid(hFig)
                            zoom(hFig,'off');
                        end
                    end
                end
            end
        end
        
        function zoomOut(tool,hToggle,~)
            if hToggle.Selected
                tool.ZoomInButton.Selected = false;
                tool.PanButton.Selected = false;
                
                for hFig = [tool.hInputImage, tool.hOutputImages]
                    if isvalid(hFig)
                        zoom(hFig,'off');
                        hZoomPan = zoom(hFig);
                        hZoomPan.Direction = 'out';
                        hZoomPan.Enable = 'on';
                    end
                end
            else
                if(~tool.ZoomInButton.Selected)
                    for hFig = [tool.hInputImage, tool.hOutputImages]
                        if isvalid(hFig)
                            zoom(hFig,'off');
                        end
                    end
                end
            end
        end
        
        function panImage(tool,hToggle,~)
            if hToggle.Selected
                tool.ZoomOutButton.Selected = false;
                tool.ZoomInButton.Selected = false;
                
                for hFig = [tool.hInputImage, tool.hOutputImages]
                    if isvalid(hFig)
                        hZoomPan = pan(hFig);
                        hZoomPan.Enable = 'on';
                    end
                end
            else
                for hFig = [tool.hInputImage, tool.hOutputImages]
                    if isvalid(hFig)
                        pan(hFig,'off');
                    end
                end
            end
        end
    end
    
    % Layout
    methods (Access=private)
        function layoutLayoutSection(tool)
            layoutPanel = toolpack.component.TSPanel( ...
                'f:p', ...              % columns
                'f:p');   % rows
            layoutPanel.Name = 'panelLayout';
            tool.LayoutSection.add(layoutPanel);
            
            tool.DefaultLayoutButton = toolpack.component.TSButton(...
                getString(message('images:commonUIString:defaultLayout')),...
                toolpack.component.Icon.LAYOUT_24);
            iptui.internal.utilities.setToolTipText(tool.DefaultLayoutButton,...
                getString(message('images:commonUIString:defaultLayoutTooltip')));
            tool.DefaultLayoutButton.Name = 'btnDefaultLayout';
            tool.DefaultLayoutButton.Orientation = toolpack.component.ButtonOrientation.VERTICAL;
            
            tool.DefaultLayoutButton.Enabled = false;
            
            layoutPanel.add(tool.DefaultLayoutButton,'xy(1,1)');
            
            addlistener(tool.DefaultLayoutButton, 'ActionPerformed',...
                @tool.resetToDefaultLayout);
            
        end
        
        function resetToDefaultLayout(tool, varargin)            
            tool.createBatchThumbnailsAndInputImageFigures();            
            
            % Delete result 
            if ~isempty(tool.hResultDisplay) && isvalid(tool.hResultDisplay)
                delete(tool.hResultDisplay);
            end
            tool.hResultDisplay = [];
            
            % Close all outputs
            for hind=numel(tool.hOutputImages):-1:1
                close(tool.hOutputImages(hind));
            end
            tool.resutNamesToShowAsOutputImages = {};
            % and dont create again
            
            if ~isempty(tool.lastProcessedInd)
                % and create again if at least one image was processed
                % do this after output images have been closed
                tool.createResultFigure();
            end
           
            % Reset zoom pan
            tool.ZoomOutButton.Selected = false;
            tool.ZoomInButton.Selected  = false;
            tool.PanButton.Selected     = false;
            
            tool.updateAllFigures();
        end
    end
    
    % Export
    methods (Access=private)
        function layoutExportSection(tool)
            exportPanel      = toolpack.component.TSPanel('f:p:g, f:p, f:p:g','f:p');
            exportPanel.Name = 'panelExport';
            tool.ExportSection.add(exportPanel);
            
            tool.ExportButton = toolpack.component.TSSplitButton(...
                getString(message('images:imageBatchProcessor:exportButtonLabel')),...
                toolpack.component.Icon.CONFIRM_24);
            tool.ExportButton.Name = 'ExportButton';
            iptui.internal.utilities.setToolTipText(...
                tool.ExportButton,...
                getString(message('images:imageBatchProcessor:exportButtonToolTip')));
            tool.ExportButton.Orientation = toolpack.component.ButtonOrientation.VERTICAL;
            tool.ExportButton.Enabled     = false;
            
            % Default action - to workspace
            addlistener(tool.ExportButton, 'ActionPerformed',...
                @(hobj,evt) tool.exportResultsToWorkspaceUI());
            
            tool.ExportButton.Popup = toolpack.component.TSDropDownPopup(...
                getExportOptions(), 'icon_text');
            tool.ExportButton.Popup.Name = 'ExportPopup';
            % -------------------------------------------------------------
            function items = getExportOptions(~)
                % Defining the option entries appearing on the popup of the
                % Export Split Button.
                
                exportDataIcon = toolpack.component.Icon.EXPORT_16;
                exportFunctionIcon = toolpack.component.Icon(...
                    fullfile(matlabroot,'/toolbox/images/icons/GenerateMATLABScript_Icon_16px.png'));
                
                items(1) = struct(...
                    'Title', getString(message('images:imageBatchProcessor:exportToWorkSpace')), ...
                    'Description', '', ...
                    'Icon', exportDataIcon, ...
                    'Help', [], ...
                    'Header', false);
                
                items(2) = struct(...
                    'Title', getString(message('images:imageBatchProcessor:exportToFiles')), ...
                    'Description', '', ...
                    'Icon', exportDataIcon, ...
                    'Help', [], ...
                    'Header', false);
                
                items(3) = struct(...
                    'Title', getString(message('images:imageBatchProcessor:genrateFunction')), ...
                    'Description', '', ...
                    'Icon', exportFunctionIcon, ...
                    'Help', [], ...
                    'Header', false);
            end
            
            
            % Add listener for each option
            addlistener(tool.ExportButton.Popup, 'ListItemSelected',...
                @tool.exportSplitButtonCallback);
            
            
            exportPanel.add(tool.ExportButton,'xy(2,1)');
        end
        
        function exportSplitButtonCallback(tool, src, ~)
            switch (src.SelectedIndex)
                case 1
                    tool.exportResultsToWorkspaceUI();
                case 2
                    tool.exportResultsToFilesUI();
                case 3
                    tool.generateFunctionUI();
            end
        end
    end
    
    %% Images
    methods (Access=private)
        
        function refreshimageStripAndAppState(tool)
            % Create or refresh input image list and input image view
            if(isempty(tool.imageStrip))
                % Create                                
                tool.createBatchThumbnailsAndInputImageFigures();
                tool.imageStrip = iptui.internal.batchProcessor.BatchThumbnails(tool.hBatchThumbnails);
                tool.hBatchThumbnails.WindowButtonDownFcn  = @(varargin)tool.imageStrip.mouseButtonDownFcn(varargin{1}, varargin{2});
                tool.hBatchThumbnails.WindowScrollWheelFcn = @(varargin)tool.imageStrip.mouseWheelFcn(varargin{1}, varargin{2});
                tool.hBatchThumbnails.WindowKeyPressFcn    = @(varargin)tool.imageStrip.keyPressFcn(varargin{1}, varargin{2});
                
                addlistener(tool.imageStrip,'SelectionChange',@tool.imageStripClicked);
                
                % Default layout can now be enabled
                tool.DefaultLayoutButton.Enabled = true;
            end
            
            % Clean up old results if any
            tool.cleanUpTemporaryResults();                        
            % Folder to save results before they get exported
            tool.temporaryResultsFolder = tempname;
            tool.createDirOrDie(tool.temporaryResultsFolder);
            
            % Reset related state variables
            tool.resultsExistToExport = false;
            tool.unexportedResultsExist = false;
            
            loadedStatus = getString(message('images:imageBatchProcessor:MLoaded', ...
                num2str(tool.imageBatchDataStore.NumberOfImages)));
            iptui.internal.utilities.setStatusBarText(tool.GroupName, loadedStatus);
            
            % Reset progress bar
            tool.jProgressLabel.setText('');
            
            tool.ToolGroup.setWaiting(true);
            tool.imageStrip.setContent(tool.imageBatchDataStore);
            
            %
            if(~isempty(tool.batchProcessor))
                tool.batchProcessor.resetState();
            end
            
            % Restore to default layout
            tool.resutNamesToShowAsOutputImages = {};
            tool.resetToDefaultLayout();
            
            % Make the first 'selected' (and fire all related callbacks)
            tool.imageStripClicked();
            
            tool.ToolGroup.setWaiting(false);
        end
        function refreshStateOnFunctionChange(tool)
            if(~isempty(tool.imageStrip))
                % Reset image list and output folders.
                tool.refreshimageStripAndAppState();
            end
        end
        function imageStripClicked(tool, ~, ~)
            if(~isvalid(tool))
                return;
            end
            
            tool.selectedImgInds = tool.imageStrip.CurrentSelection;
            
            selectionStatus = getString(message('images:imageBatchProcessor:NofMSelected', ...
                num2str(numel(tool.selectedImgInds)), num2str(tool.imageBatchDataStore.NumberOfImages)));
            iptui.internal.utilities.setStatusBarText(tool.GroupName, selectionStatus);
            
            tool.updateAllFigures();
        end
        
        function createBatchThumbnailsAndInputImageFigures(tool)
            if isempty(tool.hBatchThumbnails)
                [~, leafFolder] = fileparts(tool.imageBatchDataStore.ReadLocation);
                tool.hBatchThumbnails = figure('NumberTitle', 'off',...
                    'Name', [leafFolder, filesep],...
                    'Color','w',...
                    'Visible','on',...
                    'Tag','BatchThumbnails',...
                    'IntegerHandle','off',...
                    'HandleVisibility','off',...
                    'CloseRequestFcn', [],...
                    'WindowKeyPressFcn',@(~,~)[]);
                tool.ToolGroup.addFigure(tool.hBatchThumbnails);
                tool.ToolGroup.getFiguresDropTargetHandler.unregisterInterest(tool.hBatchThumbnails);
            end
            
            if isempty(tool.hInputImage) || ~isvalid(tool.hInputImage)
                tool.hInputImage = figure('NumberTitle', 'off',...
                    'Name',getString(message('images:commonUIString:inputImage')),...
                    'Color','w',...
                    'Visible','on',...
                    'Tag','ImageView',...
                    'IntegerHandle','off',...
                    'HandleVisibility','off',...
                    'WindowKeyPressFcn',@(~,~)[]);
                tool.ToolGroup.addFigure(tool.hInputImage);
                tool.ToolGroup.getFiguresDropTargetHandler.unregisterInterest(tool.hInputImage);
            end
            
            drawnow; % ensure figures are created before trying to place them
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            md.setClientLocation(tool.hBatchThumbnails.Name, tool.GroupName, com.mathworks.widgets.desk.DTLocation.create(0));
            md.setClientLocation(tool.hInputImage.Name, tool.GroupName, com.mathworks.widgets.desk.DTLocation.create(1));
            md.setDocumentArrangement(tool.ToolGroup.Name, md.TILED, java.awt.Dimension(2,1));
            md.setDocumentColumnWidths(tool.ToolGroup.Name, [0.2, 0.8]); % values must add to 1
            
        end
        function createResultFigure(tool)
            tool.hResultDisplay = figure('NumberTitle', 'off',...
                'Name',getString(message('images:imageBatchProcessor:results')),...
                'Color','w',...
                'Visible','on',...
                'Tag','ResultsPanel',...
                'IntegerHandle','off',...
                'HandleVisibility','off',...
                'Units','char',...
                'WindowScrollWheelFcn',@tool.mouseScrollResultDisplay,...
                'WindowKeyPressFcn',@tool.keyboardScrollResultDisplay);
            
            % Use a persistent panel for the results. This ensures result
            % updates do not steal focus allowing for keyboard scrolling in
            % the image list without focus jumping to the result figure.
            tool.hResultDisplayPanel = uipanel('Parent', tool.hResultDisplay,...
                'BorderType','none',...
                'Title','',...
                'Units','Normalized',...
                'Position',[0 0 1 1],...
                'BackgroundColor',[1 1 1]);
            
            tool.ToolGroup.addFigure(tool.hResultDisplay);
            tool.ToolGroup.getFiguresDropTargetHandler.unregisterInterest(tool.hResultDisplay);
                                    
            % Position result to the right
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            md.setClientLocation(tool.hBatchThumbnails.Name, tool.GroupName, com.mathworks.widgets.desk.DTLocation.create(0));
            
            %TODO - might not exist!
            md.setClientLocation(tool.hInputImage.Name, tool.GroupName, com.mathworks.widgets.desk.DTLocation.create(1));
            
            md.setClientLocation(tool.hResultDisplay.Name, tool.GroupName, com.mathworks.widgets.desk.DTLocation.create(2));
            md.setDocumentArrangement(tool.ToolGroup.Name, md.TILED, java.awt.Dimension(3,1));
            md.setDocumentColumnWidths(tool.ToolGroup.Name, [0.2, 0.6, 0.2]); % values must add to 1
        end
        function hFig = createOutputImageFigure(tool,resultName)
            hFig = figure('NumberTitle', 'off',...
                'Name',resultName,...
                'Color','w',...
                'Visible','on',...
                'Tag','OutputImageView',...
                'IntegerHandle','off',...
                'HandleVisibility','off',...
                'CloseRequestFcn',@tool.removeResultImageOnClose,...
                'WindowKeyPressFcn',@(~,~)[]);
            
            tool.ToolGroup.addFigure(hFig);
            tool.ToolGroup.getFiguresDropTargetHandler.unregisterInterest(hFig);
                        
            % Reset zoom pan
            tool.ZoomOutButton.Selected = false;
            tool.ZoomInButton.Selected  = false;
            tool.PanButton.Selected     = false;
            
            
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            if isempty(tool.hOutputImages)
                % Create tile under input image                
                % 
                % Find input image location
                %   Split that horizontally into upper and lower
                %   Place input on top and hFig on bottom.
                % If input image is closed, create a new full column
                % location
                
                % Workaround -
                md.setDocumentArrangement(tool.ToolGroup.Name, md.TILED, java.awt.Dimension(3,2));
                md.setDocumentRowSpan(tool.ToolGroup.Name, 0,0,2);
                md.setDocumentRowSpan(tool.ToolGroup.Name, 0,2,2);
                md.setDocumentColumnWidths(tool.ToolGroup.Name, [0.2, 0.6, 0.2]); % values must add to 1
                
                md.setClientLocation(tool.hBatchThumbnails.Name, tool.GroupName, com.mathworks.widgets.desk.DTLocation.create(0));
                md.setClientLocation(tool.hInputImage.Name, tool.GroupName, com.mathworks.widgets.desk.DTLocation.create(1));                
                if ~isempty(tool.hResultDisplay) && isvalid(tool.hResultDisplay)
                    md.setClientLocation(tool.hResultDisplay.Name, tool.GroupName, com.mathworks.widgets.desk.DTLocation.create(2));
                end
                md.setClientLocation(hFig.Name, tool.GroupName, com.mathworks.widgets.desk.DTLocation.create(3));
                
            else                
                % 
                % Add new figure as a tab to the same tile that has the
                % last output image
                %                
                
                % Add as tab with the last output image
                lastOutPutImageTile = md.getClientLocation(tool.hOutputImages(end).Name);
                newTile = com.mathworks.widgets.desk.DTLocation.create(lastOutPutImageTile.getTile());
                
                % Needed to ensure figures doesnt go into results tab
                drawnow;
                
                md.setClientLocation(hFig.Name, tool.GroupName, newTile);
            end
            
            tool.hOutputImages(end+1) = hFig;
        end
        function removeResultImageOnClose(tool,hFig, ~)
            resultName = hFig.Name;
            delete(hFig);
            
            if(~isvalid(tool))
                % App closed
                return;
            end
            
            % Remove handle
            for hind = 1:numel(tool.hOutputImages)
                if ~isvalid(tool.hOutputImages(hind))
                    % hFig in 'invalid' in this collection now
                    tool.hOutputImages(hind) = [];
                    break;
                end
            end
            % Remove from list
            tool.resutNamesToShowAsOutputImages(strcmp(tool.resutNamesToShowAsOutputImages, resultName)) = [];
        end
        
        function updateAllFigures(tool)
            % Remove any previous exception displays
            delete(tool.hExceptionDisplay);
            
            tool.updateInputImage();
            tool.updateResultFigure();
            tool.updateAllOutputImages();            
            tool.updateImageAxisLinking();
        end
        
        function updateImageAxisLinking(tool)
            if tool.LinkAxesButton.Selected
                % Link
                option = 'xy';
            else
                option = 'off';
            end
            
            haxes = matlab.graphics.axis.Axes.empty();
            
            for hFig = [tool.hInputImage, tool.hOutputImages]
                if isvalid(hFig)
                    drawnow; drawnow;
                    hax = findobj(hFig,'Type','Axes');
                    if ~isempty(hax) && isvalid(hax)
                        haxes(end+1) = hax; 
                    end
                end
            end
            
            if(~isempty(haxes))
                try
                    linkaxes(haxes ,option);
                catch ALL %#ok<NASGU>
                    % temporary invalid handles some times (fast
                    % scrolling)
                end
            end
        end
        
        
        
        function updateInputImage(tool)
            if(isvalid(tool.hInputImage))
                clf(tool.hInputImage);
                try
                    % If multiple selected, show only first
                    if(isempty(tool.selectedImgInds))
                        return;
                    end
                    imgInd = tool.selectedImgInds(1);

                    [~, fileName, ext] = fileparts(tool.imageBatchDataStore.getInputImageName(imgInd));
                    iptui.internal.imshowWithCaption(tool.hInputImage, ...
                        tool.imageBatchDataStore.read(imgInd),...
                        [fileName, ext], ...
                        'im');
                    
                    tool.enableZoomPan();
                catch ALL
                    tool.disableZoomPan();
                    clf(tool.hInputImage);
                    tool.hExceptionDisplay =...
                        iptui.internal.batchProcessor.ExceptionDisplay(tool.hInputImage, ALL);
                end
            end
        end
        function disableZoomPan(tool)
            tool.ZoomInButton.Enabled   = false;
            tool.ZoomOutButton.Enabled  = false;
            tool.PanButton.Enabled      = false;
            tool.LinkAxesButton.Enabled = false;
        end
        function enableZoomPan(tool)
            tool.ZoomInButton.Enabled   = true;
            tool.ZoomOutButton.Enabled  = true;
            tool.PanButton.Enabled      = true;
            tool.LinkAxesButton.Enabled = true;
        end
        
        
        function updateResultFigure(tool)
            if ~isempty(tool.hResultDisplay) && ~isvalid(tool.hResultDisplay)
                % Results tab was manually closed or has not been created
                return;
            end
                        
            if(isempty(tool.selectedImgInds))
                return;
            end
            
            % If multiple selected, show only first
            imgInd = tool.selectedImgInds(1);
            
            isImageProcessed = ~isempty(tool.batchProcessor) ...
                && tool.batchProcessor.visited(imgInd);
            
            if(isempty(tool.hResultDisplay) && ~isImageProcessed)
                % Dont create a result tab, nothing to show yet.
                return;
            end
            
            tool.resetResultPanel();
            
            if  isImageProcessed
                % Create if needed
                if(isempty(tool.hResultDisplay))
                    tool.createResultFigure();
                end
                
                try
                    if(tool.batchProcessor.errored(imgInd))
                        if isempty(tool.hExceptionDisplay) || ~isvalid(tool.hExceptionDisplay)
                            % No existing exception shown about bad input image
                            tool.hExceptionDisplay = ...
                                iptui.internal.batchProcessor.ExceptionDisplay(tool.hResultDisplayPanel,...
                                tool.batchProcessor.getException(imgInd));
                        end
                    else
                        tool.showResults(imgInd);
                        % Set resize call back after populating (to prevent multiple
                        % calls)
                        tool.hResultDisplay.SizeChangedFcn = @(varargin)tool.updateResultFigure();                       
                    end
                catch ALL
                    if isempty(tool.hExceptionDisplay) || ~isvalid(tool.hExceptionDisplay)
                        % No existing exception shown about bad input image
                        tool.hExceptionDisplay = ...
                            iptui.internal.batchProcessor.ExceptionDisplay(tool.hResultDisplayPanel, ALL);
                    end
                end
            else
                % Issue place holder
                uicontrol('Style','text',...
                    'Parent', tool.hResultDisplayPanel,...
                    'BackgroundColor',[1 1 1],...
                    'Units', 'Normalized',...
                    'Tag','resultPanelNotProcessedPlaceHolder',...
                    'Position', [ 0 .5 1 .25],...
                    'String', getString(message('images:imageBatchProcessor:notProcessed')));
                % Set resize call back after populating (to prevent multiple
                % calls)
                tool.hResultDisplay.SizeChangedFcn = @(varargin)tool.updateResultFigure();
            end
            
        end
        function resetResultPanel(tool)
            % Note - panel, not figure. Using this panel is a workaround to
            % prevent the Result figure from stealing focus from the image
            % list while scrolling.
            
            if isempty(tool.hResultDisplayPanel) || ~isvalid(tool.hResultDisplayPanel)
                return;
            end
            
            % Turn off resize callbacks while populating content
            tool.hResultDisplay.SizeChangedFcn = [];
            
            % Clear contents
            for hc = allchild(tool.hResultDisplayPanel)
                delete(hc);
            end
            if ~isempty(tool.hResultsVerticalSlider) && isvalid(tool.hResultsVerticalSlider)
                % Remember scroll position
                tool.hResultsVerticalSliderPersistentValue = tool.hResultsVerticalSlider.Value;
                delete(tool.hResultsVerticalSlider);
            end
            
            % Reset size and location
            tool.hResultDisplayPanel.Units = 'Normalized';
            tool.hResultDisplayPanel.Position = [0 0 1 1];
        end
        
        function showResults(tool, imgInd)
            hPanel = tool.hResultDisplayPanel;
            hPanel.Units = 'char';
            
            resultSummaries = tool.imageBatchDataStore.resultSummary(imgInd);
            
            hPanel.Position(4) = 0;
            layoutTop          = 0;
            fullWidth          = max(hPanel.Position(3),1);
            
            sliderWidth  = 3; % char
            tsizePix  = tool.imageBatchDataStore.THUMBNAILSIZE;
            tsizeChar = hgconvertunits(tool.hResultDisplay, [0 0 tsizePix tsizePix],'pixels','char',0);
            
            resultNames = fieldnames(resultSummaries);
            
            % Layout rows of results bottom up
            for ind = numel(resultNames):-1:1
                resultName = resultNames{ind};
                resultSummary = resultSummaries.(resultName);
                
                if iptui.internal.batchProcessor.isImage(resultSummary)
                    % Thumbnail
                    heightWithSpacing =  tsizeChar(4);
                    hPanel.Position(4) = hPanel.Position(4)+heightWithSpacing;
                    
                    haxes= axes('Parent', hPanel,...
                        'Units','char',...
                        'XTick',[],'YTick',[],...
                        'Tag', ['resultThumnbnailAxesFor_', resultName],...
                        'Position',[4, layoutTop, tsizeChar(3), tsizeChar(4)]);
                    himage = imshow(resultSummary,...
                        'Parent',haxes,...
                        'InitialMagnification','fit');
                    himage.UserData.Name = resultName;
                    himage.ButtonDownFcn = @tool.showThisResultImageIfThumbnailIsDoubleClicked;
                    layoutTop = hPanel.Position(4);
                else
                    % Text display
                    ht = uicontrol('Style','text',...
                        'HorizontalAlignment', 'left',...
                        'Units','char',...
                        'BackgroundColor','white',...
                        'String',resultSummary,...
                        'Parent', hPanel,...
                        'Tag', ['resultTextSummaryFor_', resultName],...
                        'Position',[ 0 0 fullWidth-sliderWidth, 1],...
                        'Visible','off');
                    
                    wrappedText = textwrap(ht,{deblank(resultSummary)});
                    numLines    = size(wrappedText,1);
                    
                    heightWithSpacing = .5 + numLines*1.5;
                    hPanel.Position(4) = hPanel.Position(4)+heightWithSpacing;
                    
                    ht.Position = [4, layoutTop, fullWidth-sliderWidth, numLines*1.5 ];
                    ht.Visible = 'on';
                    layoutTop = hPanel.Position(4);
                end
                
                % Label
                heightWithSpacing = .5+1.5; %char
                hPanel.Position(4) = hPanel.Position(4)+heightWithSpacing;
                
                uicontrol('Style','text',...
                    'HorizontalAlignment', 'left',...
                    'Units','char',...
                    'String',[' ' resultName],...
                    'Tag', resultName,...
                    'Parent', hPanel,...
                    'Position',[0, layoutTop, fullWidth, 1.5]);
                if iptui.internal.batchProcessor.isImage(resultSummary)
                    % Add 'show' button'
                    % Thumbnail show button
                    % Position accounting for potential scroll bar
                    uicontrol('Style','pushbutton',...
                        'String',getString(message('images:imageBatchProcessor:show')),...
                        'Tag',resultName,...
                        'Units','char',...
                        'Callback', @(varargin)tool.showThisResultImage(resultName),...
                        'Parent', hPanel,...
                        'Tag', ['resultThumbnailShowButtonFor_', resultName],...
                        'Tooltip',getString(message('images:imageBatchProcessor:showToolTip')),...
                        'Position',[fullWidth-8-sliderWidth-.5, layoutTop, 8, 1.5]);
                end
                
                layoutTop = hPanel.Position(4);
            end
            
            % Reposition panel to be flush to top of parent
            hPanel.Position(2) = -(hPanel.Position(4)-hPanel.Parent.Position(4));
            
            
            if hPanel.Position(4)>hPanel.Parent.Position(4)
                % Slider needed (Parent expected to be in 'char')
                
                numExtraCharLines  = (hPanel.Position(4)-hPanel.Parent.Position(4));
                
                sliderPos = tool.hResultDisplay.Position;
                sliderPos(1) = sliderPos(3)-sliderWidth;
                sliderPos(3) = sliderWidth; %
                
                sliderStep = [.1 1];
                
                % Remembered value or top
                initValue = min(tool.hResultsVerticalSliderPersistentValue,numExtraCharLines);
                
                tool.hResultsVerticalSlider = uicontrol('Style','Slider',...
                    'Parent', tool.hResultDisplay,...
                    'Units','char',...
                    'Max', numExtraCharLines,...
                    'Tag','resultPaneScrollBar',...
                    'Value', initValue,...
                    'Callback',@tool.scrollResultPane,...
                    'SliderStep', sliderStep,...
                    'Position', sliderPos);
                
                % Scroll to remembered value or top.
                tool.scrollResultPane();
                
            end
        end
        function scrollResultPane(tool, varargin)
            curPos    = tool.hResultDisplayPanel.Position;
            curPos(2) = -tool.hResultsVerticalSlider.Value;
            tool.hResultDisplayPanel.Position = curPos;
        end
        function mouseScrollResultDisplay(tool, ~, hEvent)
            if ~isempty(tool.hResultsVerticalSlider) && isvalid(tool.hResultsVerticalSlider)
                % Scrolling makes sense
                scrollAmount = ...
                    tool.hResultsVerticalSlider.Value - hEvent.VerticalScrollCount;
                scrollAmount = max(scrollAmount, 0);
                scrollAmount = min(scrollAmount, tool.hResultsVerticalSlider.Max);
                tool.hResultsVerticalSlider.Value = scrollAmount;
                tool.scrollResultPane();
            end
        end
        function keyboardScrollResultDisplay(tool, ~, hEvent)
            if ~isempty(tool.hResultsVerticalSlider) && isvalid(tool.hResultsVerticalSlider)
                % Scrolling makes sense
                switch hEvent.Key
                    case 'downarrow'
                        scrollAmount = -1;
                    case 'uparrow'
                        scrollAmount =  1;
                    case 'pageup'
                        scrollAmount =  5;
                    case 'pagedown'
                        scrollAmount = -5;
                    case 'home'
                        scrollAmount =  Inf;
                    case 'end'
                        scrollAmount = -Inf;
                    otherwise
                        % No action
                        return;
                end
                
                scrollTo =...
                    tool.hResultsVerticalSlider.Value + scrollAmount;
                scrollTo = max(scrollTo, 0);
                scrollTo = min(scrollTo, tool.hResultsVerticalSlider.Max);
                tool.hResultsVerticalSlider.Value = scrollTo;
                tool.scrollResultPane();
            end
        end
        
        function showThisResultImageIfThumbnailIsDoubleClicked(tool, varargin)
            hfig = ancestor(varargin{1},'Figure');
            if(strcmp(hfig.SelectionType,'open'))
                % If double click
                tool.showThisResultImage(varargin{1}.UserData.Name);
            end
        end
        
        
        function updateAllOutputImages(tool)
            % If multiple selected, use only first
            if(isempty(tool.selectedImgInds))
                return;
            end
            imgInd = tool.selectedImgInds(1);
            
            for ind=1:numel(tool.resutNamesToShowAsOutputImages)
                resultName = tool.resutNamesToShowAsOutputImages{ind};
                hFig = [];
                for hind = 1:numel(tool.hOutputImages)
                    if(strcmp(tool.hOutputImages(hind).Name, resultName))
                        hFig = tool.hOutputImages(hind);
                    end
                end
                
                if isempty(hFig)
                    hFig = tool.createOutputImageFigure(resultName);
                else
                    clf(hFig);
                end
                
                try
                    if(tool.batchProcessor.visited(imgInd))
                        iptui.internal.imshowWithCaption(hFig, ...
                            tool.imageBatchDataStore.loadOneResultField(imgInd, resultName),...
                            resultName, ...
                            [resultName num2str(imgInd)]);
                    else
                        % Not processed
                        uicontrol('Style','text',...
                            'Parent', hFig,...
                            'BackgroundColor',[1 1 1],...
                            'Units', 'Normalized',...
                            'Tag','imageNotProcessedText',...
                            'Position', [ 0 .5 1 .25],...
                            'String', getString(message('images:imageBatchProcessor:outputNotAvailable')));
                    end
                catch ALL %#ok<NASGU>
                    if ~isempty(tool.hExceptionDisplay) && isvalid(tool.hExceptionDisplay)
                        messageString = ''; % prior error already shown.
                    else
                        messageString = getString(message('images:imageBatchProcessor:unableToDisplayOutputImage'));
                    end
                    uicontrol('Style','text',...
                        'Parent', hFig,...
                        'BackgroundColor',[1 1 1],...
                        'Units', 'Normalized',...
                        'Position', [ 0 .5 1 .25],...
                        'Tag','unableToDisplayImageText',...
                        'String', messageString);
                end
                
            end
            
        end
        
    end
    
    %% Export
    methods (Access=private)
        function exportResultsToWorkspaceUI(tool)
            %% UI
            hd = dialog('Visible','off',...
                'Name',getString(message('images:imageBatchProcessor:exportToWorkSpace')),...
                'Units','char');
            
            width =  50;
            hd.Position(3) = width;
            
            % Grow dynamically in height, while populating bottom-up
            hd.Position(4) = .5;
            layoutTop      = .5;
            
            % OK - Cancel
            hd.Position(4) = hd.Position(4)+2.5;
            buttonWidths = 10;
            uicontrol('Style','pushbutton',...
                'Parent', hd,...
                'Units','char',...
                'Callback', @exportResultsToWorkspace,...
                'Position',[width-2*buttonWidths-2 layoutTop buttonWidths 2],...
                'Tag', 'exportToWSOK',...
                'String',getString(message('images:commonUIString:ok')));
            uicontrol('Style','pushbutton',...
                'Parent', hd,...
                'Units','char',...
                'Callback',@(varargin)delete(hd),...
                'Position',[width-buttonWidths-1 layoutTop buttonWidths 2],...
                'Tag', 'exportToWSCancel',...
                'String',getString(message('images:commonUIString:cancel')));
            layoutTop = hd.Position(4);
            
            
            % Variable name
            hd.Position(4) = hd.Position(4)+1.5;
            hVarName = uicontrol('Style','edit',...
                'Parent', hd,...
                'Units','char',...
                'HorizontalAlignment','left',...
                'Position',[1 layoutTop width-2 1.5],...
                'Tag', 'exportToWSVariableName',...
                'String','allresults');
            layoutTop = hd.Position(4);
            
            hd.Position(4) = hd.Position(4)+1.5;
            uicontrol('Style','text',...
                'Parent', hd,...
                'Units','char',...
                'HorizontalAlignment','left',...
                'Position',[1 layoutTop width-2 1.5],...
                'String',getString(message('images:imageBatchProcessor:enterVariableName')));
            hd.Position(4) = hd.Position(4)+.5;
            layoutTop = hd.Position(4);
            
            % Choose format (table/struct array)
            subWidth     = width-2;
            hButtonGroup = uibuttongroup('Parent', hd,...
                'Units','char',...
                'Position', [1 layoutTop subWidth 2],...
                'Tag', 'exportToWSTableOrStructButtonGroup',...
                'Title', getString(message('images:imageBatchProcessor:chooseExportVariableType')));
            hd.Position(4) = hd.Position(4)+2;
            
            subWidth = subWidth-2;
            
            heightPerEntry = 1.2;
            hd.Position(4) = hd.Position(4)+heightPerEntry;
            hButtonGroup.Position(4) = hButtonGroup.Position(4)+heightPerEntry;
            
            uicontrol('Style','Radio',...
                'Parent', hButtonGroup,...
                'Units','char',...
                'String',getString(message('images:commonUIString:table')),...
                'Tag', 'exportToWSTableRadioButton',...
                'Position', [1 .5 subWidth/2 heightPerEntry]);
            uicontrol('Style','Radio',...
                'Parent', hButtonGroup,...
                'Units','char',...
                'Tag', 'exportToWSStructArrayRadioButton',...
                'String',getString(message('images:commonUIString:structArray')),...
                'Position', [1+subWidth/2 .5 subWidth/2 heightPerEntry]);
            hd.Position(4) = hd.Position(4)+.5;
            layoutTop = hd.Position(4);
            
            
            % The 'Choose fields panel'
            subWidth     = width-2;
            hFieldsPanel = uipanel('Parent', hd,...
                'Units','char',...
                'Position', [1 layoutTop subWidth 2],...
                'Tag', 'exportToWSFieldsPanel',...
                'Title', getString(message('images:imageBatchProcessor:chooseFieldsToExport')));
            hd.Position(4) = hd.Position(4)+2;
            
            subLayoutTop = .5;
            heightPerEntry = 1.2;
            
            % Include file name
            hd.Position(4) = hd.Position(4)+heightPerEntry;
            hFieldsPanel.Position(4) = hFieldsPanel.Position(4)+heightPerEntry;
            hFileNameCheckBox = uicontrol('style','checkbox',...
                'Parent', hFieldsPanel,...
                'Units','Char',...
                'Value', tool.fileNameFieldSelected,...
                'String',getString(message('images:imageBatchProcessor:includeInputFileName')),...
                'Tag', 'exportToWSFieldCheckBox_fileName',...
                'Position',[1 subLayoutTop subWidth-1 heightPerEntry]);
            
            %  Fields and checkboxes
            resultSummaries = tool.imageBatchDataStore.resultSummary(tool.lastProcessedInd);
            fields = fieldnames(resultSummaries);
            subLayoutTop = subLayoutTop +1.2+.5;
            hcboxes = matlab.ui.control.UIControl.empty();
            for ind=numel(fields):-1:1
                hd.Position(4) = hd.Position(4)+heightPerEntry;
                hFieldsPanel.Position(4) = hFieldsPanel.Position(4)+heightPerEntry;
                
                hcboxes(ind) = uicontrol('style','checkbox',...
                    'Parent', hFieldsPanel,...
                    'Units','Char',...
                    'String',fields{ind},...
                    'Tag', ['exportToWSFieldCheckBox_' fields{ind}],...
                    'Position',[1 subLayoutTop subWidth-1 heightPerEntry]);
                if(any(strcmp(fields{ind}, tool.fieldsSelectedForWS)))
                    % memory
                    hcboxes(ind).Value = 1;
                end
                
                % Spacing
                hd.Position(4) = hd.Position(4)+.2;
                hFieldsPanel.Position(4) = hFieldsPanel.Position(4)+.2;
                subLayoutTop = subLayoutTop+heightPerEntry+.2;
            end
            
            % Top margin
            hd.Position(4) = hd.Position(4)+.5;
            
            hd.Units = 'pixels'; % needed for API below
            hd.Position = imageslib.internal.apputil.ScreenUtilities.getModalDialogPos(...
                tool.GroupName, hd.Position(3:4));
            hd.Visible = 'on';
            
            %% Callback
            function exportResultsToWorkspace(varargin)
                % Save selected fields
                selectedInds  = [hcboxes.Value];
                allFieldNames = {hcboxes.String};
                
                if(~any(selectedInds) && hFileNameCheckBox.Value~=1)
                    % nothing selected, flash as warning
                    [hcboxes.Visible, hFileNameCheckBox.Visible] = deal('off');
                    pause(.1);
                    [hcboxes.Visible, hFileNameCheckBox.Visible] = deal('on');
                    return;
                end
                
                tool.fieldsSelectedForWS = allFieldNames(selectedInds==1);
                
                tool.fileNameFieldSelected = hFileNameCheckBox.Value==1;
                resultToExport = tool.imageBatchDataStore.loadAllResults(...
                    tool.fieldsSelectedForWS,tool.fileNameFieldSelected);
                
                if(strcmp(hButtonGroup.SelectedObject.Tag,'exportToWSTableRadioButton'))
                    resultToExport = struct2table(resultToExport,...
                        'AsArray',true);
                end
                
                if(~isvarname(hVarName.String))
                    errordlg(getString(message('MATLAB:uistring:export2wsdlg:NotValidMATLABVariableNamesOneVariables', hVarName.String)),...
                        getString(message('MATLAB:uistring:export2wsdlg:InvalidVariableName')),...
                        'modal');
                    return;
                end
                
                assignin('base',hVarName.String, resultToExport);
                evalin('base',['disp(', hVarName.String,')']);
                                
                tool.unexportedResultsExist = false;
                
                delete(hd);
            end
        end
        
        function exportResultsToFilesUI(tool)
            %% UI
            hd = dialog('Visible','off',...
                'Name',getString(message('images:imageBatchProcessor:exportToFiles')),...
                'Units','char');
            
            width =  50;
            hd.Position(3) = width;
            
            % Grow dynamically in height, while populating bottom-up
            hd.Position(4) = .5;
            layoutTop      = .5;
            
            % OK - Cancel
            hd.Position(4) = hd.Position(4)+2.5;
            buttonWidths = 10;
            uicontrol('Style','pushbutton',...
                'Parent', hd,...
                'Units','char',...
                'Callback', @exportResultsToFiles,...
                'Position',[width-2*buttonWidths-2 layoutTop buttonWidths 2],...
                'Tag', 'exportToFilesOK',...
                'String',getString(message('images:commonUIString:ok')));
            uicontrol('Style','pushbutton',...
                'Parent', hd,...
                'Units','char',...
                'Callback',@(varargin)delete(hd),...
                'Position',[width-buttonWidths-1 layoutTop buttonWidths 2],...
                'Tag', 'exportToFilesCancel',...
                'String',getString(message('images:commonUIString:cancel')));
            layoutTop = hd.Position(4);
            
            
            % Outputdir name
            hd.Position(4) = hd.Position(4)+1.5;
            hDirName = uicontrol('Style','edit',...
                'Parent', hd,...
                'Units','char',...
                'HorizontalAlignment','left',...
                'Tag', 'exportToFilesOutPutDirName',...
                'Position',[1 layoutTop width-2-10 1.5],...
                'String',pwd);
            uicontrol('Style','pushbutton',...
                'Parent', hd,...
                'Units','char',...
                'HorizontalAlignment','left',...
                'Tag', 'exportToFilesOutPutDirBrowseButton',...
                'Callback',@browseForOutputDir,...
                'Position',[width-2-10+1 layoutTop 10 1.5],...
                'String',getString(message('images:commonUIString:browse')));
            layoutTop = hd.Position(4);
            % Label
            hd.Position(4) = hd.Position(4)+1.5;
            uicontrol('Style','text',...
                'Parent', hd,...
                'Units','char',...
                'HorizontalAlignment','left',...
                'Position',[1 layoutTop width-2 1.5],...
                'String',getString(message('images:imageBatchProcessor:enterOutputDirName')));
            hd.Position(4) = hd.Position(4)+.5;
            layoutTop = hd.Position(4);
            function browseForOutputDir(varargin)
                % Brose and set output dir
                dirName = uigetdir(pwd,...
                    getString(message('images:imageBatchProcessor:pickOutputDirName')));
                if(dirName~=0)
                    hDirName.String = dirName;
                end
            end
            
            
            % The 'Choose fields panel'
            subWidth     = width-2;
            hFieldsPanel = uipanel('Parent', hd,...
                'Units','char',...
                'Position', [1 layoutTop subWidth 2],...
                'Title', getString(message('images:imageBatchProcessor:chooseFieldsAndFormats')));
            hd.Position(4) = hd.Position(4)+2;
            
            % Image fields and dropdowns
            resultSummaries = tool.imageBatchDataStore.resultSummary(tool.lastProcessedInd);
            fields = fieldnames(resultSummaries);
            subLayoutTop = .5;
            
            registeredFormats = imformats;
            writeEnabled = cellfun(@(x)~isempty(x), {registeredFormats.write});
            registeredExtentions = [{''}, registeredFormats(writeEnabled).ext];
            % these need maps
            registeredExtentions(strcmp(registeredExtentions,'xwd'))=[];
            registeredExtentions(strcmp(registeredExtentions,'pcx'))=[];
            % add dicom
            registeredExtentions{end+1} = 'dcm';
            
            hf = matlab.ui.control.UIControl.empty();
            ht = matlab.ui.control.UIControl.empty();
            for ind=1:numel(fields)
                
                if ~iptui.internal.batchProcessor.isImage(resultSummaries.(fields{ind}))
                    % Skip non-image results
                    continue;
                end
                
                heightPerEntry = 1.5;
                hd.Position(4) = hd.Position(4)+heightPerEntry;
                hFieldsPanel.Position(4) = hFieldsPanel.Position(4)+heightPerEntry;
                
                secondColWidth = 12;
                hf(end+1) = uicontrol('style','popup',...
                    'Parent', hFieldsPanel,...
                    'Units','Char',...
                    'Tag', ['exportToFilesOutFormatDropDownFor_' fields{ind}],...
                    'String',registeredExtentions,...
                    'Value', 1,...
                    'Position',[1+subWidth-secondColWidth-2 subLayoutTop secondColWidth heightPerEntry]); 
                
                % memory
                for mind = 1:numel(tool.fieldsSelectedForFile)
                    if(strcmp(fields{ind}, tool.fieldsSelectedForFile{mind}{1}))
                        hf(end).Value = ...
                            find(strcmp(registeredExtentions, tool.fieldsSelectedForFile{mind}{2}));
                    end
                end
                
                ht(end+1) = uicontrol('style','text',...
                    'Parent', hFieldsPanel,...
                    'HorizontalAlignment','left',...
                    'Units','Char',...
                    'String',fields{ind},...
                    'Position',[1 subLayoutTop subWidth-secondColWidth-2 heightPerEntry]);
                
                % Spacing
                hd.Position(4) = hd.Position(4)+.5;
                hFieldsPanel.Position(4) = hFieldsPanel.Position(4)+.5;
                subLayoutTop = subLayoutTop+heightPerEntry+.5;
            end
            
            %  Select All/Clear Selection
            hd.Position(4) = hd.Position(4)+1;
            
            % Top margin
            hd.Position(4) = hd.Position(4)+.5;
            hd.Units = 'pixels'; % needed for API below
            hd.Position = imageslib.internal.apputil.ScreenUtilities.getModalDialogPos(...
                tool.GroupName, hd.Position(3:4));
            hd.Visible = 'on';
            
            %% Callback
            function exportResultsToFiles(varargin)
                % Save selected fields
                tool.fieldsSelectedForFile = {};

                if all([hf.Value]==1)
                    % All set to blank, warn by flashing dropdowns
                    [hf.Visible] = deal('off');
                    pause(.1);
                    [hf.Visible] = deal('on');
                    return;
                end

                for k = 1:numel(hf)
                    if(hf(k).Value~=1) % 1 is set to blank, i.e ignore.
                        % Save field and format
                        tool.fieldsSelectedForFile{end+1} = ...
                            {ht(k).String, hf(k).String{hf(k).Value}};
                    end
                end
                
                failed = tool.imageBatchDataStore.copyAllResultsToFiles(...
                    hDirName.String ,...
                    tool.fieldsSelectedForFile,...
                    tool.batchProcessor.UseParallel);
                if(failed)
                    warndlg(...
                        getString(message('images:imageBatchProcessor:failedToExportAllToFilesName')),...
                        getString(message('images:imageBatchProcessor:failedToExportAllToFilesMessage')));
                    % Show the logs in the command window;
                   commandwindow; 
                else
                    tool.unexportedResultsExist = false;
                end                                
                
                delete(hd);
            end
        end
        
        function generateFunctionUI(tool)
            %% UI
            hd = dialog('Visible','off',...
                'Name',getString(message('images:imageBatchProcessor:genrateFunction')),...
                'Units','char');
            
            width =  80;
            hd.Position(3) = width;
            
            % Grow dynamically in height, while populating bottom-up
            hd.Position(4) = .5;
            layoutTop      = .5;
            
            % OK - Cancel
            hd.Position(4) = hd.Position(4)+2.5;
            buttonWidths = 10;
            uicontrol('Style','pushbutton',...
                'Parent', hd,...
                'Units','char',...
                'Callback', @generateCode,...
                'Position',[width-2*buttonWidths-2 layoutTop buttonWidths 2],...
                'Tag', 'exportToFilesOK',...
                'String',getString(message('images:commonUIString:ok')));
            uicontrol('Style','pushbutton',...
                'Parent', hd,...
                'Units','char',...
                'Callback',@(varargin)delete(hd),...
                'Position',[width-buttonWidths-1 layoutTop buttonWidths 2],...
                'Tag', 'exportToFilesCancel',...
                'String',getString(message('images:commonUIString:cancel')));
            layoutTop = hd.Position(4);
            
            
            % The 'Configure fields panel'
            subWidth     = width-2; % panel
            hFieldsPanel = uipanel('Parent', hd,...
                'Units','char',...
                'Position', [1 layoutTop subWidth 2],...
                'Title', getString(message('images:imageBatchProcessor:assignFieldsTo')));
            hd.Position(4) = hd.Position(4)+2;
            
            subLayoutTop = .5;
            heightPerEntry = 1.5;
            subWidth     = subWidth-5; % 1 pixel spacing between columns
            
            % Image fields and dropdowns
            resultSummaries = tool.imageBatchDataStore.resultSummary(tool.lastProcessedInd);
            fields = fieldnames(resultSummaries);
            
            registeredFormats = imformats;
            writeEnabled = cellfun(@(x)~isempty(x), {registeredFormats.write});
            % No '', all outputs should either be written or returned to ws
            registeredExtentions = [registeredFormats(writeEnabled).ext];
            % xwd needs a map
            registeredExtentions(strcmp(registeredExtentions,'xwd'))=[];
            
            ht  = matlab.ui.control.UIControl.empty();
            hbg = matlab.ui.control.UIControl.empty();
            hf  = matlab.ui.control.UIControl.empty();
            for ind=1:numel(fields)
                hd.Position(4) = hd.Position(4)+heightPerEntry;
                hFieldsPanel.Position(4) = hFieldsPanel.Position(4)+heightPerEntry;
                
                ht(end+1) = uicontrol('style','text',...
                    'Parent', hFieldsPanel,...
                    'HorizontalAlignment','left',...
                    'Units','Char',...
                    'String',fields{ind},...
                    'Position',[1 subLayoutTop subWidth/4 heightPerEntry]);
                
                hf(end+1) = uicontrol('style','popup',...
                    'Parent', hFieldsPanel,...
                    'Units','Char',...
                    'Tag', ['exportToFilesOutFormatDropDownFor_' fields{ind}],...
                    'String',registeredExtentions,...
                    'Value', 1,...
                    'Position',[3*subWidth/4+2 subLayoutTop subWidth/4 heightPerEntry]);
                
                hbg(end+1) = uibuttongroup('Parent', hFieldsPanel,...
                    'Units', 'char',...
                    'Position',[1*subWidth/4+1 subLayoutTop 2*(subWidth/4) heightPerEntry]);
                uicontrol('Style','Radio',...
                    'Parent',hbg(end),...
                    'Units','char',...
                    'UserData', struct('toWS',true,'name', fields{ind}),...
                    'Position',[subWidth/4/2-1 0 4 heightPerEntry],...
                    'Callback',@(varargin)enableDisableFormatDropDown(hf(end), 'off'),...
                    'Tag',['generateFunctionRadioToResult_' fields{ind}]);
                uicontrol('Style','Radio',...
                    'Parent',hbg(end),...
                    'Units','char',...
                    'UserData', struct('toWS',false,'name', fields{ind}),...
                    'Position',[subWidth/4+subWidth/4/2-1 0 4 heightPerEntry],...
                    'Callback',@(varargin)enableDisableFormatDropDown(hf(end), 'on'),...
                    'Tag',['generateFunctionRadioToOutDir_' fields{ind}]);
                
                
                if iptui.internal.batchProcessor.isImage(resultSummaries.(fields{ind}))
                    % To outDir/file
                    hbg(end).Children(1).Value = true;
                    % Default to tif
                    hf(end).Value = find(strcmp(hf(end).String,'tiff'));
                else
                    % To result/ws
                    hbg(end).Children(2).Value = true;
                    hbg(end).Children(1).Enable = 'off';
                    hbg(end).Children(2).Enable = 'off';
                    hf(end).Value = 1;
                    hf(end).String = {''};
                    hf(end).Enable = 'off';
                end
                
                % Spacing
                hd.Position(4) = hd.Position(4)+.5;
                hFieldsPanel.Position(4) = hFieldsPanel.Position(4)+.5;
                subLayoutTop = subLayoutTop+heightPerEntry+.5;
            end
            
            function enableDisableFormatDropDown(hf, enableDisable)
                % Disable format dropdown if field is going to the output.
                hf.Enable = enableDisable;
            end
            
            % Headers
            hd.Position(4) = hd.Position(4)+2.5;
            hFieldsPanel.Position(4) = hFieldsPanel.Position(4)+2.5;
            hTitle1 = uicontrol('Style','text',...
                'HorizontalAlignment','left',...
                'Parent', hFieldsPanel,...
                'Units', 'char',...
                'Position',[1 subLayoutTop subWidth/4 heightPerEntry],...
                'String',getString(message('images:commonUIString:field')));
            hTitle2 = uicontrol('Style','text',...
                'HorizontalAlignment','center',...
                'Parent', hFieldsPanel,...
                'Units', 'char',...
                'Position',[1*subWidth/4+1 subLayoutTop subWidth/4 heightPerEntry],...
                'String',getString(message('images:imageBatchProcessor:assignTo')));
            hTitle3 = uicontrol('Style','text',...
                'HorizontalAlignment','center',...
                'Parent', hFieldsPanel,...
                'Units', 'char',...
                'Position',[2*subWidth/4+1 subLayoutTop subWidth/4 heightPerEntry],...
                'String',getString(message('images:imageBatchProcessor:sendTo')));
            hTitle4 = uicontrol('Style','text',...
                'HorizontalAlignment','right',...
                'Parent', hFieldsPanel,...
                'Units', 'char',...
                'Position',[3*subWidth/4+1 subLayoutTop subWidth/4 heightPerEntry],...
                'String',getString(message('images:imageBatchProcessor:format')));
            
            maxTitleWidth = max([hTitle1.Extent(3),...
                                        hTitle2.Extent(3),...
                                        hTitle3.Extent(3),...
                                        hTitle4.Extent(3)]);
            
            % If maxTitleWidth is greater than width of the textbox, the
            % title will get wraped. So we need to increate the height of
            % the text.
            if(maxTitleWidth > subWidth/4)
                
                numLines = ceil(maxTitleWidth/(subWidth/4));

                hTitle1.Position(4) = (heightPerEntry-0.5)*numLines + 0.5; % subtract the extra buffer in heightPerEntry
                hTitle2.Position(4) = (heightPerEntry-0.5)*numLines + 0.5; % subtract the extra buffer in heightPerEntry
                hTitle3.Position(4) = (heightPerEntry-0.5)*numLines + 0.5; % subtract the extra buffer in heightPerEntry
                hTitle4.Position(4) = (heightPerEntry-0.5)*numLines + 0.5; % subtract the extra buffer in heightPerEntry
                
                hd.Position(4) = hd.Position(4)+heightPerEntry*numLines;
                hFieldsPanel.Position(4) = hFieldsPanel.Position(4)+heightPerEntry*numLines;
            end

            
            hd.Position(4) = hd.Position(4)+.5;
            
            % Choose format (table/struct array)
            layoutTop = hd.Position(4);
            subWidth     = width-2;
            hButtonGroup = uibuttongroup('Parent', hd,...
                'Units','char',...
                'Position', [1 layoutTop subWidth 2],...
                'Tag', 'exportToWSTableOrStructButtonGroup',...
                'Title', getString(message('images:imageBatchProcessor:chooseResultType','results')));
            hd.Position(4) = hd.Position(4)+2;
            
            subWidth = subWidth-2;
            
            heightPerEntry = 1.2;
            hd.Position(4) = hd.Position(4)+heightPerEntry;
            hButtonGroup.Position(4) = hButtonGroup.Position(4)+heightPerEntry;
            
            uicontrol('Style','Radio',...
                'Parent', hButtonGroup,...
                'Units','char',...
                'String',getString(message('images:commonUIString:table')),...
                'Tag', 'generateCodeTableRadioButton',...
                'Position', [1 .5 subWidth/2 heightPerEntry]);
            uicontrol('Style','Radio',...
                'Parent', hButtonGroup,...
                'Units','char',...
                'Tag', 'generateCodeStructArrayRadioButton',...
                'String',getString(message('images:commonUIString:structArray')),...
                'Position', [1+subWidth/2 .5 subWidth/2 heightPerEntry]);
            
            hd.Position(4) = hd.Position(4)+.5;
            
            
            % Function signature information
            layoutTop = hd.Position(4);
            subWidth     = width-2;
            hSignaturePanel = uipanel('Parent', hd,...
                'Units','char',...
                'Position', [1 layoutTop subWidth 2],...
                'Title','');
            hd.Position(4) = hd.Position(4)+2;
            subWidth = subWidth-2;
            ht = uicontrol('Style','text',...
                'Horizontalalignment','left',...
                'Parent',hSignaturePanel,...
                'Units','char',...
                'Position',[1 .5 subWidth 4],...
                'String', '');
            wrappedText = textwrap(ht, ...
                {getString(message('images:imageBatchProcessor:generatedFunctionSignature'))});
            numLines    = size(wrappedText,1);
            hd.Position(4) = hd.Position(4)+numLines*1.5;
            hSignaturePanel.Position(4) = hSignaturePanel.Position(4)+numLines*1.5;
            ht.Position(4) = numLines*1.5;
            ht.String = wrappedText;
            
            
            
            % Top margin
            hd.Position(4) = hd.Position(4)+.5;
            hd.Units = 'pixels'; % needed for API below
            hd.Position = imageslib.internal.apputil.ScreenUtilities.getModalDialogPos(...
                tool.GroupName, hd.Position(3:4));
            hd.Visible = 'on';
            
            %% Callback
            function generateCode(varargin)
                
                codeGenerator = iptui.internal.CodeGenerator();
                templateFile = fullfile(matlabroot, 'toolbox','images',...
                    'imuitools','+iptui','+internal','+batchProcessor',...
                    'generatedBatchFunction.template');
                codeString = fileread(templateFile);
                
                % <FUNCTIONCALL>
                %    oneResult = <FUNCTION>(im);
                % or
                %    oneResult.result = <FUNCTION>(im);
                resultSummaries = tool.imageBatchDataStore.resultSummary(tool.lastProcessedInd);
                fields = fieldnames(resultSummaries);
                functionCallStr = 'oneResult = <FUNCTION>(im);';
                if numel(fields)==1 && strcmp(fields,'output')
                    % assume its the special one output syntax (for
                    % backwards compatability) 
                    functionCallStr = 'oneResult = struct();oneResult.output = <FUNCTION>(im);';
                end
                
                codeString = strrep(codeString,'<FUNCTIONCALL>',functionCallStr);
                
                % <FUNCTION>
                % Update template with current state
                codeString = strrep(codeString,'<FUNCTION>',tool.batchFunctionName);
                               
                % Input directory
                inDir = tool.imageBatchDataStore.ReadLocation;
                inDir = strrep(inDir,'''','''''');
                codeString = strrep(codeString,'<DEFAULTINPUT>',inDir);
                if(tool.imageBatchDataStore.IncludeSubdirectories)
                    codeString = strrep(codeString, '<INCLUDESUBDIRECTORIES>','true');
                else
                    codeString = strrep(codeString, '<INCLUDESUBDIRECTORIES>','false');
                end
                                
                tool.fieldsSelectedForWS   = {};
                tool.fieldsSelectedForFile = {};    
                selectedRadioButtons = [hbg(:).SelectedObject];
                for rind = 1:numel(selectedRadioButtons)
                    if(selectedRadioButtons(rind).UserData.toWS)
                        tool.fieldsSelectedForWS{end+1} = ...
                            selectedRadioButtons(rind).UserData.name;
                    else
                        tool.fieldsSelectedForFile{end+1} = ...
                            {selectedRadioButtons(rind).UserData.name,...
                            hf(rind).String{hf(rind).Value}
                            };
                    end
                end
                
                % <COMMENT_WORKSPACEFIELDS>
                wsFieldsComent = sprintf('%%    %s\n', tool.fieldsSelectedForWS{:});
                codeString = strrep(codeString, '<COMMENT_WORKSPACEFIELDS>',wsFieldsComent);
                
                % <WORKSPACEFIELDS>
                wsFieldsCode = sprintf('''%s'',', tool.fieldsSelectedForWS{:});
                if(~isempty(wsFieldsCode))
                    wsFieldsCode(end)=[];
                end
                codeString = strrep(codeString, '<WORKSPACEFIELDS>',wsFieldsCode);
                
                % <COMMENT_FILEFIELDSWITHFORMAT>
                fileFieldsComment = '';
                for ffind = 1:numel(tool.fieldsSelectedForFile)
                    fileFieldsComment = [fileFieldsComment, ...
                        '%    ',tool.fieldsSelectedForFile{ffind}{1},' saved as ', tool.fieldsSelectedForFile{ffind}{2},' format']; %#ok<*AGROW>
                    fileFieldsComment = [fileFieldsComment, newline];
                end
                if(~isempty(fileFieldsComment))
                    fileFieldsComment(end) = [];
                end
                codeString = strrep(codeString, '<COMMENT_FILEFIELDSWITHFORMAT>',fileFieldsComment);                
                
                % <FILEFIELDSWITHFORMAT>
                fileFieldsCode = '';
                for ffind = 1:numel(tool.fieldsSelectedForFile)
                    fileFieldsCode = [fileFieldsCode, ...
                        '{''',tool.fieldsSelectedForFile{ffind}{1},''', ''', tool.fieldsSelectedForFile{ffind}{2},'''}']; %#ok<*AGROW>
                    fileFieldsCode = [fileFieldsCode, newline];
                end
                if(~isempty(fileFieldsCode))
                    fileFieldsCode(end) = [];
                end
                                
                codeString = strrep(codeString, '<FILEFIELDSWITHFORMAT>',fileFieldsCode);
                
                if(tool.ProcessInParallelToggle.Selected)
                    codeString = strrep(codeString, '<FOR>','parfor');
                else
                    codeString = strrep(codeString, '<FOR>','for');
                end
                
                codeString = strrep(codeString, '<DATE>',date);                
                
                if strcmp(hButtonGroup.SelectedObject.Tag,'generateCodeTableRadioButton')
                    % Table
                    codeString = strrep(codeString, '<TABLEORSTRUCTARRAY>','table');
                    codeString = strrep(codeString, '<STRUCT2TABLEIFNEEDED>','result = struct2table(result,''AsArray'',true);');
                else
                    % Struct array
                    codeString = strrep(codeString, '<TABLEORSTRUCTARRAY>','struct array');
                    codeString = strrep(codeString, '<STRUCT2TABLEIFNEEDED>','');
                end
                
                codeGenerator.addLineWithoutWhitespace(codeString);
                codeGenerator.putCodeInEditor();
                delete(hd);
            end
        end
        
    end
    
    %% UI State control
    methods (Access=private)
        function setState(tool, state)
            switch state
                case 'notReady'
                    tool.LoadButton.Enabled                      = true;
                    tool.BatchFunctionNameComboBox.Enabled       = true;
                    tool.BatchFunctionBrowseButton.Enabled       = true;
                    tool.BatchFunctionOpenInEditorButton.Enabled = false;
                    tool.BatchFunctionCreateButton.Enabled       = true;
                    tool.ProcessInParallelToggle.Enabled         = false;
                    tool.ProcessStopButton.Enabled               = false;
                    tool.ZoomInButton.Enabled                    = false;
                    tool.ZoomOutButton.Enabled                   = false;
                    tool.PanButton.Enabled                       = false;
                    tool.LinkAxesButton.Enabled                  = false;
                    tool.ExportButton.Enabled                    = false;
                case 'ready'
                    tool.LoadButton.Enabled                      = true;
                    tool.BatchFunctionNameComboBox.Enabled       = true;
                    tool.BatchFunctionBrowseButton.Enabled       = true;
                    tool.BatchFunctionOpenInEditorButton.Enabled = true;
                    tool.BatchFunctionCreateButton.Enabled       = true;
                    tool.ProcessInParallelToggle.Enabled         = true;
                    tool.ProcessStopButton.Enabled               = true;
                    tool.ZoomInButton.Enabled                    = true;
                    tool.ZoomOutButton.Enabled                   = true;
                    tool.PanButton.Enabled                       = true;
                    tool.LinkAxesButton.Enabled                  = true;
                    tool.DefaultLayoutButton.Enabled             = true;
                    tool.ExportButton.Enabled                    = tool.resultsExistToExport;
                    
                    tool.changeToProcessButton();
                    
                case 'processing'
                    tool.LoadButton.Enabled                      = false;
                    tool.BatchFunctionNameComboBox.Enabled       = false;
                    tool.BatchFunctionBrowseButton.Enabled       = false;
                    tool.BatchFunctionOpenInEditorButton.Enabled = false;
                    tool.BatchFunctionCreateButton.Enabled       = false;
                    tool.ProcessInParallelToggle.Enabled         = false;
                    tool.ProcessStopButton.Enabled               = true;
                    tool.DefaultLayoutButton.Enabled             = true;
                    tool.ExportButton.Enabled                    = false;
                    
                    tool.changeToStopButton();
                    
                case 'locked'
                    tool.LoadButton.Enabled                      = false;
                    tool.BatchFunctionNameComboBox.Enabled       = false;
                    tool.BatchFunctionBrowseButton.Enabled       = false;
                    tool.BatchFunctionOpenInEditorButton.Enabled = false;
                    tool.BatchFunctionCreateButton.Enabled       = false;
                    tool.ProcessInParallelToggle.Enabled         = false;
                    tool.ProcessStopButton.Enabled               = false;
                    tool.ZoomInButton.Enabled                    = false;
                    tool.ZoomOutButton.Enabled                   = false;
                    tool.PanButton.Enabled                       = false;
                    tool.LinkAxesButton.Enabled                  = false;
                    tool.DefaultLayoutButton.Enabled             = false;
                    tool.ExportButton.Enabled                    = false;
                    
                otherwise
                    assert(false,'unknown state requested');
            end
        end
        
        function setReadyIfPossible(tool)
            if ~isempty(tool.imageBatchDataStore) && ~isempty(tool.batchFunctionHandle)
                
                tool.batchProcessor = iptui.internal.batchProcessor.BatchProcessor(...
                    tool.imageBatchDataStore,tool.batchFunctionHandle);
                
                % wire up
                tool.batchProcessor.beginning = @tool.indicateImageBeginning;
                tool.batchProcessor.done      = @tool.indicateImageDone;
                tool.batchProcessor.cleanup   = @tool.cleanUp;
                tool.batchProcessor.checkIfStopRequested = @tool.checkIfStopRequested;
                
                tool.setState('ready');
            end
        end
    end
    
    %% Handle callback functions from the batchprocessor
    methods (Access=private)
        function indicateImageBeginning(tool, ~)
            tool.numberOfQueuedImages = tool.numberOfQueuedImages+1;
            tool.indicateProgress();
        end
        
        function indicateImageDone(tool, imgInd)
            
            if(~isvalid(tool))
                % Tool has closed
                return
            end
            
            if(~tool.batchProcessor.visited(imgInd))
                % 'done' was invoked before the output was visited, i.e
                % processing did not complete (potential dbquit midway),
                % clean up the status for this image.
                tool.cleanUp(imgInd);
                return;
            end
            
            if(tool.batchProcessor.errored(imgInd))
                tool.imageStrip.setFileState(imgInd,'errored');
                tool.numberOfErroredImages = tool.numberOfErroredImages+1;
            else
                tool.imageStrip.setFileState(imgInd,'done');
                tool.numberOfDoneImages = tool.numberOfDoneImages+1;
                tool.lastProcessedInd = imgInd;
            end
            
            if(~isempty(tool.selectedImgInds) &&...
                    imgInd == tool.selectedImgInds(1))
                % Update currently selected image immediately
                tool.updateAllFigures();
            end                        
            
            tool.indicateProgress();
        end
        
        function indicateProgress(tool)
            progressStateString = '';
            if(tool.ProcessInParallelToggle.Selected==true)
                progressStateString = [num2str(tool.numberOfQueuedImages) ' ',...
                    getString(message('images:imageBatchProcessor:queued')),...
                    '.'];
            end
            
            progressStateString = [progressStateString ' ' ,...
                num2str(tool.numberOfDoneImages),' ',...
                getString(message('images:imageBatchProcessor:doneOf')),...
                ' ',num2str(tool.numberOfTodoImages) '.'];
            
            if(tool.numberOfErroredImages~=0)
                progressStateString = [progressStateString ' ',...
                    num2str(tool.numberOfErroredImages),' ',...
                    getString(message('images:imageBatchProcessor:errored')),...
                    '.'];
            end
            
            tool.jProgressLabel.setText(progressStateString);
            % From 0 - 100%
            tool.jProgressBar.setValue(tool.numberOfDoneImages/tool.numberOfTodoImages*100);
        end
        
        function cleanUp(~, ~)
            % nothing to do
        end
        
        function stopnow = checkIfStopRequested(tool)
            % Give the stop button callback a chance
            drawnow;
            
            if(~isvalid(tool))
                % Tool has closed
                stopnow = true;
                return
            end
            
            stopnow = tool.stopRequested;
            if(stopnow)
                % Request will already be relayed to backend
                tool.stopRequested = false;
                tool.ProcessStopButton.Text = getString(message('images:imageBatchProcessor:stoppingButton'));
            end
        end
        
    end
    
end
