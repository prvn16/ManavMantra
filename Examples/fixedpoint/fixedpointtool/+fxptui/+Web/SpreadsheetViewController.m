classdef SpreadsheetViewController < handle
% SPREADSHEETVIEWCONTROLLER Class definition to communicate with the web based spreadsheet in FPT
    
    %   Copyright 2014-2016 The MathWorks, Inc.
    
    properties
        modelName;
    end
    
    methods
        function this =  SpreadsheetViewController(mName)
            this.modelName = mName;
            connector.ensureServiceOn;
        end
        
        % Collects the data for the model name used while creating an
        % instance.
        % The output data_struct is an array of structs where each struct 
        % represents values of each row containing all the fields.
        function [data_struct] = collectDataForModel(this)
            repositoryInstance = fxptds.FPTRepository.getInstance;
            ds = repositoryInstance.getDatasetForSource(this.modelName);
            results1 = ds.getResultsFromRuns;

            data_struct = struct;
            
            % Creating three different arrays to contain list of the
            % different kinds of properties present.
            primaryFields = {'SignalName','CompiledDT','SpecifiedDT','SimMin','SimMax','DesignMin','DesignMax','DerivedMin','DerivedMax','ProposedDT','OverflowWrap','OverflowSaturation'};
            secondaryFields = {'CompiledDesignMin','CompiledDesignMax','InitialValueMin','InitialValueMax','DTGroup','SignalName'};
            derivedFields = {'RunID','ProposedMin','ProposedMax','Size','Complexity','Scope','fimath'};
            
            %Collect all the required data and add it to the struct
            for l=1:length(results1)
                for k=1:numel(primaryFields)
                    data_struct(l).(primaryFields{k}) = results1(l).getPropertyValue(primaryFields{k});
                end
                for k=1:numel(secondaryFields)
                    data_struct(l).(secondaryFields{k}) = results1(l).getPropertyValue(secondaryFields{k});
                end
                % getPropValue is used the properties present in the
                % derivedFields array are derived.
                for k=1:numel(derivedFields)
                    data_struct(l).(derivedFields{k}) = results1(l).getPropValue(derivedFields{k});
                end
            end
            
            %overflowHighlight is the field used by javascript side to
            %determine if a row should be highlighted.
            for j=1:length(results1)
                if(~isempty(data_struct(j).OverflowSaturation) || ~isempty(data_struct(j).OverflowWrap))
                    data_struct(j).overflowHighlight = 1;
                else
                    data_struct(j).overflowHighlight = 0;
                end
            end

            %Add the display as well as the Run names .
            for m=1:numel(data_struct)
                data_struct(m).Name = results1(m).getDisplayLabel;
                data_struct(m).Run = results1(m).getRunName;
            end

            structToPublish.message = 'Results obtained';
            structToPublish.result = data_struct;

            % Load the preferences if they exist.
            prefs = fxptui.Web.SpreadsheetViewController.readSpreadsheetViewPreferences;
            
            % Add the preferences to the struct to be published only if
            % the preferences are present.
            if(~strcmp(prefs,''))
                structToPublish.preferences = prefs;
            end
            
            message.publish('/fpt/table_data',structToPublish);
        end
    end
    
    % Created static methods since the preferences do no depend on the
    % model.
    methods (Static = true)

        % Used to read the preference data for the SpreadsheetView
        % component.
        function prefsRead = readSpreadsheetViewPreferences()
            preferenceFile = fullfile(prefdir, 'fixedpointtoolprefs.mat');
            prefsRead = '';
            if exist(preferenceFile, 'file')
                existStatus = whos('-file', preferenceFile, 'fixedPointWebUIpreferences');
                if ~isempty(existStatus)
                    prefsRead = load(preferenceFile, 'fixedPointWebUIpreferences');
                    prefsRead = prefsRead.fixedPointWebUIpreferences;
                end
            end
        end

        % Used to write the preference data for the SpreadsheetView
        % component.
        % This function will over-write fixedPointWebUIpreferences if they 
        % are present. 
        function saveSpreadsheetViewPreferences(prefs)
            fixedPointWebUIpreferences = prefs; %#ok<NASGU>
            preferenceFile = fullfile(prefdir, 'fixedpointtoolprefs.mat');
            if exist(preferenceFile, 'file')
                save(preferenceFile, 'fixedPointWebUIpreferences', '-append');
            else
                save(preferenceFile, 'fixedPointWebUIpreferences', '-v7.3');
            end
        end
    end
end
