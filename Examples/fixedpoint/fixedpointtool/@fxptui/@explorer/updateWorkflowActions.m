function updateWorkflowActions(h)
% updateWorkflowActions Updates the actions related to FPT workflow when
% the SUD is set

%   Copyright 2014-2015 The MathWorks, Inc.

    mlfbConversionEnabled = fxptui.isMATLABFunctionBlockConversionEnabled();

    if ~h.isSystemUnderConversionDefined
        h.getaction('START').Enabled = 'off';
        h.getaction('PAUSE').Enabled = 'off';
        h.getaction('STOP').Enabled = 'off';
        h.getaction('DERIVE').Enabled = 'off';
        h.getaction('LAUNCHFPA').Enabled = 'off';
        h.getaction('SCALE_PROPOSEDT').Enabled = 'off';
        h.getaction('SCALE_APPLYDT').Enabled = 'off';
        setCodeViewEnabled('off');
    else
        simStatus = h.getTopNode.getDAObject.SimulationStatus;
        if strcmpi(simStatus,'running')
            h.getaction('START').Enabled = 'off';
            h.getaction('PAUSE').Enabled = 'on';
            h.getaction('STOP').Enabled = 'on';
            setCodeViewEnabled('off');
        elseif strcmpi(simStatus, 'paused')
            h.getaction('START').Enabled = 'on';
            h.getaction('PAUSE').Enabled = 'off';
            h.getaction('STOP').Enabled = 'on';
            setCodeViewEnabled('off');
        else
            h.getaction('START').Enabled = 'on';
            h.getaction('PAUSE').Enabled = 'off';
            h.getaction('STOP').Enabled = 'off';
            h.getaction('DERIVE').Enabled = 'on';
            h.getaction('LAUNCHFPA').Enabled = 'on';
            h.getaction('SCALE_PROPOSEDT').Enabled = 'on';
            h.getaction('SCALE_APPLYDT').Enabled = 'on';
            
            if mlfbConversionEnabled
                setCodeViewEnabled(coder.internal.mlfb.gui.fxptToolIsCodeViewEnabled('global', true));
            end
        end    
    end
    
    function setCodeViewEnabled(enabledStr)
        if mlfbConversionEnabled
            h.getaction('OPEN_CODE_VIEW').Enabled = enabledStr;
        end
    end
end


