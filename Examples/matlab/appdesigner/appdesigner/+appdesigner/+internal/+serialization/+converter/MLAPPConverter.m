classdef MLAPPConverter< handle
    %MLAPPCONVERTER A class to convert 18a and greater apps to 16b-17b.
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Access='private')
        DestinationFile   
        
        % Data is the data that needs to be written to the app file in the
        % older V1 format of using MCOS objects to store the data.  Some data 
        % needs to be converted, others can be written as is:  The data is:
        %     Metadata
        %     DestinationRelease
        %     UIFigure
        %     ScreenshotPath
        %     StartupCallback
        %     EditableSectionCode
        %     InputParameters
        %     Callbacks
        %     Groups
        Data
    end
    
    methods
        function obj = MLAPPConverter(destinationFile, data)
            obj.DestinationFile = destinationFile;
            obj.Data = data;
        end        
    end
    
    methods
        
        function convert(obj)
                       
            import appdesigner.internal.serialization.util.*;
            
            fileWriter =  appdesigner.internal.serialization.FileWriter(obj.DestinationFile);
            
            % write the matlab code text
           fileWriter.writeMATLABCodeText(obj.Data.UpdatedCode);
            
           if ( strcmp(obj.Data.DestinationRelease,'R2017b') )
               % write the full metadata to the file in 17b (Name,
               % summary, description, screensnapshot, etc) because it is
               % supported in that release
               metadata = obj.Data.Metadata;
               metadata.MATLABRelease = obj.Data.DestinationRelease;
               % make sure the MLAPPVersion is set to 1 and min release to
               % R2016a
               metadata.MLAPPVersion = '1';
               metadata.MinimumSupportedMATLABRelease = 'R2016a';
               fileWriter.writeAppMetadata(metadata);
               
               % write the screenshot only if not empty
               screenshotPath = obj.Data.ScreenshotPath;
               if ~isempty(screenshotPath)
                   try
                       fileWriter.writeAppScreenshot(screenshotPath);
                   catch ex
                       % The screenshot is not critical to the app file and so
                       % silently do nothing if writing the screenshot fails..
                   end
               end
           else
               metadata = struct();
               % otherwise write MATLABRelease and set MLAPPVersion to 1
               % and min release to
               % R2016a
               metadata.MLAPPVersion = '1';
               metadata.MinimumSupportedMATLABRelease = 'R2016a';
               metadata.MATLABRelease = obj.Data.DestinationRelease;
               fileWriter.writeAppMetadata(metadata);
           end
            
            % process the components
           obj.processComponents();
           
           % process the code
           codeData = obj.convertCodeData();
                      
            % create the appmetadata for groups
            appMetadata = appdesigner.internal.serialization.app.AppMetadata(obj.Data.Groups);
            
            % create the appData
            appData = appdesigner.internal.serialization.app.AppData(obj.Data.UIFigure,codeData,appMetadata);
            
            %  set ToolboxVer 
            % remove the "R" from the destinationRelease because it is not
            % expected in previous releases
            appData.ToolboxVer = extractAfter(obj.Data.DestinationRelease,'R');
            
            % By default, minimumSupportedVersion is set to 'R2016a'.
            % However, apps created in release R2016b has it set to R2016b 
            % so need to check for that and set it correctly
            if ( strcmp(obj.Data.DestinationRelease,'R2016b') )
                appData.MinimumSupportedVersion = 'R2016b';
            end
            
            % need to set FullVersion to empty because it will be incorrect
            % and we don't know what the correct value should be.  Its
            % better to leave empty...  our code never uses it anyways
            appData.FullVersion  = '';
            
            % write it out to the file
            fileWriter.writeAppDesignerDataVersion1(appData);
        end
        
            
        function processComponents(obj)
            
            % get the components and convert the DesignTimeProperties
            % structure to a class
            componentList = findall(obj.Data.UIFigure, '-property', 'DesignTimeProperties');
            for idx = length(componentList):-1:1
                childComponent = componentList(idx);
                % get the Design time properties
                dtp = childComponent.DesignTimeProperties;
                
                % create and add fields to a DesignTimeProperties object
                designTimeProperties = appdesigner.internal.model.DesignTimeProperties();
                designTimeProperties.CodeName = dtp.CodeName;
                designTimeProperties.GroupId = dtp.GroupId;
                designTimeProperties.ComponentCode = dtp.ComponentCode;
                
                % set this design time property object on the component
                childComponent.DesignTimeProperties = designTimeProperties;
                
                % if don't do this the font size is 8 when opening previous
                % releases
                if isa(childComponent,'matlab.ui.container.Panel')
                    childComponent.FontSizeMode = 'manual';
                    childComponent.FontNameMode = 'manual';
                end
                
                if isa(childComponent,'matlab.ui.control.Table')
                    childComponent.FontSizeMode = 'manual';
                    childComponent.FontNameMode = 'manual';
                end

            end
        end
        
        function codeData = convertCodeData(obj)
            % create a Version 1 codedata object
            codeData = appdesigner.internal.codegeneration.model.CodeData();
                        
            % 17a and 17b start off with configurable startup fcn as empty
            if ( strcmp(obj.Data.DestinationRelease,'R2017a') || strcmp(obj.Data.DestinationRelease,'R2017b'))
                codeData.ConfigurableStartupFcn = [];
            end
            
            % set the class name of the app to codedata
            [~,className] = fileparts(obj.DestinationFile);
            codeData.GeneratedClassName = className;
            
             % add a startupFcn to make app consistent as if it was created
             % in 16b-17b
            codeData.StartupFcn = appdesigner.internal.codegeneration.model.AppCallback();
            codeData.StartupFcn.Args = {'app'};
            codeData.StartupFcn.Type = 'AppStartupFcn';
            codeData.StartupFcn.Comment = getString(message('MATLAB:appdesigner:codegeneration:RunStartupFcnComment'));
            codeData.StartupFcn.Name = 'startupFcn';
            codeData.StartupFcn.ComponentData  = appdesigner.internal.codegeneration.model.CallbackComponentData.empty;
            codeData.StartupFcn.ReturnArgs = [];
                   
            % set startup Callback
            if ( ~isempty(obj.Data.StartupCallback))
                codeData.ConfigurableStartupFcn = appdesigner.internal.codegeneration.model.AppCallback();
                codeData.ConfigurableStartupFcn.Name = obj.Data.StartupCallback.Name;
                codeData.ConfigurableStartupFcn.Code = obj.Data.StartupCallback.Code;
                codeData.ConfigurableStartupFcn.ComponentData = [];
                codeData.ConfigurableStartupFcn.Type = 'AppStartupFunction'; 
                codeData.ConfigurableStartupFcn.Comment = getString(message('MATLAB:appdesigner:codegeneration:RunStartupFcnComment'));
                codeData.ConfigurableStartupFcn.Args = {'app'};
                codeData.ConfigurableStartupFcn.ReturnArgs = [];
                
                % set the StartupFcn's code
                codeData.StartupFcn.Code = codeData.ConfigurableStartupFcn.Code;
            end
            
            % set Editable Section
            if ( ~isempty(obj.Data.EditableSectionCode))
                codeData.EditableSection.Code = obj.Data.EditableSectionCode;
                codeData.EditableSection.Exist = true;               
            end
            
            % set input parameters
            if (  ~isempty(obj.Data.InputParameters))
                codeData.InputParameters = {obj.Data.InputParameters};
            end
            
            % restore the ComponentData to each callback  (CodeName,CallbackPropertyName,ComponentType)
            callbacks = appdesigner.internal.serialization.util.restoreCallbackComponentData(obj.Data.UIFigure,obj.Data.Callbacks);
            
            % get the list of valid component types for 16b, 17a
            validComponentTypes = appdesigner.internal.serialization.converter.getValidComponentTypesfor16b17a();
            
            % loop over all the callbacks and their componentDatas, and
            % only create a componentData if its valid for the release
            for i = 1:numel(callbacks)
                callback = callbacks(i);
                convertedCallback = appdesigner.internal.codegeneration.model.AppCallback();
                convertedCallback.Type = 'AppCallbackFunction';
                convertedCallback.Name = callback.Name;
                convertedCallback.Code = callback.Code;      
                
                % set extra callback info as if this app was created in
                % 16b-17b
                % args is a 2x1 cell array
                convertedCallback.Args = {'app', 'event'}';               
                convertedCallback.Comment = getString(message('MATLAB:appdesigner:codegeneration:mixedCallbackFcnComment'));
                convertedCallback.ReturnArgs = [];
                                
                componentData = appdesigner.internal.codegeneration.model.CallbackComponentData.empty;
                
                % get the list of componentDatas for the callback
                componentDatas = callback.ComponentData;
                for j=1:numel(componentDatas)
                    codeName = componentDatas(j).CodeName;
                    callbackPropertyName = componentDatas(j).CallbackPropertyName;
                    componentType = componentDatas(j).ComponentType;
                    % if the target release is 17b or if its a known component type for 16b, 17a,
                    % then add the CallbackComponentData object to the callback
                    if ( strcmp(obj.Data.DestinationRelease,'R2017b') && strcmp('matlab.ui.container.Menu',componentType)) ||...
                            (any(strcmp(validComponentTypes,componentType)))
                        componentData(end+1) = appdesigner.internal.codegeneration.model.CallbackComponentData(...
                            codeName,callbackPropertyName,componentType);
                    end
                end
                
                convertedCallback.ComponentData = componentData;
                codeData.Callbacks(i) = convertedCallback;
            end             
        end
        
    end
          
end
