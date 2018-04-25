classdef Startup < handle
% STARTUP Launch point of the Initial interview & system selector dialog.
    
% Copyright 2014-2017 The MathWorks, Inc.
    
    
    properties (SetAccess=private, GetAccess=private)
        DebugApp = 'toolbox/fixedpoint/fixedpointtool/web/startupdialog/startup-debug.html'
        ReleaseApp = 'toolbox/fixedpoint/fixedpointtool/web/startupdialog/startup.html'
        StartupDialog
        StartupController
        AppURL
        Subscriptions
        Model
        BlockDiagram
        EventListeners
    end

    events
        SUDChangedEvent

    end

    methods
        function this = Startup(model)
            connector.ensureServiceOn;
            if nargin < 1
                [msg, identifier] = fxptui.message('incorrectInputArgsModel');
                e = MException(identifier, msg);
                throwAsCaller(e);
            end
            sys = find_system('type','block_diagram','Name',model);
            if isempty(sys)
                [msg, identifier] = fxptui.message('modelNotLoaded',model);
                e = MException(identifier, msg);
                throwAsCaller(e);
            else
                this.Model = model;
                this.BlockDiagram = get_param(model,'Object');
            end
            this.Subscriptions = message.subscribe('/fpt/startup/ready',@(data) this.initStartupController(data));
        end
        
        function delete(this)
            delete(this.StartupController);
            this.deleteDialog;
            message.unsubscribe(this.Subscriptions);
        end
        
        function show(this, debug)
        % Launches the initial dialog within a DDG window
            this.deleteDialog;   
            isDebug = false;
            if nargin > 1
                isDebug = debug;
            end
            this.AppURL = this.getApplicationURL(isDebug);
            this.StartupDialog = DAStudio.Dialog(this);
        end
            
        function dlgstruct = getDialogSchema(this, ~)
            webbrowser.Type = 'webbrowser';
            webbrowser.MinimumSize = [500 300];
            webbrowser.Tag = 'startup_web';
            webbrowser.Url = this.AppURL;
            webbrowser.WebKit  = true;
            webbrowser.DisableContextMenu = true;
            
            dlgstruct.DialogTitle = fxptui.message('titleStartupDialog');
            dlgstruct.DialogTag = 'FPT_Startup_Window';
            dlgstruct.StandaloneButtonSet  = {'OK'};
            dlgstruct.CloseCallback = 'fxptui.Startup.showFPT';
            dlgstruct.LayoutGrid  = [1 1];
            dlgstruct.RowStretch = 1;
            dlgstruct.ColStretch = 1;
            dlgstruct.Items = {webbrowser};
        end
        
        function deleteDialog(this)
            if isa(this.StartupDialog,'DAStudio.Dialog')
                delete(this.StartupDialog);
            end
        end
    end
    
    methods (Hidden)
        function appURL = getApplicationURL(this, isDebug)
            connector.ensureServiceOn;
            if isDebug
                appURL = this.DebugApp;
            else
                appURL = this.ReleaseApp;
            end
            appURL = fxptui.Web.CreateNoncedURL(appURL);
        end
    end
    
    methods(Access=private)
        function initStartupController(this, data)
            modelHierarchy = fxptui.ModelHierarchy(this.BlockDiagram.getFullName);
            modelHierarchy.captureHierarchy;
            this.StartupController = fxptui.Web.StartupController(data.UUID, modelHierarchy, this.BlockDiagram.getFullName);
            this.EventListeners = addlistener(this.StartupController,'SUDChangedEvent',@this.notifySUDChange);
            this.StartupController.publishHierarchy(data);
        end

        function notifySUDChange(this, ~, eventdata)
            notify(this, 'SUDChangedEvent', eventdata);
        end
    end

    
    methods(Static)
        function showFPT
           me = fxptui.getexplorer;
           if ~isempty(me)
               me.hide;
               me.show;
           end
        end
    end
end
