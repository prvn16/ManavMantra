classdef DICOMBrowser < handle
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties
        browserModel
        browserView
        browserController
    end
    
    methods
        function obj = DICOMBrowser(location)
            obj.browserView = images.internal.app.dicom.BrowserView;
            obj.browserModel = images.internal.app.dicom.BrowserModel;
            obj.browserController = images.internal.app.dicom.BrowserController(obj.browserModel, obj.browserView);
            
            if nargin > 0
                try
                    obj.browserModel.loadNewCollection(location)
                catch ME
                    dialogTitle = getString(message('images:DICOMBrowser:errorDialogTitle'));
                    errordlg(ME.message, dialogTitle, 'modal')
                    return
                end
            end
            
            imageslib.internal.apputil.manageToolInstances('add', 'DICOMBrowser', obj.browserView.ToolGroup)
            
            % Tie lifecycle of DICOMBrowser class to destruction of the
            % ToolGroup in the View.
            addlistener(obj.browserView.ToolGroup, 'GroupAction', @(src, event) closeCallback(obj, event));
            
        end
        
        function closeCallback(obj, event)
            ET = event.EventData.EventType;
            if strcmp(ET, 'CLOSED')
                delete(obj.browserView)
                delete(obj.browserModel)
                delete(obj.browserController)
                delete(obj)
            end
        end
    end
end

            
