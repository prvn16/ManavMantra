classdef SingleConverterController < handle
% SINGLECONVERTERCONTROLLER Class that handles communication between the
% client and the server for double-single conversion.

% Copyright 2015-2016 The MathWorks, Inc.

properties(SetAccess = private, GetAccess=private)
    CompatibilityPublishChannel = '/singleconverter/compatibilityresults';
    ConvertPublishChannel = '/singleconverter/convertresults';
    VerifyPublishChannel = '/singleconverter/verifyresults';
    SubscribeChannel
    Data
    Listeners
end

methods
    function this = SingleConverterController
        converterEngine = DataTypeWorkflow.Single.Engine.getInstance;
        this.Listeners = addlistener(converterEngine,'CompatibilityCompletedEvent',@this.updateCompatibilityResultData);
        this.Listeners(2) = addlistener(converterEngine,'ConvertCompletedEvent',@this.updateConversionResultData);
        this.Listeners(3) = addlistener(converterEngine,'VerifyCompletedEvent',@this.updateVerificationResultData);
    end
    
    function updateCompatibilityResultData(this, ~, eventData)
        data = eventData.getData;
        clientData.Message = '';
        clientData.Identifier = '';
        clientData.IncompatibleBlks = [];
        clientData.UnsupportedBlks = [];
        clientData.DTLockedDblBlks = [];
        clientData.SolverSettings = [];
        clientData.DTOSettings = [];
        clientData.TLSSettings = [];
        
        if isfield(data, 'err')
            if isa(data.err, 'MException')
                clientData.Message = data.err.message;
                clientData.Identifier = data.err.identifier;
            end
        end
        
        if isfield(data, 'IncompatibleBlks')
            for i = 1:1:length(data.IncompatibleBlks)
                clientData.IncompatibleBlks(i).Name = data.IncompatibleBlks{i}.ID.getDisplayName;
                clientData.IncompatibleBlks(i).UniqueID = data.IncompatibleBlks{i}.ID.UniqueKey;
                clientData.IncompatibleBlks(i).objectClass = this.getClassFromObject(data.IncompatibleBlks{i}.ID.getObject);          
                clientData.IncompatibleBlks(i).Path = '';
                if ~isempty(data.IncompatibleBlks{i}.ID.getObject)
                    clientData.IncompatibleBlks(i).Path = data.IncompatibleBlks{i}.ID.getObject.getFullName;
                end
            end
        end
        if isfield(data, 'UnsupportedBlks')
            for i = 1:1:length(data.UnsupportedBlks)
                clientData.UnsupportedBlks(i).Name = data.UnsupportedBlks{i}.ID.getDisplayName;
                clientData.UnsupportedBlks(i).UniqueID = data.UnsupportedBlks{i}.ID.UniqueKey;
                clientData.UnsupportedBlks(i).objectClass = this.getClassFromObject(data.UnsupportedBlks{i}.ID.getObject);
                clientData.UnsupportedBlks(i).Path = '';
                if ~isempty(data.UnsupportedBlks{i}.ID.getObject)
                    clientData.UnsupportedBlks(i).Path = data.UnsupportedBlks{i}.ID.getObject.getFullName;
                end
            end
        end
        
        if isfield(data, 'DTLockedDblBlks')
            for i = 1:1:length(data.DTLockedDblBlks)
                clientData.DTLockedDblBlks(i).Name = data.DTLockedDblBlks{i}.ID.getDisplayName;
                clientData.DTLockedDblBlks(i).UniqueID = data.DTLockedDblBlks{i}.ID.UniqueKey;
                clientData.DTLockedDblBlks(i).objectClass = this.getClassFromObject(data.DTLockedDblBlks{i}.ID.getObject);
                clientData.DTLockedDblBlks(i).Path = '';
                if ~isempty(data.DTLockedDblBlks{i}.ID.getObject)
                    clientData.DTLockedDblBlks(i).Path = data.DTLockedDblBlks{i}.ID.getObject.getFullName;
                end
            end
        end
        
        if isfield(data, 'DTOSettings')
        for i = 1:length(data.DTOSettings)
            if isempty(clientData.DTOSettings)
                clientData.DTOSettings = data.DTOSettings{i};
            else
                clientData.DTOSettings(i) = data.DTOSettings{i};
            end
        end
        end
        
        if isfield(data, 'SolverSettings')
        for i = 1:length(data.SolverSettings)
            clientData.SolverSettings(i).System = data.SolverSettings{i}.System;
            clientData.SolverSettings(i).Original = data.SolverSettings{i}.OriginalSolverSetting;
            clientData.SolverSettings(i).Current = data.SolverSettings{i}.AfterSolverSettting;
        end
        end
        
        if isfield(data, 'TLSSettings')
        for i = 1:length(data.TLSSettings)
            clientData.TLSSettings(i).Model = data.TLSSettings{i};
        end
        end
        
        this.Data = clientData; 
        message.publish(this.CompatibilityPublishChannel, this.Data);
    end
    
    function updateConversionResultData(this, ~, eventData)
        data = eventData.getData;
        clientData.Path = '';
        clientData.CompiledDT = '';
        clientData.ProposedDT = '';
        clientData.UniqueID = '';
        clientData.Class = '';
        clientData.objectClass = '';
        for i = 1:length(data.results)
            clientData(i).Path = data.results{i}.getUniqueIdentifier.getDisplayName; %#ok<*AGROW>
            clientData(i).CompiledDT = data.results{i}.getPropValue('CompiledDT');
            clientData(i).ProposedDT = data.results{i}.getProposedDT;
            clientData(i).UniqueID = data.results{i}.getUniqueIdentifier.UniqueKey;
            slObject = data.results{i}.getUniqueIdentifier.getObject;
            clientData(i).objectClass = this.getClassFromObject(slObject);
            icon = data.results{i}.getDisplayIcon;
            [~, filename] = fileparts(icon);
            clientData(i).Class = filename;
        end
        if isempty(data.results)
            clientData = [];
        end
        this.Data = clientData;
        message.publish(this.ConvertPublishChannel, this.Data);
    end
    
    function updateVerificationResultData(this, ~, eventData)
        data = eventData.getData;
        clientData.Message = '';
        clientData.Identifier = '';
        clientData.StowawayDblBlks = [];
        
        for i = 1:1:length(data.StowawayDblBlks)
            clientData.StowawayDblBlks(i).Name = data.StowawayDblBlks{i}.ID.getDisplayName;
            clientData.StowawayDblBlks(i).UniqueID = data.StowawayDblBlks{i}.ID.UniqueKey;
            clientData.StowawayDblBlks(i).objectClass = this.getClassFromObject(data.StowawayDblBlks{i}.ID.getObject);
            clientData.StowawayDblBlks(i).Path = '';
            if ~isempty(data.StowawayDblBlks{i}.ID.getObject)
                clientData.StowawayDblBlks(i).Path = data.StowawayDblBlks{i}.ID.getObject.getFullName;
            end
        end
        if isa(data.err, 'MException')
            clientData.Message = data.err.message;
            clientData.Identifier = data.err.identifier;
        end
        
        this.Data = clientData;
        message.publish(this.VerifyPublishChannel, this.Data);

    end
    
    function delete(this)
        for i = 1:length(this.Listeners)
            delete(this.Listeners(i));
        end
        this.Listeners = [];
    end
end

methods (Hidden)
    function data = getData(this)
        data = this.Data;
    end
end

methods(Access=private)
    function objClass = getClassFromObject(~, object)
        if fxptds.isSFMaskedSubsystem(object)
            object = fxptds.getSFChartObject(object);
        end
        objClass = class(object);
    end
end
        
end

% LocalWords: singleconverter compatibilityresults convertresults
% LocalWords: verifyresults TLSSettings

