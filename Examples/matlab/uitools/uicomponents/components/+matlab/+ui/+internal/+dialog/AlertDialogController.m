classdef AlertDialogController < matlab.ui.internal.dialog.DialogController
    %ALERTDIALOGCONTROLLER
    % This controller marshals data to the view to create and manage alert
    % dialogs on web GUIs.
    
    properties
        ViewDataFields = {'dataTestId','action','title','message','options','callbackChannelID'};
        FigureCloseListener;
    end
    
    methods(Access = public)
        function this = AlertDialogController(params)
            validParams = {'CloseFcn','Figure','FigureID','Icon','IconType','Message','Modal','Title'};
            this@matlab.ui.internal.dialog.DialogController(params,validParams);
            
            this.ViewData.action = 'displayAlertDialog';
            this.ViewData.title = this.ModelProperties.Title;
            this.ViewData.message = this.ModelProperties.Message;
            this.ViewData.options.modal = this.ModelProperties.Modal;
            this.ViewData.dataTestId = ['AlertDialog_' this.InstanceID];
            this.setupIconForView();
        end
    end
    
    methods (Access = protected)
        function e = processEventData(this, ~)
            e.Source = this.ModelProperties.Figure;
            e.EventName = 'AlertDialogClosed';
            e.DialogTitle = this.ModelProperties.Title;
        end
        
        function setupListeners(this)
            % Setup Close function
            this.FigureCloseListener = addlistener(this.ModelProperties.Figure, 'Close', @(o,e) this.closeCallback('FigureClosed'));
            this.CallbackSubscription = message.subscribe(this.CallbackChannelID, @(evd) this.closeCallback(evd));
        end
        
        function destroyListeners(this)
            % disable other close callbacks
            message.unsubscribe(this.CallbackSubscription);
            delete(this.FigureCloseListener);
        end
        
    end
end

