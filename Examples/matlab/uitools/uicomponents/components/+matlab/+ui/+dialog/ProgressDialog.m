classdef ProgressDialog  < handle & matlab.mixin.CustomDisplay & ....
        matlab.mixin.SetGet
    %
    
    % Do not remove above white space
    % Copyright 2017 The MathWorks, Inc.
    
    
    properties (Transient)
        Value (1,1) {mustBeNumeric, mustBeGreaterThanOrEqual(Value,0), mustBeLessThanOrEqual(Value,1)} = 0;
        Message = '';
        Title = '';
        Indeterminate (1,1) matlab.lang.OnOffSwitchState = matlab.lang.OnOffSwitchState.off;
        Icon = '';
        ShowPercentage (1,1) matlab.lang.OnOffSwitchState = matlab.lang.OnOffSwitchState.off;
        Cancelable (1,1) matlab.lang.OnOffSwitchState = matlab.lang.OnOffSwitchState.off;
        CancelText = getString(message('MATLAB:uitools:uidialogs:Cancel'));
    end
    
    properties (Transient, Dependent)
        % This property gets/sets its value from the controller/view
        CancelRequested (1,1) logical;
    end
    
    properties (Transient, Access = protected)
        IconType = 'preset';
        FigureHandle;
        FigureID;
        ChannelID = '';
        Controller;
    end
    
    methods
        
        function obj = ProgressDialog(f,varargin)
            %
            
            narginchk(1,nargin);
            
            if nargin > 1
                [varargin{:}] = convertStringsToChars(varargin{:});
            end
            
            % Validate Figure
            obj.FigureID = matlab.ui.internal.dialog.DialogHelper.validateUIfigure(f);
            obj.FigureHandle = f;
            
            % Setup controller
            obj.Controller = matlab.ui.internal.dialog.ProgressDialogController(obj.FigureID, f, obj);
            
            if (nargin > 1)
                if (mod(numel(varargin),2) == 1)
                    throwAsCaller(MException(message('MATLAB:uitools:uidialogs:IncorrectNameValuePairs')));
                end
                % Pass through all PV pairs to set
                set(obj,varargin{:});
            end
            
            obj.Controller.show();
        end
        
        function delete(obj)
            delete(obj.Controller);
        end
        
        function close(obj)
            delete(obj);
        end
        
        function set.Title (obj, titleString)
            titleString = convertStringsToChars(titleString);
            obj.Title = matlab.ui.internal.dialog.DialogHelper.validateTitle(titleString);
            obj.Controller.updateProperty('Title',obj.Title); %#ok<*MCSUP>
        end
        
        function set.Message (obj, msgString)
            msgString = convertStringsToChars(msgString);
            obj.Message = matlab.ui.internal.dialog.DialogHelper.validateMessageText(msgString);
            obj.Controller.updateProperty('Message',obj.Message);
        end
        
        function set.Icon (obj, icon)
            icon = convertStringsToChars(icon);
            [obj.Icon, obj.IconType] = matlab.ui.internal.dialog.DialogHelper.validateIcon(icon);
            obj.Controller.updateProperty('Icon',obj.Icon,obj.IconType);
        end
        
        function set.Value (obj, val)
            obj.Value = val;
            obj.Controller.updateProperty('Value',obj.Value);
        end
        
        function set.Indeterminate (obj, val)
            obj.Indeterminate = val;
            obj.Controller.updateProperty('Indeterminate',obj.Indeterminate);
        end
        
        function set.ShowPercentage (obj, val)
            obj.ShowPercentage = val;
            obj.Controller.updateProperty('ShowPercentage',obj.ShowPercentage);
        end
        
        function set.Cancelable (obj, val)
            obj.Cancelable = val;
            obj.Controller.updateProperty('Cancelable',obj.Cancelable);
        end
        
        function set.CancelText (obj, val)
            val = convertStringsToChars(val);
            obj.CancelText = matlab.ui.internal.dialog.DialogHelper.validateTitle(val);
            obj.Controller.updateProperty('CancelText',obj.CancelText);
        end
        
        function set.CancelRequested (obj, val)
            obj.Controller.updateProperty('CancelRequested',val);
        end
        
        function out = get.CancelRequested (obj)
            out = obj.Controller.getCancelRequested();
        end
        
    end
    
    methods (Access = protected)
        function propgrp = getPropertyGroups(~)
            propgrp = matlab.mixin.util.PropertyGroup({'Value','Message','Title','Indeterminate','Icon','ShowPercentage','Cancelable'});
        end
    end
end

