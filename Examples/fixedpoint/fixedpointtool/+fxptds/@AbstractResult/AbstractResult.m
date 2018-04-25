classdef AbstractResult < fxptds.AbstractObject & matlab.mixin.Heterogeneous & matlab.mixin.Copyable
    % ABSTRACTRESULT Class definition of the abstract result class
    
    % Copyright 2012-2017 The MathWorks, Inc.
    
    %% Properties
    properties(SetAccess = protected)
        % the unique identifier of the result
        UniqueIdentifier
        
        % the compiled data type (string)
        CompiledDT = '';
        
        % the specified data type (string): may be different than the
        % compiled data type during Data Type Override
        SpecifiedDT = '';
        
        % alert level of the result (string): may be empty/green, yellow or
        % red
        Alert = '';
        
        % the data type group ID the result belongs to (string): all results
        % are associated with at least one data type group
        DTGroup = '';
        
        % comments populated in the result during the automatic data typing
        % process (cell array)
        Comments = '';
        
        % ranges used in automatic data typing
        SimMin
        SimMax
        DesignMin
        DesignMax
        DerivedMin
        DerivedMax
        CalcDerivedMin
        CalcDerivedMax
        InitialValueMin
        InitialValueMax
        ModelRequiredMin
        ModelRequiredMax
        CompiledDesignMin
        CompiledDesignMax
        
        % combined set of all present ranges
        LocalExtremumSet
        
        % constraints used in automatic data typing
        DTConstraints
        
        % properties not used in automatic data typing (only used for UI
        % purposes, sattelite services etc.)
        IsScaledDouble = false;
        TimeSeriesID = 0;      % ID of the logged signal from the global SDI Engine
        SignalName = '';        % Name of the signal that was logged.
        IsViewOnlyEntry = false;
        IsVisible = true;
        FPTEventHandler
        ActionHandler
        RunObject   % For performance reasons, store a reference to the run object this result belongs to.
        PossibleOverflows = false;
        OverflowMode; % Needed to decide if the possible overflow in Scale Double mode is due to wrap or saturate
        IsReferredByOtherActualSourceID = false; % import/export: to collect data to restore ResultSetForSourceMap
        SubsystemId = '';
        DerivedRangeIntervals
        OverflowWrap
        OverflowSaturation
        DivideByZero
        DerivedRangeState = fxptds.DerivedRangeStates.Unknown;
        WholeNumber =  []
        HistogramData = struct('BinData', [], 'numZeros', 0)
        HasSimMinMax = false
        HasDesignMinMax = false
        HasDerivedMinMax = false
        HasProposedDT = false
        IsPlottable = false
        HasSpecifiedDT = false
        HasOverflowInformation = false
        HasAlert = false
        Accept = false
        ScopingId = ''
        ProposedRange
        RepresentableMin
        RepresentableMax
        IsLocked = false; % Indicates if the specified type on the result is locked
        IsInheritanceReplaceable = false; % Indicates if inheritance rules on specifiedDT are replaceable with proposed dt
    end
    
    properties(GetAccess = protected, SetObservable = true, AbortSet)
        ProposedDT = '';        % Proposed data type for the result.
        SpecifiedDTContainerInfo = SimulinkFixedPoint.DTContainerInfo('',[]);
        EntityAutoscaler;
    end
    
    %% Events
    events
        SetAccept
        UpdatedResultsOnProposedOrApplyChange
        SetProposedDT
    end
    
    %% Methods
    methods
        function this = AbstractResult(data)
            % Class should be able to instantiate with no input arguments
            this@fxptds.AbstractObject;
            
            this.EntityAutoscaler = SimulinkFixedPoint.EntityAutoscalers.AbstractEntityAutoscaler.empty;
            
            initEventHandlers(this);
            if nargin > 0
                if isfield(data, 'uniqueID')
                    this.UniqueIdentifier = data.uniqueID;
                else
                    this.UniqueIdentifier = createUniqueIdentifierForData(this, data);
                end
                this.ActionHandler = createActionHandlerForResult(this, data);
                if isfield(data, 'RunObject')
                    this.setRun(data.RunObject);
                end
                updateResultData(this, data);
            end
        end
        
        function setIsLocked(this, value)
            this.IsLocked = value;
        end
        
        function setDerivedRangeState(this)
            % Update the state to Default when no issues found
            this.DerivedRangeState = fxptds.DerivedRangeStates.Default;
        end
        
        function minVal = get.RepresentableMin(this)
            % Returns the minimum representable value of the proposed data type.
            minVal = '';
            if this.hasProposedDT
                rangeVal = this.ProposedRange;
                minVal = rangeVal(1);
            end
        end
        
        function maxVal = get.RepresentableMax(this)
            % Returns the maximum representable value of the proposed data type.
            maxVal = '';
            if this.hasProposedDT
                rangeVal = this.ProposedRange;
                maxVal = rangeVal(2);
            end
        end
        
        function rangeVal = get.ProposedRange(this)
            % Returns the representable range of the proposed data type.
            rangeVal = '';
            if this.hasProposedDT
                [rmin, rmax] = SimulinkFixedPoint.DataType.getFixedPointRepMinMaxRwvInDouble(eval(this.ProposedDT));
                rangeVal = [rmin, rmax];
            end
        end
        
        function set.SpecifiedDT(this,val)
            if ~isempty(val)
                this.SpecifiedDT = val;
            else
                this.SpecifiedDT = '';
            end
        end
        
        function set.CompiledDT(this,val)
            if ~isempty(val)
                this.CompiledDT = val;
            else
                this.CompiledDT = '';
            end
        end
        
        function set.IsLocked(this, val)
            this.IsLocked = val;
        end
        
        function set.DerivedMin(this, val)
            this.DerivedMin = SimulinkFixedPoint.extractMin(val);
        end
        
        function set.DerivedMax(this, val)
            this.DerivedMax = SimulinkFixedPoint.extractMax(val);
        end
        
        function set.CalcDerivedMin(this, val)
            this.CalcDerivedMin = SimulinkFixedPoint.extractMin(val);
        end
        
        function set.CalcDerivedMax(this, val)
            this.CalcDerivedMax = SimulinkFixedPoint.extractMax(val);
        end
        
        function set.SimMin(this, val)
            this.SimMin = SimulinkFixedPoint.extractMin(val);
        end
        
        function set.SimMax(this, val)
            this.SimMax = SimulinkFixedPoint.extractMax(val);
        end
        
        function set.DesignMin(this, val)
            this.DesignMin = SimulinkFixedPoint.extractMin(val);
        end
        
        function set.DesignMax(this, val)
            this.DesignMax = SimulinkFixedPoint.extractMax(val);
        end
        
        function set.CompiledDesignMin(this, val)
            this.CompiledDesignMin = SimulinkFixedPoint.extractMin(val);
        end
        
        function set.CompiledDesignMax(this, val)
            this.CompiledDesignMax = SimulinkFixedPoint.extractMax(val);
        end
        
        function proposedDT = getProposedDT(this)
            % Gets the proposed data type on the result
            proposedDT = this.ProposedDT;
        end
        
        function name = getElementName(this)
            % Return the name of the element corresponding to this result.
            name = '';
            if ~isempty(this.UniqueIdentifier)
                name = this.UniqueIdentifier.getElementName;
            end
        end
        
        function uniqueID = getUniqueIdentifier(this)
            % Return the identifier that uniquely identifies this result.
            uniqueID = this.UniqueIdentifier;
        end
        
        function b = isPlottable(this)
            %Return true if the result can be plottedOut
            b = this.IsPlottable;
        end
        
        function b = hasDTGroup(this)
            b = ~isempty(this.DTGroup);
        end
        
        function b = hasProposedDT(this)
            %Return true if the object has proposed data type
            b = ~isempty(this.ProposedDT) && ~strcmpi(this.ProposedDT, 'n/a') && ~this.isLocked;
        end
        
        function b = hasApplicableProposals(this)
            %Return true if the proposed data type can be applied to the result
            b = this.Accept && this.hasProposedDT;
        end
        
        function b = hasFixedDT(this)
            %Return true if the compiled data type is a fixed-point type.
            b = fxptds.isFixedPointType(this.CompiledDT) ...
                && ~this.IsScaledDouble;
        end
        
        function b = hasCompiledDT(this)
            %Return true if the compiled data type is not empty
            b = ~isempty(this.CompiledDT);
        end
        
        function b = hasSpecifiedDT(this)
            %Return true if the specified data type is not empty
            b = ~isempty(this.SpecifiedDT);
        end
        
        function b = hasSignalOnly(this)
            % Return true if the result has only signal logging information.
            b = ...
                this.isPlottable && ~this.hasMinMaxInformation;
        end
        
        function b = hasDerivedMinMax(this)
            b = ~isempty(this.DerivedMin) || ~isempty(this.DerivedMax);
        end
        
        function b = hasSimMinMax(this)
            b = ~isempty(this.SimMin) || ~isempty(this.SimMax);
        end
        
        function b = hasOverflows(this)
            % HASOVERFLOWS returns true if any of the overflow properties are non-empty.
            % This includes Wrap, Saturation, DivideByZero and possible
            % overflows in scaled double simulation
            b = ~isempty(this.OverflowWrap) || ~isempty(this.OverflowSaturation) ...
                || ~isempty(this.DivideByZero) || this.PossibleOverflows;
        end
        
        function b = hasIssuesWithDerivedRanges(this)
            % HASISSUESWITHDERIVEDRANGES Inspect the result and find if there is an issue with the derived range
            
            % Mark as true if the result has insufficient ranges or has non-intersecting ranges
            b = this.DerivedRangeState ~= fxptds.DerivedRangeStates.Default;
        end
        
        function setCommentsForDerivedRanges(this)
            % Get current result state
            state = this.DerivedRangeState;
            % Get state's corresponding message code
            msgCode = char(fxptds.DerivedRangeStates.getMessageStringFromState(state));
            if ~isempty(msgCode)
                this.addComment(fxptui.message(msgCode));
            end
        end
        
        function b = hasPossibleOverflows(this)
            b = this.PossibleOverflows;
        end
        
        function b = hasDTConstraints(this)
            % Return true if the result has constraints on the proposed type.
            b =  ~isempty(this.DTConstraints);
        end
        
        function b = isAnyDesignRangeEmpty(this)
            b = isempty(this.DesignMin) ||  isempty(this.DesignMax) || ...
                isempty(this.CompiledDesignMin) || isempty(this.CompiledDesignMax);
        end
        
        function b = isResultValid(this)
            b = false;
            if ~isempty(this.UniqueIdentifier)
                b = this.UniqueIdentifier.isValid;
            end
        end
        
        function b = hasOneChannel(this)
            b = numel(this.TimeSeriesID) == 1 || sum(this.TimeSeriesID ~= 0) == 1;
        end
        
        function b = hasOnlyOneValidChannel(this)
            b = sum(this.TimeSeriesID ~= 0) == 1;
        end
        
        function runName = getRunName(this)
            runName = this.getPropValue('Run');
        end
        
        function b = isWithinProvidedScope(this, systemIdentifierObj)
            % Return true if the result is in the scope of the provided
            % system or model
            b = false;
            if ~isempty(this.UniqueIdentifier)
                b = this.UniqueIdentifier.isWithinProvidedScope(systemIdentifierObj);
            end
        end
        
        function b = isVisible(this)
            b = this.IsVisible;
        end
        
        function parent = getHighestLevelParent(this)
            % Return the highest parent that contains this result
            parent = '';
            if ~isempty(this.UniqueIdentifier)
                parent = this.getUniqueIdentifier.getHighestLevelParent;
            end
        end
        
        function propValue = isValidProperty(~, ~)
            % ME interface needed to display objects
            propValue = true;
        end
        
        function label = getDisplayLabel(this)
            % ME interface to display the name of the object in the list view.
            label = '';
            if ~isempty(this.UniqueIdentifier)
                label = this.UniqueIdentifier.getDisplayName;
            end
        end
        
        function b = hasAlert(this)
            % HASALERT Returns true if the result has an alert.
            
            b = strcmp(this.Alert,'red') || ...
                strcmp(this.Alert,'yellow');
        end
        
        function b = isLocked(this)
            b = this.IsLocked;
        end
        
        function rawData = getTimeseriesData(this)
            % Queries SDI Engine with timeseries id if one exists and gets
            % raw simulation data
            % When no timeseries data is available, empty array is returned
            rawData = [];
            sdiEngine = Simulink.sdi.Instance.engine();
            for i = 1:length(this.TimeSeriesID)
                if sdiEngine.isValidSignalID(this.TimeSeriesID(i))
                    signalObj = sdiEngine.getSignal(this.TimeSeriesID(i));
                    rawData = [rawData;double(signalObj.DataValues.Data(:))]; %#ok<AGROW>
                end
            end
        end
        
        function addScopingId(this, val)
            this.ScopingId = val;
        end
        
        function val = getScopingId(this)
            val = this.ScopingId;
        end
        
        function obj = saveobj(this)
            % return the savable copy of this
            
            obj = this.copy;
            % obj.UniqueIdentifier is handled by saveobj of ID classes
            
            
            obj.FPTEventHandler = [];
            obj.ActionHandler = []; % to be recreated
            obj.RunObject = []; % to be recreated by FPTRun addResult
            obj.TimeSeriesID = []; % to be recreated and assigned from the restore signal logging data
            
            % the following properites are cleaned and not to be restored
            % since they are not used before regeneration, e.g. by
            % autoscaler
            obj.SignalName = [];
            obj.IsVisible = [];
        end
        
        autoscaler = getAutoscaler(this);
        b = hasMinMaxInformation(this);
        b = hasInsufficientRange(this);
        b = hasInterestingInformation(this);
        b = hasFullDesignAndDerivedRange(this);
        b = hasConflictingDesignAndDerivedRangeIntersection(this);
        cm = getContextMenu(this, selectedHandles);
        subsystemId = getSubsystemId(this);
        setProposedDT(this, newDT);
        [isValid, evaluatedNumericType] = validateProposedDT(this, value);
    end
    
    methods(Hidden)
        function val = getPropertyValue(this, prop)
            % Convenience method to get the property value of the result
            val = this.(prop);
        end
        
        function isReferred = getIsReferredByOtherActualSourceID(this)
            % Get the flag to tell whether this result is referred by other results' ActualSourceID
            isReferred = this.IsReferredByOtherActualSourceID;
        end
        
        function flag = getAccept(this)
            flag = this.Accept;
        end
        
        function setIsReferredByOtherActualSourceID(this, isReferred)
            % Set the flag to tell whether this result is referred by other results' ActualSourceID
            this.IsReferredByOtherActualSourceID = isReferred;
        end
        
        function setAccept(this, flag)
            this.Accept = flag;
        end
        
        function firePropertyChange(this)
            ed = DAStudio.EventDispatcher;
            ed.broadcastEvent('PropertyChangedEvent', this);
        end
        
        function isReplaceable = isInheritanceReplaceable(this)
            isReplaceable = this.IsInheritanceReplaceable;
        end
        
        computeIfInheritanceReplaceable(this)
        
        function u = combineIFsame(~, u)
            % This function receives a vector of length 2, if
            % both values are equal, then return the value, if
            % not, return the original vector.
            if numel(u)==2 && u(1)==u(2)
                u = u(1);
            end
        end
        
        function RangeFactor = SafetyMargin2RangeFactor(~, SafetyMargin)
            % RangeFactor vs SafetyMargin
            %
            % RangeFactor and SafetyMargin are alternate ways to specify how much extra
            % range the user wants beyond the maximum and minimum values.
            % The relationship between RangeFactor and SafetyMargin are given in
            % the helper function below.
            
            RangeFactor = 1 + (SafetyMargin/100);
        end
        
        function updateAcceptFlag(this)
            % Update the accept flag on the result based on the specified &
            % proposed data types
            this.Accept = false;
            if this.hasProposedDT && ~strcmp(this.SpecifiedDT,this.ProposedDT)
                this.Accept = true;
            end
        end
        
        function updateAcceptFlagPostApply(this)
            % Update the accept flag on the result based on the specified &
            % proposed data types
            this.Accept = false;
            if this.hasProposedDT && ~strcmp(this.SpecifiedDT,this.ProposedDT)
                this.Accept = true;
            end
        end
        
        function batchSetAccept(this, flag)
            notify(this,'SetAccept', fxptds.FPTEvents.AcceptDTEvent(flag));
        end
        
        function batchSetProposedDT(this, proposedDT)
            notify(this,'SetProposedDT', fxptds.FPTEvents.ProposedDTEvent(proposedDT));
        end
        
        function updateVisibility(this)
            this.IsVisible = this.hasInterestingInformation;
        end
        
        function addComment(this, comment)
            % Update the comments on the result
            if isempty(comment); return; end
            if ~iscell(comment)
                comment = {comment};
            end
            if isempty(this.Comments)
                this.Comments = comment;
            else
                this.Comments(end+(1:numel(comment))) = comment;
                this.Comments = unique(this.Comments);
            end
        end
        
        function b = needsAttention(this)
            % Return true if the result has an flag from the data type
            % proposal phase.
            b = this.Accept && strcmpi(this.Alert,'red');
        end
        
        function comments = getComment(this)
            comments = this.Comments;
        end
        
        function sDT = getSpecifiedDT(this)
            sDT = this.SpecifiedDT;
        end
        
        function tsID = getTimeSeriesID(this, index)
            tsID = 0;
            if nargin < 2
                tsID = this.TimeSeriesID;
            else
                if numel(this.TimeSeriesID) >= index
                    tsID = this.TimeSeriesID(index);
                end
            end
        end
        
        function name = getSignalName(this, index)
            name = '';
            if nargin < 2
                name  = this.SignalName;
            else
                if numel(this.SignalName) >= index
                    name = this.SignalName{index};
                end
            end
        end
        
        function actionHandler = getActionHandler(this)
            actionHandler = this.ActionHandler;
        end
        
        function constraints = getConstraints(this)
            constraints = this.DTConstraints;
        end
        
        function localExtremum = getLocalExtremum(this)
            localExtremum = this.LocalExtremumSet;
        end
        
        function val = getCompiledDT(this)
            val = this.CompiledDT;
        end
        
        function val = getOverflowWrap(this)
            val = this.OverflowWrap;
        end
        
        function val = getOverflowSaturation(this)
            val = this.OverflowSaturation;
        end
        
        function val = getDivideByZero(this)
            val = this.DivideByZero;
        end
        
        function val = getOverflowMode(~)
            val = 'saturate';
        end
        
        function val = getSpecifiedDTContainerInfo(this)
            val = this.SpecifiedDTContainerInfo;
        end
        
        function val = getProposedDTContainerInfo(this)
            val = [];
            if this.hasProposedDT
                val = SimulinkFixedPoint.DTContainerInfo(this.ProposedDT, []);
            end
        end
        
        function runObj = getRunObject(this)
            runObj = this.RunObject;
        end
        
        function setSpecifiedDTContainerInfo(this, value)
            this.SpecifiedDTContainerInfo = value;
        end
        
        function setSpecifiedDataType(this, datatype)
            this.SpecifiedDT = datatype;
            % Cache state for performance.
            this.HasSpecifiedDT = this.hasSpecifiedDT;
        end
        
        function setDTConstraints(this, dtConstraint)
            % Set the data type constraints on the result
            this.DTConstraints = dtConstraint;
        end
        
        function setLocalExtremumSet(this, extremumRange)
            % Set the extremum set computed by the autoscaling engine on the
            % result.
            this.LocalExtremumSet = extremumRange;
        end
        
        function setDesignRange(this, minVal, maxVal)
            % Set the design min/max information on the result.
            this.DesignMin = SimulinkFixedPoint.extractMin(minVal);
            this.DesignMax = SimulinkFixedPoint.extractMax(maxVal);
            this.HasDesignMinMax = false;
            if ~isempty(this.DesignMin) || ~isempty(this.DesignMax)
                this.HasDesignMinMax = true;
            end
        end
        
        function setAsReadOnly(this, flag)
            this.IsViewOnlyEntry = flag;
        end
        
        function setAlert(this, alert)
            this.Alert = alert;
            % Cache away for performance
            this.HasAlert = this.hasAlert;
        end
        
        function alert = getAlert(this)
            alert = this.Alert;
        end
        
        function setDTGroup(this, grp)
            this.DTGroup = grp;
        end
        
        function dtGroup = getDTGroup(this)
            dtGroup = this.DTGroup;
        end
        
        function setTimeSeriesID(this, tsSignalID)
            if numel(this.TimeSeriesID) == 1 && ~this.isPlottable
                this.TimeSeriesID = tsSignalID;
            else
                this.TimeSeriesID = [this.TimeSeriesID tsSignalID];
            end
            this.IsPlottable = true;
        end
        
        function setRun(this, runObj)
            this.RunObject = runObj;
        end
        
        function setVisibility(this, visibility)
            this.IsVisible = logical(visibility);
        end
        
        function b = isReadOnly(this)
            b = this.IsViewOnlyEntry;
        end
        
        function val = isScaledDoubleType(this)
            val = this.IsScaledDouble;
        end
        
        extremumSet = getExtremaSim(this, SafetyMarginForSimMinMax);
        extremumSet = getExtremaDerived(this, extremumSet);
        setDerivedRange(this, minVal, maxVal);
        value = getPropValue(this, propName);
        b = isReadonlyProperty(this, propName);
        updateResultData(this, data);
        setPropValue(this, propName, propVal);
        wasUpdated = clearSignalForID(this, signalID);
        updateTimeSeriesInformation(this, sdiSignal);
        clearProposalData(this);
        clearDerivedRangeData(this);
        clearInstrumentationData(this);
        clearSignalLogData(this);
        
    end
    
    methods(Access=protected)
        function extremumSet = getExtremumSet(this, proposalSettings)
            
            extremumSet = SimulinkFixedPoint.AutoscalerUtils.unionRange(this.DesignMin, this.DesignMax);
            extremumSet = this.combineIFsame(extremumSet);
            noDesignRange = false;
            % Empty extremumSet indicates no design min/max available
            if isempty(extremumSet)
                noDesignRange = true;
            end
            
            % use Sim Min/Max if isUsingSimMinMax is set
            % this function applies the safety margin on the ranges
            if noDesignRange && proposalSettings.isUsingSimMinMax
                extremumSet = this.getExtremaSim(proposalSettings.SafetyMarginForSimMinMax);
            end
            
            % use Derived Min/Max if it is available
            if noDesignRange && (slsvTestingHook('RAviaRTWTesting') == 0) && proposalSettings.isUsingDerivedMinMax
                extremumSet = this.getExtremaDerived(extremumSet);
            end
        end
        
        function setLocalExtremum(this, rangeVector)
            [curMin, curMax] = SimulinkFixedPoint.extractMinMax(rangeVector);
            rangeVector = this.combineIFsame([curMin curMax]);
            
            % set the local extremum (range) to be the combination of all
            % applicable and available ranges
            this.setLocalExtremumSet(rangeVector);
            
        end
        
        function initEventHandlers(this)
            this.FPTEventHandler = fxptds.FPTEventHandler(this);
        end
        
    end
    
    methods (Sealed = true)
        function list = findobj(this, varargin)
            list = findobj@handle(this, varargin{:});
        end
    end
    
    methods(Static)
        function obj = loadobj(this)
            if this.UniqueIdentifier.isValid
                
                this.initEventHandlers;
                % this.runObject is set by FPTRun addResult
                
                % this.ActionHandler property is restored in the derived classes
                
                % TODO: restore TimeSeriesID -- signal logging
            end
            obj = this;
        end
    end
    
    methods(Abstract)
        icon = getDisplayIcon(this);
        calculateRangesForResult(this, proposalSettings);
    end
    
    methods(Access=protected, Abstract)
        uniqueID = createUniqueIdentifierForData(this, data);
        actionHandler = createActionHandlerForResult(this, data);
    end
end

% LocalWords: RAvia
