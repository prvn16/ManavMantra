classdef VisualizerController < handle
%% VISUALIZERCONTROLLER class is server side controller for Visulization 
% GUI interface for fixed point tool's Web-based GUI

%   Copyright 2016-2017 The MathWorks, Inc.
    properties
        VisualizerEngine;
    end
    properties (Access = 'private')
        Subscriptions; % Unsubscribe during deletion
        
        %Channel to publish Data
        PublishServerReadyChannel = '/visualizer/startVisualizer';
        PublishMetaDataChannel = '/visualizer/sendMetaData';
        PublishDataChannel = '/visualizer/sendData';
        PublishDataDoneChannel = '/visualizer/sendDataComplete';
        PublishSelectHistogramChannel = '/visualizer/selectHistogram';
        PublishClearHistogramsChannel = '/visualizer/deleteRun';
        PublishDataForCanvasMoveChannel = '/visualizer/dataForCanvasMove';
        Data;
        MetaData; 
    end
    properties(Hidden)
        % Test property used to check if right channel was used for publish
        % calls in the unit tests
        LastUsedChannel = '';
        LastUsedData = '';
        LastSelectedRun = '';
    end
    methods
        function this = VisualizerController(clientID)
            % VisualizerController: Constructor
            % initialize the URL & the message subscription channel &
            % callback.            
            this.addClientIDToChannels(clientID);     
            this.VisualizerEngine = DataTypeWorkflow.Visualizer.Engine(DataTypeWorkflow.Visualizer.ClientTypes.FPTClientRecordFactory);
        end        
        sendServerReady(this);
        updateVisualizer(this, lastUpdatedRun, results, spreadsheetResultHierarchy);
        updateVisualizerUsingDB(this, tableData);
        selectHistogram(this, msg);
        sendDataForCanvasMove(this, data);
        clearHistogramsForDeletedRun(this, msg);
        notifyScopingChange(this, msg);
        getRowIdForSignalIdex(this, signalIndex);
        delete(this);
    end
    methods(Hidden = true)
        addClientIDToChannels(this, clientID);
        sendVisualizationData(this, runName, results, resultRenderingOrder);
        publishData(this, doPublishMetaDataFlag);
        packageData(this, runName, results, resultRenderingOrder);
        packageDataUsingDB(this, doPackageMetaDataFlag);
        cleanup(this);
        [tableData, Zero, GlobalYLimit, WouldBeOverflows] = collectData(this, runName, results, resultRenderingOrder);
        data = getData(this);
        data = getMetaData(this);
        channelSelected = getLastUsedChannel(this);
        subscriptions = getSubscriptions(this);
    end
    methods(Static)
        filteredOrder = filterResultRenderingOrder(currentOrder, results, runName);
    end
end

