classdef SimulinkDataObjectIdentifier < fxptds.AbstractIdentifier
    % SIGNALOBJECTIDENTIFIER Class definition for simulink data object
    % identifiers. This class is super class for identifiers if bus object
    % prameter object and signal object. This is an abstract class.
    %
    % Command line syntax:
    %
    %     H = fxptds.SimulinkDataObjectIdentifier(<Simulink.Signal object>, <name of signal>);
    %     H = fxptds.SignalObjectIdentifier(<Simulink.Signal object>);

    % Copyright 2013-2017 The MathWorks, Inc.

    properties(SetAccess = protected)
        DataObjectWrapper;
        Name;
        ObjectName;
        ElementName;
    end

    properties(SetAccess = protected, GetAccess = public)
        % This ket defines the uniqueness of the object. The UniqueKey gives the
        % uniqueness of usage
        % [format] <objectClass>#<objectName>#<workspaceType>|<workspaceName>
        DataObjectUniqueKey;
    end
    
    methods(Static)
        function obj = loadobj(this)
            obj = this;
        end
    end
    methods
        function obj = saveobj(this)
            obj = this.copy;
        end
    end

    methods        
        function this = SimulinkDataObjectIdentifier(dataObjectWrapper, elementName)
            setDataObject(this, dataObjectWrapper);
            setName(this, dataObjectWrapper, elementName);
            setUniqueKeys(this);
        end

        function owner = getObject(this)
            % Returns the Signal object
            owner = this.DataObjectWrapper;
        end

        function b = isWithinProvidedScope(~, ~)
            % Signal objects are defined in workspaces or Data Dictionary. They
            % don't belong to any model. Trying to see where they are used in a
            % model can be expensive performance wise and might not be the best
            % solution.
            b = false;
        end


        function unhilite(~)
            % NO-OP
        end

        function hiliteInEditor(~)
            %NO-OP
        end

        function flag = isValid(this)
            % return true if the object is valid
            flag = isvalid(getObject(this));
        end

        function parent = getHighestLevelParent(~)
            % Gets the name of its parent.
            parent = [];
        end
        
        function elementName = getElementName(this)
            elementName = this.ElementName;
        end
        
        function displayName = getDisplayName(this, ~)
            objectName = this.ObjectName;
            elementName = this.ElementName;
            
            if strcmp(objectName, elementName)
                displayName = objectName;
            else
                displayName = [objectName ' : ' elementName];
            end
            
            % Returns the name to be displayed.
            if getWorkspaceEnumType(this) == SimulinkFixedPoint.AutoscalerVarSourceTypes.Model
                displayName = [displayName '(model)'];
            end
        end        
    end

    methods (Access = protected)
        function setDataObject(this, dataObject)
            this.DataObjectWrapper = dataObject;
        end
        
        function setObjectName(this, dataObjectWrapper)
            this.ObjectName = dataObjectWrapper.Name;
        end
        
        function setElementName(this, elementName)
            this.ElementName = elementName;
        end
        
        function setName(this, dataObjectWrapper, elementName)
            setObjectName(this, dataObjectWrapper);
            setElementName(this, elementName);
            fullName = this.ObjectName;
            if ~isempty(this.ElementName) && ~strcmp(this.ObjectName, this.ElementName)
                fullName = [fullName ':' this.ElementName];
            end
            this.Name = fullName;
        end

        function setUniqueKeys(this)
            % Construct the unique keys for data object (DataObjectUniqueKey) and its
            % usage (UniqueKey)
            this.DataObjectUniqueKey = calcDataObjectUniqueKey(this);
            this.UniqueKey   		 = calcUniqueKey(this);
        end
        
        function classOfDataObject = getClassOfDataObject(this)
            dataObjectWrapper = getObject(this);
            classOfDataObject = class(dataObjectWrapper.Object);
        end

        function key = calcDataObjectUniqueKey(this)
			% Returns a data object unique key
            key = [getClassOfDataObject(this) '#' this.Name  '#'  getWorkspaceInfo(this)];
        end

        function key = calcUniqueKey(this)            
            % Append the context used in to the DataObjectUniqueKey
            key = this.DataObjectUniqueKey;
            key = [key '#usedIn:' getDataObjectContext(this)];
            %NOTE: Folllow up geck g1474252
        end

        function workspaceInfo = getWorkspaceInfo(this)
            % workspaceInfo consists of the workspace type and name
            % Ex: model|<modelName>, base|global
            workspaceInfo = [getWorkspaceType(this) '|' getWorkspaceName(this)];
        end

        function workSpaceType = getWorkspaceType(this)
            % Get the string representation of workSpaceEnumType (of type
            % SimulinkFixedPoint.AutoscalerVarSourceTypes)
            workSpaceEnumType = getWorkspaceEnumType(this);
            workSpaceType = lower(char(workSpaceEnumType));
        end

        function workSpaceName = getWorkspaceName(this)
            % workSpaceName is as follows
            % base: global
            % model: <model name>
            % data dictionary: [format]<PathHex_<endoded path>_FileName_<data dictionary file name>>
            workSpaceEnumType = getWorkspaceEnumType(this);
            switch workSpaceEnumType
                case {SimulinkFixedPoint.AutoscalerVarSourceTypes.Base}
                    workSpaceName       = 'global';
                case {SimulinkFixedPoint.AutoscalerVarSourceTypes.Model}
                    workSpaceName       = getDataObjectContext(this);
                case {SimulinkFixedPoint.AutoscalerVarSourceTypes.DataDictionary}
                    workSpaceName       = fxptds.SimulinkDataObjectIdentifier.getDataDictionaryWorkspaceName(getDataObjectContext(this), this.ObjectName);
                otherwise
                    workSpaceName       = 'unknown';
            end
            % The case for mask is not possible till autoscaling support for mask
            % parameters is added
        end

        function context = getDataObjectContext(this)
            % The context is stored in SimulinkFixedPoint.NamedTypeHandle.
            % Hence, overrriding the method.
			context = this.DataObjectWrapper.ContextName;
        end

        function workSpaceEnumType = getWorkspaceEnumType(this)
            % The workSpaceEnumType is stored in SimulinkFixedPoint.NamedTypeHandle.
            % Hence, overrriding the method.
            workSpaceEnumType = this.DataObjectWrapper.WorkspaceType;
        end
    end

    methods (Static, Hidden)
        function dataSourceObject = getDataSource(context)
            % Simulink.data.DataSource.create returns the base work psace or a connection
            % to the data dictionary used in context
            dataSourceObject = Simulink.data.DataSource.create(context);
        end

        function dataDictionary = getDataDictionary(dataSourceObject)
            % Get the actual data dictionary from the connection to it
            dataDictionaryFullPath = dataSourceObject.DataSource.filespec;
            dataDictionary = Simulink.data.dictionary.open(dataDictionaryFullPath);
        end

        function workSpaceName = getDataDictionaryWorkspaceName(context, variableName)
            % Get the data dictionary
            dataSourceObject = fxptds.SimulinkDataObjectIdentifier.getDataSource(context);
            dataDictionary = fxptds.SimulinkDataObjectIdentifier.getDataDictionary(dataSourceObject);
            
            % Get the Design Data section of the data dictionary
            section = dataDictionary.getSection('Design Data');
            entry = section.getEntry(variableName);
            dataDictionaryFileName = entry.DataSource;
            
            % Get the filename and path of the data dictionary which is the source of
            % the entry (variableName)
            dataDictionary = Simulink.data.dictionary.open(dataDictionaryFileName);
            dataDictionaryFullPath = dataDictionary.filepath;
            [dataDictionaryPath, dataDictionaryFileName] = fileparts(dataDictionaryFullPath);
            
            % Encode the path and file name as workSpaceName
            encodedPath = fxptds.SimulinkDataObjectIdentifier.encodeDictionaryPath(dataDictionaryPath);
            workSpaceName = ['PathHex_' encodedPath '_FileName_' dataDictionaryFileName];
        end
        
        function encodedPath = encodeDictionaryPath(dataDictionaryPath)
            % Get encoded path from data dictionary path
            % Ex: 
            %
            % dataDictionaryPath = 'hello'
            % dataDictionaryFileName = 'myDD'
            %
            % concatenatedIndex = {'104'    '101'    '108'    '108'    '111'}
            % [concatenatedIndex{:}] = '104101108108111'
            % str2double([concatenatedIndex{:}]) = 1.041011081081110e+14
            % num2hex(str2double([concatenatedIndex{:}])) = '42d7ab7b6472d3c0'
            % workSpaceName = 'PathHex_42d7ab7b6472d3c0_FileName_myDD'
            concatenatedIndex = arrayfun(@(x) num2str(x), double(dataDictionaryPath), 'UniformOutput', false);
            encodedPath = num2hex(str2double([concatenatedIndex{:}]));
        end
    end
end

% LocalWords:  fxptautoscale
