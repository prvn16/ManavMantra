classdef SimulationHandler < handle
% Class to handle simulating the model from FPT.

% Copyright 2017-2018 The MathWorks, Inc.
   
    properties(SetAccess = private, GetAccess = private)
        Model
        Listener
        AccelModeHandler
    end
    
    methods
        function this =  SimulationHandler(topModel)
            if nargin < 1
                [msg, identifier] = fxptui.message('incorrectInputArgsModel');
                e = MException(identifier, msg);
                throwAsCaller(e);
            end
            this.Model = topModel;            
        end
        
        function Simulate(this, action)
        % Perform the requested simulation action.
            switch action
                case 'start'
                    if strcmpi(get_param(this.Model,'SimulationStatus'), 'paused')
                        cmd = 'continue';
                    else
                        this.AccelModeHandler = fxptui.Web.AccelModeHandler(this.Model);
                        % The below event should be triggered as long as
                        % the simulation is started. It will be triggered
                        % even if the model compilation fails.
                        if isempty(this.Listener)
                            this.Listener = handle.listener(get_param(this.Model, 'Object'), 'EngineSimulationEnd', @(s,e)this.cleanupAfterSimulation);
                        end
                        this.AccelModeHandler.switchToNormalMode;
                        cmd = 'start';
                    end
                case 'pause'
                    cmd = 'pause';
                case 'stop'
                    cmd = 'stop';
            end
            
            try
                fpt_diagViewer = DAStudio.DiagViewer.findInstance('FPTDiagnostics');
                if ~isempty(fpt_diagViewer)
                    fpt_diagViewer.flushMsgs;
                    fpt_diagViewer.Visible = false;
                    delete(fpt_diagViewer);
                end
                fpt = fxptui.FixedPointTool.getExistingInstance;
                % Disable code-view if present
                fpt.enableCodeView(false);
                set_param(this.Model, 'simulationcommand', cmd);
            catch e %#ok                
            end
            
        end
        
        function delete(this)          
            this.Model = '';
        end
        
    end
    
    methods(Access = private)        
        function cleanupAfterSimulation(this)
            % Restore the DTO/MMO/Run name settings on the model
            fpt = fxptui.FixedPointTool.getExistingInstance;
            fpt.restoreSystemSettings;
            % restore the accel mode in the model (incl. model references)
            if ~isempty(this.AccelModeHandler)
                this.AccelModeHandler.restoreSimulationMode;
                delete(this.AccelModeHandler);
                this.AccelModeHandler = [];
                delete(this.Listener);
                this.Listener = [];
            end
        end
    end
   
end   
