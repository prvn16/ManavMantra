classdef BrowserController < handle
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Access = private)
        Model
        View
    end
    
    methods
        function obj = BrowserController(model, view)
            obj.Model = model;
            obj.View = view;
            
            obj.wireListeners()
        end
    end
    
    methods (Access = private)
        function wireListeners(obj)
            addlistener(obj.Model, 'CollectionChange', @(hObj,evtData) obj.View.updateViewer(evtData));
            addlistener(obj.View, 'ViewStudySelection', @(hObj,evtData) obj.studySelectionFcn(evtData));
            addlistener(obj.View, 'ViewSeriesSelection', @(hObj,evtData) obj.seriesSelectionFcn(evtData));
            addlistener(obj.View, 'SendVolumeToWorkspace', @(hObj,evtData) obj.sendVolumeToWorkspace(evtData));
            addlistener(obj.View, 'SendTableToWorkspace', @(hObj,evtData) obj.sendTableToWorkspace(evtData));
            addlistener(obj.View, 'SendToVideoViewer', @(hObj,evtData) obj.sendToVideoViewer(evtData));
            addlistener(obj.View, 'SendToVolumeViewer', @(hObj,evtData) obj.sendToVolumeViewer(evtData));
            addlistener(obj.View, 'ImportFromDicomFolder', @(hObj,evtData) obj.importFromFolder(evtData));
            addlistener(obj.View, 'ImportFromWorkspace', @(hObj,evtData) obj.importFromWorkspace(evtData));
            addlistener(obj.View, 'BackgroundVolumeLoad', @(hObj,evtData) obj.backgroundVolumeLoad(evtData));
        end
        
        function studySelectionFcn(obj, evtData)
            studyIndex = evtData.StudyIndex;
            seriesDetails = obj.Model.getSeriesDetailsForStudy(studyIndex);
            obj.Model.CurrentStudy = studyIndex;
            obj.Model.updateCurrentVolume([])
            obj.View.updateSeriesTable(seriesDetails);
        end
        
        function seriesSelectionFcn(obj, evtData)
            obj.Model.CurrentStudy = evtData.StudyIndex;
            obj.Model.CurrentSeries = evtData.SeriesIndex;
            obj.Model.updateCurrentVolume([])
        end
        
        function sendVolumeToWorkspace(obj, evtData)
            oc = onCleanup(@() obj.View.makeResponsive());
            
            studyIndex = evtData.StudyIndex;
            seriesIndex = evtData.SeriesIndex;
            
            try
                [V, spatialDetails] = obj.Model.loadVolume(studyIndex, seriesIndex);
                map = obj.Model.loadColormap(studyIndex, seriesIndex);
            catch ME
                dialogTitle = getString(message('images:DICOMBrowser:errorDialogTitle'));
                errordlg(ME.message, dialogTitle, 'modal')
                return
            end
            
            if ~isempty(map)
                checkBoxLabels = {getString(message('images:DICOMBrowser:exportVolumeLabel')), ...
                    getString(message('images:DICOMBrowser:exportColormapLabel')), ...
                    getString(message('images:DICOMBrowser:exportSpatialLabel'))};
                defaultNames = {'V', 'map', 'spatialDetails'};
                export2wsdlg(checkBoxLabels, defaultNames, {V, map, spatialDetails});
            else
                checkBoxLabels = {getString(message('images:DICOMBrowser:exportVolumeLabel')), ...
                    getString(message('images:DICOMBrowser:exportSpatialLabel'))};
                defaultNames = {'V', 'spatialDetails'};
                export2wsdlg(checkBoxLabels, defaultNames, {V, spatialDetails});
            end
        end
        
        function sendTableToWorkspace(obj, evtData)
            oc = onCleanup(@() obj.View.makeResponsive());
            
            studyIndex = evtData.StudyIndex;
            seriesIndex = evtData.SeriesIndex;
            
            theSeriesDetails = obj.Model.getFullDetailsForSeries(studyIndex, seriesIndex);
            
            checkBoxLabels = {getString(message('images:DICOMBrowser:exportSeriesLabel'))};
            defaultNames = {'seriesDetails'};
            export2wsdlg(checkBoxLabels, defaultNames, {theSeriesDetails});
        end
        
        function sendToVolumeViewer(obj, evtData)
            oc = onCleanup(@() obj.View.makeResponsive());
            
            studyIndex = evtData.StudyIndex;
            seriesIndex = evtData.SeriesIndex;
            
            try
                [V, spatialDetails, sliceDim] = obj.Model.loadVolume(studyIndex, seriesIndex);
            catch ME
                dialogTitle = getString(message('images:DICOMBrowser:errorDialogTitle'));
                errordlg(ME.message, dialogTitle, 'modal')
                return
            end
            
            try
                if isempty(spatialDetails) || isempty(spatialDetails.PatientOrientations) || isempty(spatialDetails.PixelSpacings)
                    volumeViewer(squeeze(V))
                else
                    tform = images.internal.dicom.convertSpatialToHGTform(spatialDetails, sliceDim);
                    volumeViewer(squeeze(V), tform)
                end
            catch ME
                dialogTitle = getString(message('images:DICOMBrowser:errorDialogTitle'));
                errordlg(ME.message, dialogTitle, 'modal')
                return
            end
        end
        
        function sendToVideoViewer(obj, evtData)
            oc = onCleanup(@() obj.View.makeResponsive());
            
            studyIndex = evtData.StudyIndex;
            seriesIndex = evtData.SeriesIndex;
            
            try
                vid = obj.Model.loadVolume(studyIndex, seriesIndex);
                map = obj.Model.loadColormap(studyIndex, seriesIndex);
            catch ME
                dialogTitle = getString(message('images:DICOMBrowser:errorDialogTitle'));
                errordlg(ME.message, dialogTitle, 'modal')
                return
            end
            
            try
                if ~isa(vid, 'uint8') && isempty(map)
                    clim = single([min(vid(:)) max(vid(:))]);
                    vid = uint8((single(vid) - clim(1)) ./ (clim(2) - clim(1)) * 255);
                end
                
                I = implay(vid);
                if ~isempty(map)
                    I.Visual.ColorMap.Map = map;
                    I.Visual.ColorMap.MapExpression = '';
                end
                I.DataSource.Controls.Repeat = true;
            catch ME
                dialogTitle = getString(message('images:DICOMBrowser:errorDialogTitle'));
                errordlg(ME.message, dialogTitle, 'modal')
                return
            end
        end
        
        function importFromFolder(obj, evtData)
            obj.Model.loadCollection(evtData.DirectoryName)
        end
        
        function importFromWorkspace(obj, evtData)
            obj.Model.loadCollection(evtData.Collection)
        end
        
        function backgroundVolumeLoad(obj, evtData)
            obj.Model.updateCurrentVolume(evtData);
        end
    end
end