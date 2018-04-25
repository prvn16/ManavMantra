classdef DataTypeGroupInterface < handle
    %DATATYPEGROUPINTERFACE is an interface between the FPTRun class and
    %the DataTypeGroup class. The class provides three public APIs to be
    %used by the FPTRun to interract with the data type groups that are
    %registered during collection phase. The interface also provides a
    %reverse look up infrastructure for the results to find the group that
    %a result belongs to, providing an indirect link between parent and
    %child.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties(SetAccess = private, GetAccess = public)
        reverseResultLookUp containers.Map = containers.Map.empty()
        dataTypeGroups containers.Map = containers.Map.empty()
        nodes containers.Map = containers.Map.empty()
        edges containers.Map = containers.Map.empty()
        connectivityGraph 
    end
    
    methods(Access = public)
        function this = DataTypeGroupInterface()
            this.reverseResultLookUp = containers.Map();
            this.dataTypeGroups = containers.Map();
            this.nodes = containers.Map();
            this.edges = containers.Map();
            this.connectivityGraph = graph();
        end
        
        delete(this)
        formDataTypeGroups(this)
        addNode(this, node)
        addEdge(this, nodeA, nodeB)
        dataTypeGroup = getGroupForResult(this, result)
        dataTypeGroups = getGroups(this)
        addGroup(this, dataTypeGroup)
        clear(this)
        deleteResultFromGroup(this, result)
        updateResultInfoForGroups(this) % see g1457387
    end
    
    methods(Access = public, Hidden)
        registerGroupInLookUpMap(this, dataTypeGroup)
        registerResultInLookUpMap(this, result, dataTypeGroup)
    end
    
end

