function launch(system, debug)
% LAUNCH Launch the Fixed-Point Tool.

% Copyright 2015-2018 The MathWorks, Inc.

  
    if nargin < 2
        debug = false;
    end
    
    model = bdroot(system);
    
    fptInstance = fxptui.FixedPointTool.getExistingInstance;
    if isempty(fptInstance)
        createInstance = true;
    elseif ~strcmpi(fptInstance.getModel, model)
        close(fptInstance);
        createInstance = true;
    else
        createInstance = false;
        fptInstance.loadReferencedModels;
    end
    
    if createInstance
        fptInstance = fxptui.FixedPointTool.getInstance(model);
        fptInstance.loadReferencedModels;
        fptInstance.ShortcutManager = fxptui.ShortcutManager(model);
        fptInstance.CaptureOriginalSettings = true;
        fptInstance.GoalSpecifier = fxptui.ConversionGoals(model);
        fptInstance.ExternalViewer = fptInstance.createExternalViewer;
    end
    
    % g1696210 - FPT should throw an error when the model is 
    % locked and should not hang
    [success, dlgType] = fxptui.verifyModelState(model);
    if ~success
        [~, msg_ID] = fxptui.message('errorTitleFPTGeneralError');
        msg = fxptui.message(dlgType);
        fpt_exception = MException(msg_ID, msg);
        throw(fpt_exception);
    end
          
    currentSystemForConversion = fptInstance.getSystemForConversion;
    blk = get_param(system, 'Object');
    if isa(blk,'Simulink.ModelReference')
        % Point to the referenced model if the model block is intended to
        % be the SUD. If not, retain the model block selection.
        if isempty(currentSystemForConversion)
            selectedSystem = blk.ModelName;
        else
            selectedSystem = blk.getFullName;
        end
        
    else
        [b, maskedSubsys] = fxptui.isUnderMaskedSubsystem(blk);
        if b
            selectedSystem = maskedSubsys.getFullName;
        else
            selectedSystem = blk.getFullName;
        end
    end
    
    if isempty(currentSystemForConversion)
        fptInstance.updateSelectedSystem(selectedSystem);       
    end
    
    fptInstance.postProcessSimulationData;
    if debug
        debugPort = matlab.internal.getOpenPort;
        fptInstance.open(debugPort);
    else
        fptInstance.open;
    end
end
% LocalWords: FPT