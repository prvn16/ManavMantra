function formDataTypeGroups(this)
    % FORMDATATYPEGROUPS this function processes the internal registry of
    % nodes and edges of the interface and produces the connectivity graph
    % that is used to derive the groups in the model. 
    
    % Copyright 2016-2017 The MathWorks, Inc.
	
    % enter all nodes in the universal node map in the graph
    nodeKeys = this.nodes.keys';
    
    % create a table from the cell array
    NodesTable = table(nodeKeys, 'VariableNames', {'Name'});
    
    % enter all edges in the universal edges map in the graph
    % at this point edgesCell is a cell array of cell arrays
    edgesCell = this.edges.values';
    
    % reshape the cell array to be Nx2
    edgesCell = reshape([edgesCell{:}], 2, [])';
    
    % create a table from the cell array
    EdgesTable = table(edgesCell, 'VariableNames', {'EndNodes'});
    
    % initialize the graph using table objects
    this.connectivityGraph = graph(EdgesTable, NodesTable);
    
    % calculate strongly connected components
    bins = conncomp(this.connectivityGraph);
    
	% get unique bins 
    uniqueBins = unique(bins);
    
    % initialize a cell array with all the groups with the proper group IDs
    groups = cell(length(uniqueBins), 1);
    for gIndex = 1:length(uniqueBins)
        groups{gIndex} = fxptds.DataTypeGroup(uniqueBins(gIndex));
        
        % register all the groups in the groups map registry of the data type
        % group interface
        this.addGroup(groups{gIndex});
    end
    
    if ~isempty(uniqueBins)
        % create a group map to register results in the groups as we loop
        % through them, key set is the group IDs cell array, value set is the
        % groups cell array
        groupMap = containers.Map(num2cell(uniqueBins), groups);
        
        % loop through all the nodes and register them to the corresponding
        % groups
        % NOTE: the group ID comes from the algorithm of strongly connected
        % components and is the 'bins' variable
        for index = 1:length(this.nodes)
            
            % get the group we are currently processing
            currentGroup = groupMap(bins(index));
            
            % add the member (AbstractResult) to the group
            currentGroup.addMember(this.nodes(nodeKeys{index}));
            
            % add the member in the reverse result look up map
            % NOTE: the reverse result look up map is used to fetch the group
            % from a given result, this is useful in the deletion workflow and
            % also to retrieve the child-parent relationship between the two
            % entities without introducing any cyclic dependencies
            this.registerResultInLookUpMap(this.nodes(nodeKeys{index}), currentGroup);
            
        end
        
        % set the group related fields on the result, see g1457387
        this.updateResultInfoForGroups();
    end
end