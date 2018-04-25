classdef AutoscalerMetaData < handle
% AUTOSCALERMETADATA Class to handle the additional information needed by the Autoscaler Engine to determine data type proposals.
    
% Copyright 2012-2017 The MathWorks, Inc.
    
    properties (Hidden, SetAccess = private, GetAccess = private)
        ResultSetForSourceMap    % Mapping between a list of results and a source.
        InternalDerivedRangeMap   % Mapping between derived range data tag and range data 
    end
     
    properties (Hidden, SetAccess = private, GetAccess = private)
        busObjectHandleMap  % Mapping between name of the bus objects and bus object handle      
        MLFBResultsMap
    end
     
    methods
        % ------------- constructor --------------------------------------
        function this = AutoscalerMetaData
            this.ResultSetForSourceMap = Simulink.sdi.Map(char('a'),?handle);%java.util.LinkedHashMap;
            this.InternalDerivedRangeMap = Simulink.sdi.Map(char('a'),?handle);
            this.busObjectHandleMap = SimulinkFixedPoint.BusObjectHandleMap;
            this.MLFBResultsMap = Simulink.sdi.Map(char('a'), ?handle);
        end
        
        % ------------- bus object handle map-----------------------------
        setBusObjectHandleMap(this,map)           
        map = getBusObjectHandleMap(this)
  
        % -----------------MLFB Results Map -------------------------------
        setMLFBResultsMap(this, value)
        MLFBResultsMap = getMLFBResultsMap(this)
        
        % ------------- Source blk map reported interface ----------------
        resStruc = getResultListForAllSources(this)
        resList = getResultListForSource(this, source)
        setResultSetForSource(this, source, resultSet)
        resultSet = getResultSetForSource(this, source)
        resStruc = getResultSetsForAllSources(this)
        
        % ---------- clear and removal function -------------------------
        clearResultListForAllSources(this)
        res = getInternalDerivedRangeData(this, internalID)
        addInternalDerivedRangeData(this, internalID, data)
        clearInternalDerivedRangeData(this)
        clear(this)
        deleteData(this)
        
    end
    
    methods(Hidden)
        updateFromMetaData(this, otherMetaData)
        
    end

end

% LocalWords:  setlist blklist setblklist
