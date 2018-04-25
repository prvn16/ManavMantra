classdef Version1Loader < appdesigner.internal.serialization.loader.interface.Loader
    %VERSION1LOADER  A class to load older apps (16a-17b), and some 18a
    %apps that were created before the serialization change
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        FileReader
    end
    
    methods
        
        function obj = Version1Loader(fileReader)
            obj.FileReader = fileReader;
        end
        
        function appData = load(obj)
            % read the app designer data using the FileReader
            appData = obj.FileReader.readAppDesignerData();
            
            % convert the data to the new format
            appData = obj.convertToCurrentFormat(appData);
        end
    end
    
    methods(Access='private')
        
        function appData = convertToCurrentFormat(~,olderAppData)
            % converts the older format data to the new format
            
            % return a struct of data
            appData = struct();
            
            % update the components with a structure of design-time data
            componentList = findall(olderAppData.appData.UIFigure, '-property', 'DesignTimeProperties');
            % save all the component Code Names for Callback processing
            % below
            componentCodeNames = cell(size(componentList,1), 1);
            for i = 1:length(componentList)
                childComponent = componentList(i);
                % get the Design time properties MCOS object
                dtp = childComponent.DesignTimeProperties;
                
                % create and add fields to a structure
                designTimeProperties = struct();
                designTimeProperties.CodeName = dtp.CodeName;
                componentCodeNames{i} =  dtp.CodeName;
                designTimeProperties.GroupId = dtp.GroupId;
                designTimeProperties.ComponentCode = dtp.ComponentCode;
                
                % set this design time property structure on the component
                childComponent.DesignTimeProperties = designTimeProperties;
            end
            
            % set the UIFigure oand groups on the struct
            appData.components.UIFigure = olderAppData.appData.UIFigure;
            appData.components.Groups =   olderAppData.appData.Metadata.GroupHierarchy;
            
            % create a CodeData structure
            codeDataObj = olderAppData.appData.CodeData;
            codeDataStruct = struct();
            codeDataStruct.ClassName = codeDataObj.GeneratedClassName;
            codeDataStruct.EditableSectionCode = codeDataObj.EditableSection.Code;
            
            % Version 1 apps had InputParams in a cell array
            if ( ~isempty(codeDataObj.InputParameters))
                codeDataStruct.InputParameters = codeDataObj.InputParameters{1};
            else
                codeDataStruct.InputParameters = '';
            end
            
            % create a struct array for callbacks
            cbdata = struct.empty;
            callbacks = codeDataObj.Callbacks;
            codeDataStruct.Callbacks = [];
            for i=1:length(callbacks)
                callback = callbacks(i);
                cbdata(i).Name = callback.Name;
                cbdata(i).Code = callback.Code;
                cbdata(i).ComponentData = struct('CodeName', {}, ...
                    'CallbackPropertyName', {}, 'ComponentType', {});
                % recreate ComponentDatas as a struct
                componentDatas = callback.ComponentData;
                for  j=1:length(componentDatas)
                    cd = componentDatas(j);
                    % find the component this callback is associated with
                    componentIdx = find(strcmp(cd.CodeName, componentCodeNames));
                    if (numel(componentIdx) == 1 && ... check that the component exists
                            isprop(componentList(componentIdx), cd.CallbackPropertyName) && ...
                            ... check that the component's property points to this callback
                            strcmp(get(componentList(componentIdx), cd.CallbackPropertyName), callback.Name))
                        cbdata(i).ComponentData(end+1).CodeName = cd.CodeName;
                        cbdata(i).ComponentData(end).CallbackPropertyName = cd.CallbackPropertyName;
                        cbdata(i).ComponentData(end).ComponentType = cd.ComponentType;
                    end
                end
            end
            % if there are callbacks add them to the codeDataStruct
            % otherwise this field should be empty
            if (~isempty(cbdata))
                codeDataStruct.Callbacks = cbdata;
            end
            
            % startupFcn
            startupFcn = [];
            if ~isempty(codeDataObj.ConfigurableStartupFcn)
                startupFcn.Name = codeDataObj.ConfigurableStartupFcn.Name;
                startupFcn.Code = codeDataObj.ConfigurableStartupFcn.Code;
                % set the componentData to be empty so that it has a
                % similar structure to callbacks
                startupFcn.ComponentData = struct( ...
                    'CodeName', {}, ...
                    'CallbackPropertyName', {}, ...
                    'ComponentType', {});
            end
            codeDataStruct.StartupFcn = startupFcn;
            
            % set the code Data
            appData.code = codeDataStruct;
            
        end
    end
end
