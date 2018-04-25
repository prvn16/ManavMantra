classdef ModelPreferencesHandler < handle
% MODELPREFERENCESHANDLER provides basic APIs to manipulate a value in the
% Settings file. These changes can be saved with the user preference or
% model file by providing either the User or Model level flags
    
% Copyright 2014 The MathWorks, Inc.
    
    properties(GetAccess = private, SetAccess = private)
        FPTDataPartName
        ModelName
    end
       
    methods
        function this = ModelPreferencesHandler(model)
            if nargin < 1
                [msg, identifier] = fxptui.message('incorrectInputArgsModel');
                e = MException(identifier, msg);
                throwAsCaller(e);
            end
            partInfo = fxptui.FPTPartInformation;
            this.FPTDataPartName = partInfo.getPartName;
            sys = find_system('type','block_diagram','Name',model);
            if isempty(sys)
                [msg, identifier] = fxptui.message('modelNotLoaded',model);
                e = MException(identifier, msg);
                throwAsCaller(e);
            else
                this.ModelName = model;
            end
        end
        
        function val = getPreference(this, parameter)
            val = [];
            partFileName = fullfile(get_param(this.ModelName,'UnpackedLocation'),...
                this.FPTDataPartName);
            modelLevelSettings = fxptui.readFPTDataFromPartFile(partFileName);
            if isfield(modelLevelSettings, parameter)
                convertTo = modelLevelSettings.([parameter 'Class']);
                strVal = modelLevelSettings.(parameter);
                switch convertTo
                    case 'logical'
                        val = true;
                        if strcmp(strVal,'0')
                            val = false;
                        end
                    case 'double'
                        val = str2double(strVal);
                end               
            end
        end
              
        function setPreference(this, parameter, value)
            % Save setting to SLX file
            partInfo = fxptui.FPTPartInformation;
            partsFileName = fullfile(get_param(this.ModelName,'UnpackedLocation'),...
                this.FPTDataPartName);
            fxptui.writeFPTDataToPartFile(partsFileName, parameter, value);
            bd = get_param(this.ModelName,'Object');
            % Set the dirty state of a part
            bd.setDirty(partInfo.getPartID,true);
        end
        
        function modelLevelSettings = getPreferences(this)
            partsFileName = fullfile(get_param(this.ModelName,'UnpackedLocation'),...
                this.FPTDataPartName);
            modelLevelSettings = fxptui.readFPTDataFromPartFile(partsFileName);
        end
    end
end
