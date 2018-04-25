classdef PlotsTabUtils
    % A utility class for the MATLAB On The Web Plots Tab. This class gets
    % the plots information from java, formats the data and sends it to the
    % client. In addition it handles selection change events and
    % accordingly sends information about the plots enabled for that data
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    methods(Static = true, Access = 'protected')
        % Move the methods that call the Java Classes here so they can be
        % overridden in the Test Class
        
        function result = getSelectionNames(var, selectionString)
            if (isstruct(var) || matlab.internal.datatypes.istabular(var))
                result = strsplit(selectionString,';');
            else
                result{1} = selectionString;
            end
        end
        
        function map = getPlotsMap()
            map = com.mathworks.mlwidgets.array.web.PlotUtils.getPlotsMap();
        end
        
        function outputString = getCamelCase(tag)
            spaces = find(tag==' ');
            tag(spaces+1) = upper(tag(spaces+1));
            tag(tag==' ') = [];
            outputString = tag;
        end
        
        function outputTag = getFormattedTag(itemTag)
            itemTag = internal.matlab.plotstab.PlotsTabUtils.getCamelCase(char(itemTag));
            % if the tag name has a '.' in it we change it to '_'. This is done because
            % tag names are used as file names to uniquely identify plots.
            itemTag = strrep(itemTag,'.','_');
            outputTag = strcat('plots_',char(itemTag));
        end
        
        % The client expects either a 'selectionChanged' or 'executionStringsUpdated' event. So the server eventtype strings are
        % translated to match the event strings expected by the client
        % 'selectionChanged'       <- (selectionChanged,
        %                              variablesSwapped,
        %                              DataChange
        %                              DocumentFocusGained
        %                              ManagerFocusGained)
        % 'executionStringsUpdated' <- figureCreationChanged
        function translatedEvntType = translateEvntTypeString(eventType)
            if strcmp(eventType,'SelectionChanged') || strcmp(eventType,'variablesSwapped') ||...
                    strcmp(eventType,'DataChange') || strcmp(eventType,'DocumentFocusGained') || ...
                    strcmp(eventType, 'ManagerFocusGained') || strcmp(eventType, 'DocumentTypeChanged')
                translatedEvntType = 'selectionChanged';
            elseif strcmp(eventType, 'figureCreationChanged')
                translatedEvntType = 'executionStringsUpdated';
            end
        end
        
        % swap function specifically for a cell array of length 2
        function swappedResult = swap(selection)
            temp = selection{1};
            selection{1} = selection{2};
            selection{2} = temp;
            swappedResult = selection;
        end
        
        % Return the classType as sparse for sparse variables as class(data)
        % returns double instead of sparse.
        function classType = getClassType(data)
            if issparse(data)
                classType='sparse';
            else
                classType = class(data);
            end
        end
        
        % checks and returns if a particular plot action is enabled for a given selection combination
        function isEnabled = isValidPlotForSelection(selectedItem, selection)
            L = lasterror; %#ok<*LERR>
            isEnabled = false;
            try
                if isempty(com.mathworks.mlwidgets.array.web.PlotUtils.getSelectionMCode(selectedItem))
                    isEnabled = plotpickerfunc('defaultshow',char(com.mathworks.mlwidgets.array.web.PlotUtils.getID(selectedItem)),{},selection);
                else
                    selectionMcodeHandle = eval(com.mathworks.mlwidgets.array.web.PlotUtils.getSelectionMCode(selectedItem));
                    isEnabled = feval(selectionMcodeHandle, selection);
                end
            catch
                % Catch any errors to protect against toolboxes which might potentially
                % involve errors while evaluating Plot Actions
                
                % If any of the variables are tall, reset lasterror
                if any(cellfun(@(x) istall(x), selection))
                    lasterror(L);
                end
            end 
        end
        
        function result = hasCustomExecutionFunction(plotType)
            result = com.mathworks.mlwidgets.array.web.PlotUtils.hasCustomExecutionFunction(plotType);
        end
        
        function result = getCustomExecutionFunction(plotType, selectionNames)
            result = char(com.mathworks.mlwidgets.array.web.PlotUtils.getCustomExecutionStringEvaluator(plotType, selectionNames));
            % Always evaluate in the base workspace until we support 
            % private workspaces
            %result = evalin('base', result);
        end
        
        function result = getExecutionFunction(plotType, selectionNames, newFigureOption)
            result = char(com.mathworks.mlwidgets.array.web.PlotUtils.getExecutionString(plotType, selectionNames, newFigureOption));
        end
        
        function [execString, doEval] = getEvalString(plotType, selection, selectionNames, newFigureOption, isPrivateWorkspace)
            % execString must be '' for private workspaces
            execString = '';
            doEval = false;
            
            if internal.matlab.plotstab.PlotsTabUtils.isValidPlotForSelection(plotType, selection)
                if ~isPrivateWorkspace
                    if internal.matlab.plotstab.PlotsTabUtils.hasCustomExecutionFunction(plotType)
                        execString = internal.matlab.plotstab.PlotsTabUtils.getCustomExecutionFunction(plotType, selectionNames);
                        doEval = true;
                        % For custom execution functions, the 'figure;' codegen has to be manually added
