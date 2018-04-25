classdef AppCallback < handle
    
    %AppCallback a class to hold callback data from code generation
    
    % Copyright 2015-2016 The MathWorks, Inc.
    properties
        % the Callback's Name
        Name
        
        % a cell array of code content for the callback
        Code
       
        % the type of callback this is.  Types are 'AppCallbackFunction' or
        % 'AppStartupFunction'
        Type
        
        % an array of associated component data for this callback
        % of type
        % 'appdesigner.internal.codegeneration.model.CallbackComponentData'
        ComponentData
        
        % a cell array of arguments for the callback
        Args
    end
    
    properties
        % properties maintained for compatibility
        
        % the Callback's Comment
        Comment
        
        % a cell array of return arguments from the callback
        ReturnArgs
    end
    
    properties(Transient, Hidden)
        % an temporary identifier for the callback
        CallbackId
    end
    
    methods
        function obj = AppCallback(callbackId)
            % constructor
            % constructor
            if nargin > 0
                obj.CallbackId = callbackId;
            end
            % initialize array to empty
            obj.ComponentData = appdesigner.internal.codegeneration.model.CallbackComponentData.empty;
        end
    end
    
    methods(Static, Hidden)
        
        %------------------------------------------------------------------
        
        function obj = loadobj(loadedObj)
            % handles loading the AppCallback Object from a MAT file. This
            % is used for maintaining backward compatibilty between releases
            % of App Designer. loadobj is a point when unserializing App
            % Designer data to modify the loaded object to make it
            % compatibile to the current release of App Designer
                        
            % update the returned obj to have the same data as loadedObj
            if isstruct(loadedObj)
                % MCOS will pass a struct into loadobj() when load() can't
                % create the object directly, e.g. class definition
                % changes.
                % In this case, 16a AppCallback inherits from AppVersion,
                % but removed in 16b (g1398205). So when loading an 16a app
                % into 16b, the loadedObj would be a struct
                obj = appdesigner.internal.codegeneration.model.AppCallback();
                fieldNames = fieldnames(loadedObj);
                for i = 1:length(fieldNames)
                    propName = fieldNames{i};
                    if isprop(obj, propName)
                        obj.(propName) = loadedObj.(propName);
                    end
                end
            else
                % Otherwise class definition is compatible with the 
                % serialized object, and MCOS load() can instantiate the 
                % object, and loadedObj would be a regular object
                obj = loadedObj;            
            end
        end
        %------------------------------------------------------------------
    end
end

