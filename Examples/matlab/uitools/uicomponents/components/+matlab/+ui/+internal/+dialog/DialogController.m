classdef (Abstract) DialogController < handle
    %Base Dialog controller for dialogs in WebGUIs
    
    properties
        ModelProperties;
        ViewData;
        ChannelID = '';
        InstanceID = '';
        CallbackChannelID = '';
        CallbackSubscription;
    end
    
    properties (Abstract = true)
        ViewDataFields;
    end
    
    methods(Access = public)
        function this = DialogController(params, validParams)
            this.validateStruct(params, validParams);
            
            this.InstanceID = char(java.util.UUID.randomUUID);
            this.ChannelID = ['/gbt/figure/DialogService/' params.FigureID];
            this.ModelProperties = params;
            
            this.CallbackChannelID = [this.ChannelID '/' this.InstanceID];
            this.ViewData.callbackChannelID = this.CallbackChannelID;
        end
        
        function show(this)
            this.validateStruct(this.ViewData, this.ViewDataFields)
            
            this.setupListeners();
            
            % Send message to client
            publishHandle = @() message.publish(this.ChannelID, this.ViewData);
            matlab.ui.internal.dialog.DialogHelper.dispatchWhenViewIsReady(this.ModelProperties.Figure, publishHandle);
        end
        
        function closeCallback(this, eventData)
            this.destroyListeners();
            e = this.processEventData(eventData);
            
            % process current CloseFcn if specified
            if ~isempty(this.ModelProperties.CloseFcn)
                try
                    hgfeval(this.ModelProperties.CloseFcn, e.Source, e);
                catch e
                    warning(message('MATLAB:uitools:uidialogs:ErrorEvaluatingCloseFcn', e.getReport('basic','hyperlinks','off')));
                end
            end
        end
    end
    
    methods (Abstract, Access = protected)
        processEventData(this, e);
        setupListeners(this);
        destroyListeners(this);
    end
    
    methods (Access = protected)
        function setupIconForView(this)
            this.ViewData.options.icon = matlab.ui.internal.dialog.IconUtils.getIconForView(this.ModelProperties.Icon, this.ModelProperties.IconType);            
        end
    end
    
    methods (Access = private)
        function validateStruct(this, params, fieldNames)
            validateattributes (params, {'struct'}, {'scalar','nonempty'}, this.getClassName());
            assert(all(isfield(params,fieldNames)), 'MATLAB:DialogController:UnknownParameters', ...
                'Expected struct fields were not provided');
        end
        
        function className = getClassName(this)
            c = strsplit(class(this),'.');
            className = c{end};
        end
    end
end

