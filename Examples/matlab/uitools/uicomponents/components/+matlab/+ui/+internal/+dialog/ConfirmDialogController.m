classdef ConfirmDialogController < matlab.ui.internal.dialog.DialogController
    %CONFIRMDIALOGCONTROLLER
    % This controller marshals data to the view to create and manage
    % confirm dialogs on web GUIs.
    
    
    properties
        ViewDataFields = {'dataTestId','action','title','message','options','callbackChannelID'};
        FigureCloseRequestFcnCache;
        SelectedOption = '';
    end
    
    methods(Access = public)
        function this = ConfirmDialogController(params)
            validParams = {'CloseFcn','Figure','FigureID','Icon','IconType','Message','Title','Options','DefaultOption','CancelOption'};
            this@matlab.ui.internal.dialog.DialogController(params, validParams);
            
            this.ViewData.action = 'displayConfirmDialog';
            this.ViewData.title = this.ModelProperties.Title;
            this.ViewData.message = this.ModelProperties.Message;
            this.ViewData.options.buttonText = this.ModelProperties.Options;
            this.ViewData.options.defaultAcceptButton = this.ModelProperties.DefaultOption;
            this.ViewData.options.defaultCancelButton = this.ModelProperties.CancelOption;
            this.ViewData.dataTestId = ['ConfirmDialog_' this.InstanceID];
            this.setupIconForView();
        end
    end
    
    methods (Access = protected)
        function e = processEventData(this, eventData)
            e.Source = this.ModelProperties.Figure;
            e.EventName = 'ConfirmDialogClosed';
            e.DialogTitle = this.ModelProperties.Title;
            e.SelectedOptionIndex = eventData.response;
            e.SelectedOption = eventData.buttonText; 
            this.SelectedOption = e.SelectedOption;
        end
        
        function setupListeners(this)
            % Setup Close function
            this.CallbackSubscription = message.subscribe(this.CallbackChannelID, @(evd) this.closeCallback(evd));

            % Disable Figure's Close so that end-user always responds to
            % the confirmation dialog 
            this.FigureCloseRequestFcnCache = this.ModelProperties.Figure.CloseRequestFcn;
            this.ModelProperties.Figure.CloseRequestFcn = '';
        end
        
        function destroyListeners(this)
            % disable other close callbacks
            message.unsubscribe(this.CallbackSubscription);
            this.ModelProperties.Figure.CloseRequestFcn = this.FigureCloseRequestFcnCache;
            this.FigureCloseRequestFcnCache = '';
        end
    end
    
end

