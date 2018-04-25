classdef DataTypeGroup < handle
    % DATATYPEGROUP The class of DataTypeGroup is a class that provides a layer of
    % abstraction for aggregating results and performing operations on
    % them. In the automatic data typing workflow, it is often the case
    % when a group of results need to be treated in the same way due to
    % connectivity of the model or connectivity via data objects. This
    % layer provides the layer of abstraction to capture the set operations
    % that need to happen under this scope. 
    % A set of results, or group, is defined in this class as a set of 1 or
    % more results that require the same data type handling. Between the
    % group, the ranges of the members are consolidated, forming a
    % unionized full range that is used for proposal. Additionally, any
    % constraints that any member may carry, is propagated to the group
    % and consolidated in a larger scope, across the group. Finally, the
    % specified data types of the members are also consolidated at the
    % group level. 
    % This class provides a registration common interface gateway in order
    % to extract any necessary information from the members; different sets
    % of data are extracted using the interface by registration interface
    % classes that are responsible for the transaction. The class of
    % DataTypeGroup is actually agnostic of how many interfaces are being
    % registered by the user and how to process any of the members. 
    % After registration, the group may be queried for high level
    % information about the group members. Currently the supported APIs
    % that provide high level information about the members provide
    % information about the unionized range of the group, consolidated
    % constraints of the group and the consolidated specified data type of
    % the group. These APIs operate in a dynamic fashion as the do not
    % store any state of the final asnwer; any time the group will be
    % queried for the unionized range, we will calclulate the unionized
    % range on the fly. This is a desicion made to facilitate a more
    % dynamic and fluid behavior of the group, trading off performance. In
    % order to safeguard against any performance cost, the client of the
    % group should make sure to store any important values, returned by
    % these APIs. Additionally, these APIs are often dependent on the
    % proposal settings used at the workflow and hence storing the result
    % would cause a host of synchronization issues. 
	
    %   Copyright 2016-2017 The MathWorks, Inc.
    
    properties(SetAccess = private)
        id        
        ranges cell = cell.empty()        
        constraints SimulinkFixedPoint.AutoscalerConstraints.AbstractConstraint = SimulinkFixedPoint.AutoscalerConstraints.AbstractConstraint.empty()        
        initialSpecifiedDataTypes SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer = SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer.empty()
        finalProposedDataType SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer = SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer.empty()        
        members containers.Map = containers.Map.empty()
    end
    
    properties(SetAccess = private, GetAccess = private)
        registrationInterface cell = cell.empty()
    end
    
    methods(Access = public)
        function this = DataTypeGroup(id)
            this.id = id;
            this.initializeRanges();
            this.initializeConstraints();
            this.initializeRegistrationInterface();
            this.members = containers.Map();
        end
        
        addMember(this, result)
        deleteMember(this, result)
        addRange(this, rangeType, newMinExtremum, newMaxExtremum)
        addConstraints(this, dataTypeConstraints)
        addDataType(this, dataTypeStr)
        
        rangeForProposal = getRangeForProposal(this, proposalSettings)
        specifiedDataType = getSpecifiedDataType(this, proposalSettings)
        setFinalProposedDataType(this, finalProposedDataType, topSubSystemToScale, proposalSettings)
        groupMembers = getGroupMembers(this)
        determineWarnings(this, proposalSettings)
        updateFinalProposedDataType(this, newDataType, proposalSettings)
    end
    
    methods(Access=private)
        initializeRanges(this)
        initializeConstraints(this)
        initializeRegistrationInterface(this)
        successfulProposal = proposeDataType(this, resultsScope, result, proposedDataType, proposalSettings)
        specialHandlingDT = specialHandlingForResults(~, result, resultsScope, proposalSettings, proposedDataType)
        propagateAlertLevel(this, finalAlertLevel)
    end
end