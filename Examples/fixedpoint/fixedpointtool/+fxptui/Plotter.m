classdef Plotter < handle
% PLOTTER Class that provides static methods for plotting signals from the Fixed-Point Tool.

% Copyright 2012-2014 The MathWorks, Inc
    
    methods(Static)
        function plotSignal(sdiSignalID)
        % Plots the signal whos ID is sdiID in the SDI GUI
            sdiEngine = Simulink.sdi.Instance.engine();
            fxptui.Plotter.initSDIGUI;
            for i = 1:length(sdiSignalID)
                if sdiEngine.isValidSignalID(sdiSignalID(i))
                    sdiEngine.setSignalChecked(sdiSignalID(i), true);
                end
            end
        end
        
        function plotDifference(sdiSignalID1, sdiSignalID2, channelIdx)
        % Plots the difference between the selected signals identified by
        % their signalIDs. If there are multiple channels in the selection,
        % then the specified channel is used to diff the signals.
            if ~isempty(channelIdx)
                sdiSignalID1 = sdiSignalID1(channelIdx);
                sdiSignalID2 = sdiSignalID2(channelIdx);
            end
            if isequal(sdiSignalID1, -1) || isequal(sdiSignalID2,-1)
                fxptui.showdialog('diffplotmissingchannel');
                return; 
            end
            sdiEngine = Simulink.sdi.Instance.engine();  
            fxptui.Plotter.initSDIGUI;
            % select the signals for differencing
            if sdiEngine.isValidSignalID(sdiSignalID1) && sdiEngine.isValidSignalID(sdiSignalID2)
                Simulink.sdi.compareSignals(sdiSignalID1, sdiSignalID2)
            end
        end
        
        function compareRuns(sdiRunID1, sdiRunID2, selectionID)
        % Compares the runs identified by their runIDs in the SDI GUI. If
        % the selection is a valid signal, it gets selected in the GUI
            sdiEngine = Simulink.sdi.Instance.engine();
            %initialize the GUI
            fxptui.Plotter.initSDIGUI;
            sdiGUI = Simulink.sdi.Instance.getMainGUI();
            sdiGUI.changeTab(Simulink.sdi.GUITabType.CompareRuns);
            % compare runs here and select the appropriate radio button.
            if sdiEngine.isValidRunID(sdiRunID1) && sdiEngine.isValidRunID(sdiRunID2)
                Simulink.sdi.compareRuns(sdiRunID1, sdiRunID2, '', selectionID);
            end
        end
        
        function initSDIGUI
        % Initializes the SDI GUI
        % Bring the GUI into focus.
            Simulink.sdi.view;
        end
    end
end
