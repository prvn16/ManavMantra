classdef MLAPPSerializer < handle
    %MLAPPSerializer This is a class that serializes the app's data
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        % Full file path of the app to be serialized
        FullFileName
        
        UIFigure
        
        % 1xN struct array with fields: Id, ParentGroupId
        Groups
        
        % Nx1 cell array
        EditableSectionCode
        
        % 1xN array struct array with fields: Name, Code
        Callbacks
        
        % struct with fields: Name, Code
        StartupCallback
        
        % the matlab code to run the app
        MatlabCodeText
        
        % metadata of the app
        Metadata
        
        % fullfile path to a screenshot image
        ScreenshotPath
        
        InputParameters
        
        MinSupportedRelease
    end
    
    methods
         function obj = MLAPPSerializer(fullFilename, uifigure)
             obj.FullFileName = fullFilename;
             obj.UIFigure = uifigure;              
             obj.MatlabCodeText = '';
             obj.MinSupportedRelease = 'R2018a';
         end
         
         function save(obj)     
             % This method saves the data of the app.  The data has been
             % set via its public properties
             
             import appdesigner.internal.serialization.util.ReleaseUtil
             
             % construct a fileWriter
              fileWriter =  appdesigner.internal.serialization.FileWriter(obj.FullFileName);
              
             % write the matlab code....  
             fileWriter.writeMATLABCodeText(obj.MatlabCodeText);
             
             % get the components structure
             componentsStructure = obj.getComponentsStructureToSave();
             
             % get the name of the app
              [~, name] = fileparts(obj.FullFileName); 
              codeStructure = obj.getCodeStructureToSave(name);
             
            % Because the format has changed in 18a, 18a apps and beyond can no longer
            % be opened in 17b or earlier unless they are converted to the earlier format.
            % For this reason, when opening an 18a app in a previous release, the previous
            % framework requires that an AppData object be created and its 
            % MinimumSupportedVersion property be set to 'R2018a'.  When this is 
            % done in AppData, the  "This app was created in a newer version of
            % App Designer and cannot be opened for editing" dialog will
            % be popped up when 18a+ apps are opened in 16b, 17a, 17b
            appData = appdesigner.internal.serialization.app.AppData([],[],[]);
            appData.MinimumSupportedVersion =  obj.MinSupportedRelease;
            
             % write the app Designer data
             fileWriter.writeAppDesignerData(componentsStructure,codeStructure,appData);
             
             if ( isempty(obj.Metadata))
                 obj.Metadata = struct();
             end
             
             obj.Metadata.MinimumSupportedMATLABRelease = obj.MinSupportedRelease;
             obj.Metadata.MLAPPVersion = '2';
             obj.Metadata.MATLABRelease = ReleaseUtil.getCurrentRelease;
             
             % write the metadata
             fileWriter.writeAppMetadata(obj.Metadata);
             
            % write the screenshot only if not empty
            if ~isempty(obj.ScreenshotPath)
                try
                    fileWriter.writeAppScreenshot(obj.ScreenshotPath);
                catch
                    % The screenshot is not critical to the app file and so
                    % silently do nothing if writing the screenshot fails.
                    % This may happen if tyring to write to a read-only app
                    % or the user has deleted the screenshot file before
                    % saving.
                end
            end
            
         end        
    end
    
    methods  (Access = private)
        function code = getCodeStructureToSave(obj,name)
             % create code struct
             code = struct();
             code.ClassName = name;
  
            if ( ~isempty(obj.EditableSectionCode))
                 code.EditableSectionCode = obj.EditableSectionCode;
             end
             
             if ( ~isempty(obj.Callbacks))
                 code.Callbacks = obj.Callbacks;
             end
              
             if ( ~isempty(obj.StartupCallback))
                code.StartupCallback = obj.StartupCallback;
             end 
             
             if ( ~isempty(obj.InputParameters))
                code.InputParameters = obj.InputParameters;
             end 
        end
        
        function componentsStruct = getComponentsStructureToSave(obj)
             % create a structure of component data: UIFigure,  Groups
             componentsStruct = struct();
             componentsStruct.UIFigure = obj.UIFigure;
             if( ~isempty(obj.Groups))
                 componentsStruct.Groups = obj.Groups;
             end            
        end
        
    end
end
