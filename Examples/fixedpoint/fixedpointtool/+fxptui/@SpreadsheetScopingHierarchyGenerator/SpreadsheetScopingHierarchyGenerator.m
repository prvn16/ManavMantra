classdef SpreadsheetScopingHierarchyGenerator < handle
    % SPREADSHEETSCOPINGHIERARCHYGENERATOR Class that generates a
    % hierarchical result structure for a given model to help the scoping
    % of results in the web app.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    
    properties (SetAccess = private, GetAccess = private)
       ResultScopingMap 
       TreeData
       TreeHierarchyCache
       AddedTreeData
       UnresolvedVariantHierarchy
       InitialHiearchyFound
    end
    
    methods
        function this = SpreadsheetScopingHierarchyGenerator(model, scopingTable)
            this.ResultScopingMap = containers.Map('KeyType','char','ValueType','any');
            this.TreeData = fxptui.TreeData(model);
            if ~isempty(scopingTable)
                this.TreeHierarchyCache = this.TreeData.generateMapping;
            end
            [~, this.InitialHiearchyFound] = generateMappingForTable(this, scopingTable);
        end
        
        % Generate the subsystemID/result mapping. This only uses the
        % changeset to add/modify mapping.
        [map, hierarchyStruct] = generate(this, changesetTable);
        
        % Generate the subsystemID/result mapping based on the entire
        % scoping table. This is used to get updated mappings when runs are
        % renamed.
        [map, hierarchyStruct] = regenerateOnEntireTable(this, scopingTable); 
        
        % Get the child subsystem Ids for a given Subsystem ID
        subsysIds = getChildIds(this, subsystemID);
                
    end  
    
    methods (Access = private)   
        % Generate the mapping from the table. Detect any additional
        % updates on the tree.
        [map, filteredHierarchyStuct] = generateMappingForTable(this, scopingTable);
               
        % Update the mapping based on the result set.
        addResultIdsToMap(this, subKey, resultIds, subsysRows);
        
        % Determine if the subsystem ID belongs to the model or its
        % refereced models.
        ismember = isIDMemberOfCurrentModel(this, subsystemID);
        
        % Update the hierarchy based on detected hierarchy information from
        % table.
        hierarchyStruct = addToTreeCache(this, hierarchyStruct);
        
        % Get combined result set based on ids.
        resultSet = getResultSetForIDs(this, ids);
        
        % Return hierarchy that needs to be carried over after variane
        % creation.
        unresolvedHierarchy = getUnresolvedHierarchyAfterVariantCreation(this, clientIDs)
                                   
        % Update mapping of all ancestors of a subsystem ID.
        updateMappingOfAllAncestors(this, modelMap, parentKey, resultIDs, subsysRows)        
        
        % Unify result sets across MATLAB functions
        unifyResultMappingForMATLABFunctions(this);       
    end
    
    methods (Hidden)
        % Update the result mapping due to variant subsystem creation.
        updateMappingForVariantAddition(this, updatedTreeArray);   
    end
end
