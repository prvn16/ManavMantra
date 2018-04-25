classdef CodeViewExternal < fxptui.ExternalViewer
    %EXTERNALVIEWER Class to interface with MLFB Coder View
    
    %   Copyright 2013-2017 The MathWorks, Inc.
    
    methods(Static)
        function updateGlobalEnabledState(enabled)
            coder.internal.mlfb.gui.CodeViewUpdater.updateGlobalEnabledState(enabled);
        end
        function runRenamed(oldRunName, newRunName)
            coder.internal.mlfb.gui.CodeViewUpdater.runRenamed(oldRunName, newRunName);
        end
        function proposedTypeAnnotated(result)
            coder.internal.mlfb.gui.CodeViewUpdater.proposedTypeAnnotated(result);
        end
        function runsDeleted(varargin)
            coder.internal.mlfb.gui.CodeViewUpdater.runsDeleted(varargin);
        end
        function typesApplied(applySuccess)
            coder.internal.mlfb.gui.CodeViewUpdater.typesApplied(applySuccess);
        end
        function typesProposed(SUDObject)
            coder.internal.mlfb.gui.CodeViewUpdater.typesProposed(SUDObject);
        end
        function overrideConvertedMATLABFunctionBlocks(modelName, blkData)
            coder.internal.MLFcnBlock.FPTSupport.overrideConvertedMATLABFunctionBlocks(modelName,blkData);
        end
        function markSimCompleted
            coder.internal.mlfb.gui.CodeViewUpdater.markSimCompleted();
        end
        function applyIdealizedShortcutBeforePropose
            if coder.internal.mlfb.gui.fxptToolIsCodeViewEnabled
                % In order for the timestamp of the last range collection run
                % to be considered valid, reapply the idealized shortcut before
                % the proposal process kicks in.
                fpt = fxptui.FixedPointTool.getExistingInstance;
                try
                    [refMdls, ~] = find_mdlrefs(fpt.getModel);
                catch mdl_not_found_exception %#ok<NASGU> % Model not on path.
                end
                origDirty(1:length(refMdls)) = {''};
                for i = 1:length(refMdls)
                    origDirty{i} = get_param(refMdls{i}, 'dirty');
                end
                
                shortcutManager = fpt.getShortcutManager;
                lastUsedIdealizedShortcut = shortcutManager.getLastUsedIdealizedShortcut;
                if ~isempty(lastUsedIdealizedShortcut)
                    shortcutManager.applyShortcut(lastUsedIdealizedShortcut);
                end
                
                for i = 1:numel(refMdls)
                    if strcmp(origDirty{i}, 'off')
                        set_param(refMdls{i}, 'dirty','off')
                    end
                end
                % MMO is also part of the MLFB checksum, so turn on to
                % match simulation settings
                fpt.turnOnInstrumentationAndRestoreDirty;
            end
        end
        
        function restoreModelSettings
            % Restore the model settings. DTO settings were changed for the
            % proposal workflow in MLFB.
            if coder.internal.mlfb.gui.fxptToolIsCodeViewEnabled
                fpt = fxptui.FixedPointTool.getExistingInstance;
                fpt.restoreSystemSettings;
            end
        end
    end
    
end