%                         if newFigureOption
%                             execString = strcat('figure;',execString);
%                         end
                    else
                        % if the plot does not have a custom execution string then get the default
                        % execution string
                        execString = internal.matlab.plotstab.PlotsTabUtils.getExecutionFunction(plotType, selectionNames, newFigureOption);
                    end
                end
            end
        end
    end
    
    methods(Static = true)
        
        function selNames = getSelectionVarNamesForVariableEditor(selectionString)
            selNames = {};
            factory = internal.matlab.variableeditor.peer.PeerManagerFactory.getInstance();
            veManager = factory.createInstance('/VariableEditor', false);
            if ~isempty(veManager.FocusedDocument)
                selNames = internal.matlab.plotstab.PlotsTabUtils.getSelectionNames(veManager.FocusedDocument.DataModel.Data, selectionString);
            end
        end
        
        % Handles selection updates to which the plots gallery has to react. Uses the input selection
        % data to construct and publish to client an object, representing the plot items to be
        % displayed and their corresponding execution strings.
        % Format of published data object is
        % data.variables = <array of selected variables>,
        % data.items = <array of structs('tag',<plotAction>,'executionString',<executionString>)>
        function publishData = handleSelection(selection, selectionNames, eventType, isPrivateWorkspace)
            % selection is a cell array of selected values
            % selectionNames is a cell array of string representations of
            % those selected values
            isPrivateWorkspace = nargin>=4 && isPrivateWorkspace;
            map = internal.matlab.plotstab.PlotsTabUtils.getPlotsMap();
            plotsTabInstance = internal.matlab.plotstab.PlotsTabState.getInstance();
            structsWithTagAndExecStrings = {};
            newFigureOption = false;
            
            % server eventType strings are translated/converted to the match the eventType strings expected by the client
            eventTypeToPublish = internal.matlab.plotstab.PlotsTabUtils.translateEvntTypeString(eventType);
            publishData = struct('eventType',char(eventTypeToPublish));
            
            % cell array of selected variables
            varsSelectedArray = cell(1, length(selectionNames));
            if ~isempty(selectionNames)
                for v=1:length(selectionNames)
                    dataClass = internal.matlab.plotstab.PlotsTabUtils.getClassType(selection{v});
                    varsSelectedArray{v} = struct('text',selectionNames{v},'type',dataClass);
                end
            end
            % Case where a selection is made in the Workspace Browser or Variable Editor
            
            if ~isempty(selectionNames)
                
                % A string representation of all the categories as a cell array
                keySet = cell(map.keySet.toArray);
                % create a 'categories' structure array
                % size : number of categories = length(keySet), so we iterate
                % through each category
                for k = 1:length(keySet)
                    selectedItems = map.get(keySet{k});
                    % convert each item into a structure array                                        
                    
                    for j = 1:length(selectedItems)
                        
                        % if the product is installed but the user does not
                        % have a license, the items returns will be empty
                        % so we should ignore them
                        if isempty(selectedItems(j))
                            continue;
                        end
                        
                        itemTag = internal.matlab.plotstab.PlotsTabUtils.getFormattedTag(selectedItems(j));
                        if ~com.mathworks.mlwidgets.array.web.PlotUtils.isGUI(selectedItems(j))
                            newFigureOption = plotsTabInstance.createNewFig;
                        end
                        
                        % TODO: The code below sets the executing strings
                        % to empty for private workspaces, since without
                        % workspace variables to represent the selected
                        % data it is impossible to generate meaningful
                        % execution strings. To enable this feature, the
                        % Plot Gallery must be equipped with the ability
                        % to create plots from the actual selected data
                        % rather than relying on the execution strings
                        evalSelection = selection;                        
                        

                        % Return the string and whether or not it needs to
                        % be evaluated here. 
                        [execString, doEval] = internal.matlab.plotstab.PlotsTabUtils.getEvalString(selectedItems(j), evalSelection,...
                            selectionNames, newFigureOption, isPrivateWorkspace);                        
                        
                        if doEval
                            execString = evalin('caller', execString);
                            if newFigureOption
                                execString = strcat('figure;',execString);
                            end
                            
                        end
                        
                        if ~isempty(execString)
                            structsWithTagAndExecStrings{end+1} = struct('tag', itemTag,'executionString', execString);
                        end
                        
                    end
                end
                publishData.items = structsWithTagAndExecStrings;
                % No data selected
            else
                % takes care of the case where no variable is selected and the plots tab should be reverted to the initial state
                publishData.items = cell(1,0);
            end
            
            if ~strcmp(eventType, 'executionStringsUpdated')
                publishData.variables = varsSelectedArray;
            end
            
            message.publish('/PlotsChannel', publishData);
        end
        
    end
end



