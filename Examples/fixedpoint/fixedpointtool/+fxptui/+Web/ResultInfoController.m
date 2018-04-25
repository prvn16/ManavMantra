classdef ResultInfoController < handle
    %% ResultInfoController class definition of the Result Details.
    
    %   Copyright 2013-2017 The MathWorks, Inc.
    
    properties (Access = 'private')
        ApplicationURL='toolbox/fixedpoint/fixedpointtool/web/resultdetailsdialog/index.html';
        Subscriptions; % Unsubscribe during deletion
        %Channel to publish Data
        SubscribeChannel = '/slfxp_testchannel_';
        PublishChannel = '/slfxp_webchannel_';
        RowSelectionSubscription = '/fpt/spreadSheet/dataRowSelection';
        Data; %Data element which would be send to the client side
    end
    
    methods
        %%
        function this = ResultInfoController(clientID)
            % ResultInfoController: Constructor
            % initialize the URL & the message subscription channel &
            % callback.
            connector.ensureServiceOn;
            if nargin > 0
                this.SubscribeChannel = sprintf('%s/%s',this.SubscribeChannel,clientID);
                this.RowSelectionSubscription = sprintf('%s/%s',this.RowSelectionSubscription,clientID);
            end
            
            if(isempty(this.Subscriptions))
                this.Subscriptions{1} = message.subscribe(this.SubscribeChannel, @(msg)publishData(this,msg));
                this.Subscriptions{2} = message.subscribe(this.RowSelectionSubscription, @(msg)sendDataForRowSelection(this,msg));
            end
        end
        
        function publishData(this,~)
            % Publish the data to the client (JS) via connector.
            message.publish(this.PublishChannel,this.getData);
            
        end
        
        function publishDataForResult(this, result)
            % When data is changed on the server from the client, we need
            % to udpate the selected result.
            this.packageData(result);
            this.publishData;
        end
        
        function data = getData(this)
            % API to return the cached data.
            if(isempty(this.Data))
                data = '';
            else
                data = this.Data;
            end
        end
        
        function cleanup(this)
            % Destructor
            % initialize data to empty, unsubscribe the msg subscription &
            % initialize the subscription string to empty.
            this.Data = '';
            for i = 1:numel(this.Subscriptions)
                message.unsubscribe(this.Subscriptions{i});
            end
            this.Subscriptions = '';
        end
        
        function delete(this)
            this.cleanup;
        end
        
        function appURL = getApplicationURL(this)
            % get the application url for the result details
            appURL = this.ApplicationURL;
        end
        
        function packageData(this, result)
            %Collect the result information and populate the "Data"
            %element in the structure which would be later send to the client
            isInvalid = false;
            if isempty(result) || ~isa(result,'fxptds.AbstractResult')
                this.Data = '';
                return;
            else
                % If the subsystem containing the block corresponding to
                % the result is deleted, the fxptds.isResultValid and
                % result.getUniqueIdentifier.isValid continue to return
                % true. The FullName of the block inside the deleted
                % substsystem will not contain the built-in/ or deleted/
                % strings (see g1561716).
                try
                    highestParent = result.getHighestLevelParent;
                    if isempty(highestParent)
                        isInvalid = true;
                    end
                catch
                    isInvalid = true;
                end
                
                if isInvalid
                    this.Data = '';
                    this.Data.isResultInvalid = true;
                    return;
                end
            end
            
            % collect all the diagnostics (errors and warnings) for the
            % selected result
            [errors, warnings] = SimulinkFixedPoint.AutoscalerAlertsUtil.collectDiagnosticsForResult(result);
            
            
            
            autoApplyFeature = slfeature('FPTMATLABFunctionBlockFloat2Fixed');
            
            % get the application data from result
            appData = SimulinkFixedPoint.getApplicationData(result.getHighestLevelParent);
            
            if result.hasDTGroup
                % get the run object
                runObj = appData.dataset.getRun(result.getRunName);
                % get the group that the result is registered to
                group = runObj.dataTypeGroupInterface.getGroupForResult(result);
            else
                % if the result doesn't have a group, initialize the group
                % object with an empty entry
                group = fxptds.DataTypeGroup.empty();
            end
            this.Data =  struct( ...
                'ResultName',result.getUniqueIdentifier.getDisplayName,...
                'Comment',{ result.getComment },...
                'collectConstrainedDTSummary',false,...
                'CompiledDTString',result.getPropValue('CompiledDT') ,...
                'classOfResultObject',class(result),...
                'CompiledDT',result.getCompiledDT,...
                'CalcDerivedMin',compactButAccurateNum2Str(result.CalcDerivedMin),...
                'CalcDerivedMax',compactButAccurateNum2Str(result.CalcDerivedMax),...
                'DisplayName',result.getUniqueIdentifier.getDisplayName,...
                'DesignMin',compactButAccurateNum2Str(result.DesignMin),...
                'DesignMax',compactButAccurateNum2Str(result.DesignMax),...
                'DTGroup',result.getDTGroup,...
                'DerivedMin',compactButAccurateNum2Str(result.DerivedMin),...
                'DerivedMax',compactButAccurateNum2Str(result.DerivedMax),...
                'DerivedRangeState' , result.DerivedRangeState,...
                'hasOverflows',result.hasOverflows,...
                'hasProposedDT',result.hasProposedDT,...
                'hasDTGroup',result.hasDTGroup,...
                'hasDTConstraints',result.hasDTConstraints,...
                'isAbstractSimulinkResult', isa(result,'fxptds.AbstractSimulinkResult'),...
                'InitialValueMin', compactButAccurateNum2Str(result.InitialValueMin),...
                'InitialValueMax', compactButAccurateNum2Str(result.InitialValueMax),...
                'ModelRequiredMin', compactButAccurateNum2Str(result.ModelRequiredMin),...
                'ModelRequiredMax', compactButAccurateNum2Str(result.ModelRequiredMax),...
                'ProposedDT',result.getProposedDT,...
                'ProposedDTString',result.getPropValue('ProposedDT') ,...
                'RunName', result.getRunName,...
                'SharedDesignMin','',...
                'SharedDesignMax','',...
                'SharedDerivedMin','',...
                'SharedDerivedMax','',...
                'SharedSimMin','',...
                'SharedSimMax','',...
                'SharedInitValueMin','',...
                'SharedInitValueMax','',...
                'SharedModelRequiredMin','',...
                'SharedModelRequiredMax','',...
                'isUsingSimMinMax',appData.AutoscalerProposalSettings.isUsingSimMinMax,...
                'isUsingDerivedMinMax',appData.AutoscalerProposalSettings.isUsingDerivedMinMax,...
                'SpecifiedDT',result.getSpecifiedDT,...
                'SimMin',compactButAccurateNum2Str(result.SimMin),...
                'SimMax',compactButAccurateNum2Str(result.SimMax),...
                'SpecifiedDTString',result.getPropValue('SpecifiedDT') ,...
                'Alert',result.getAlert, ...
                ...% Send the status of the auto apply feature to build appropriate links
                'MLFBAutoApply', autoApplyFeature,...
                ...% below 5 properties are used for getConstrainedDT Information.
                'immediateOwner', '',...
                'sourceBlockClass', '',...
                'sourceBlockName', '',...
                'sourcePort', '',...
                'constraintSetComments', {''}, ...
                'Histogram', [], ...
                'HighLevelSummary', {{}}, ...
                'IsDataObjectResult', false, ...
                'HighlightSharedElements', false);
            
            
            [this.Data.IsInSubsysToScale, this.Data.BlkOutofSysStr] = this.isResultInSubsysToScale(result);
            
            this.Data.SlopeBias = fxptds.Utils.isBinaryPointForSlopeBiasDT(result);
            
            % if there are any errors, populate the necessary field in the
            % data struct
            if ~isempty(errors)
                this.Data.Errors = errors;
            end
            
            % if there are any warnings, populate the necessary field in the
            % data struct
            if ~isempty(warnings)
                this.Data.Warnings = warnings;
            end
            if ~isempty(group)
                % get all the range types that participate in warnings
                rangeTypes = SimulinkFixedPoint.AutoscalerAlertsUtil.getRangeTypesForWarnings();
                
                for rangeTypeIndex = 1:numel(rangeTypes)
                    % get the current range
                    extrema = group.ranges{fxptds.RangeType.getIndex(rangeTypes{rangeTypeIndex})}.getExtrema();
                    
                    % if the group has a valid range, copy over to the
                    % packaged data
                    if ~isempty(extrema)
                        minExtremumStr = ['Shared' this.getRangeString(rangeTypes{rangeTypeIndex}) 'Min'];
                        this.Data.(minExtremumStr) = compactButAccurateNum2Str(extrema(1));
                        
                        maxExtremumStr = ['Shared' this.getRangeString(rangeTypes{rangeTypeIndex}) 'Max'];
                        this.Data.(maxExtremumStr) = compactButAccurateNum2Str(extrema(2));
                    end
                end
            end
            
            if isa(result,'fxptds.MATLABVariableResult')
                this.Data.Complexity = result.Complex;
                this.Data.Size = result.Size ;
                this.Data.Scope = result.Scope;
                if(isempty(result.Fimath))
                    this.Data.Fimath = '';
                else
                    this.Data.Fimath = result.Fimath.tostring;
                end
            end
            
            this.setIsDataObjectResult(result);
            this.setHighLevelSummary(result);
            this.setHighlightSharedElements(result, group);
            
            % TODO: getConstrainedInformation always returns an empty string. Necessary
            % changes will be made as a part of g1371332.
            this.Data.constraintMessage = this.getConstrainedInformation(result);
            
            % get the range and precision for proposedDT
            [proposeDtMin,proposeDtMax,proposeDtPrecision] = this.getRangeAndPrecisionInformation(result.getProposedDT);
            ProposedDTRangeAndPrecision.Minimum = compactButAccurateNum2Str(proposeDtMin);
            ProposedDTRangeAndPrecision.Maximum = compactButAccurateNum2Str(proposeDtMax);
            ProposedDTRangeAndPrecision.Precision = compactButAccurateNum2Str(proposeDtPrecision);
            this.Data.ProposedDTRangeAndPrecision = ProposedDTRangeAndPrecision;
            
            % is signedness specified or is set to 'auto'.
            this.Data.isSignednessUnspecified = this.getSignednessOfSpecifiedDT(result.getSpecifiedDT);
            
            % get the range and precision for specifiedDT
            [specifiedDTMin, specifiedDTMax, specifiedDTPrecision] = this.getRangeAndPrecisionInformation(result.getSpecifiedDT);
            SpecifiedDTRangeAndPrecision.Minimum = compactButAccurateNum2Str(specifiedDTMin);
            SpecifiedDTRangeAndPrecision.Maximum = compactButAccurateNum2Str(specifiedDTMax);
            SpecifiedDTRangeAndPrecision.Precision = compactButAccurateNum2Str(specifiedDTPrecision);
            this.Data.SpecifiedDTRangeAndPrecision = SpecifiedDTRangeAndPrecision;
            
            % get the range and precision for compiledDT
            [compiledDTMin, compiledDTMax, compiledDTPrecision] = this.getRangeAndPrecisionInformation(result.getCompiledDT);
            CompiledDTRangeAndPrecision.Minimum = compactButAccurateNum2Str(compiledDTMin);
            CompiledDTRangeAndPrecision.Maximum = compactButAccurateNum2Str(compiledDTMax);
            CompiledDTRangeAndPrecision.Precision = compactButAccurateNum2Str(compiledDTPrecision);
            this.Data.CompiledDTRangeAndPrecision = CompiledDTRangeAndPrecision;
            
            % package histogram data
            this.computeHistogramData(result);
        end
    end
    
    methods(Access = 'private')
        function setIsDataObjectResult(this, result)
            % Default value for IsDataObjectResult is false. If the result is a data
            % object result, set it to true.
            if isa(result,'fxptds.AbstractSimulinkObjectResult')
                this.Data.IsDataObjectResult = true;
            end
        end
        
        function setHighlightSharedElements(this, result, group)
            %setHighlightShatedElements sets a boolean flag on the property
            %highlightSharedElements of this.Data.
            %
            %The value is true if a result belongs to a group and at least one result in
            %the group is not a data object result.
            
            this.Data.HighlightSharedElements = false;
            if result.hasDTGroup
                groupMembers = group.members.values;
                for ii = 1:numel(groupMembers)
                    if ~isa(groupMembers{ii},'fxptds.AbstractSimulinkObjectResult')
                        this.Data.HighlightSharedElements = true;
                        break;
                    end
                end
            end
        end
        
        function rangeTypeString = getRangeString(~, rangeType)
            switch(rangeType)
                case fxptds.RangeType.Initial
                    rangeTypeString = 'InitValue';
                otherwise
                    rangeTypeString = fxptds.RangeType.getString(rangeType);
            end
        end
        function computeHistogramData(this, result)
            %% COMPUTEHISTOGRAMDATA function computes the data required for rendering Simulation Data Histogram of  a result in ResultDetailsDialog
            % It appends a 'Histogram' struct to mData (member Variable) which
            % contains details of xMin, xMax, histogram bins, counts of
            % positive and negative values in each bin, # of bins overflowing
            % and underflowing
            %
            % result is an instance of fxptds.Result
            mData = struct();
            % get HistogramData
            
            % g1463717 Replace "fetch histogram data from
            % instrumentation or timeseries" logic to
            % fxptds.Utils.getHistogramData API (which has identical
            % implementation.
            histogramData = fxptds.Utils.getHistogramData(result);
            if ~isempty(histogramData) && ~isempty(histogramData.BinData)
                % g1463717 -  trim outlier bins to ensure only bins
                % > -129 and < 128 are visualized in Result Details
                % Dialog
                histogramData.BinData = ...
                    fxptds.HistogramUtil.consolidateOutlierBinData(histogramData.BinData);
                
                % get container type information of the result
                [dtContainerInfo, allContainerTypes] = fxptds.Utils.getContainerType(result);
                
                histogramBins = histogramData.BinData;
                
                % HistogramData.BinData = nx3 int32 array where
                % 1st col = bin
                % 2nd col = # positive values observed in a bin
                % 3rd col = # negative values observed in a bin
                % get first column for bin information
                histogramBins = histogramBins(:,1);
                
                allRanges = fxptds.Utils.getRanges(result);
                simRange = allRanges.Sim;
                
                % get OverflowBins information using containerType and
                % histogramBins
                overflowBins = fxptds.HistogramUtil.getOverflowBins(dtContainerInfo, histogramBins, simRange);
                
                % getUnderflowBins information using containerType,
                % histogramBins and simMin
                underflowBins = fxptds.HistogramUtil.getUnderflowBins(dtContainerInfo, histogramBins, simRange);
                
                histogram = double(histogramData.BinData);
                
                % xMin = min of given histogram bins, xMax = max of
                % given histogram bins
                xMin = min(histogram(:,1));
                xMax = max(histogram(:,1));
                
                % Find total number of occurrences
                mData.TotalOccurrences = sum(sum(histogram(:,2:3))) + histogramData.numZeros;
                
                % Add details on number of times zero occurred as a
                % value during simulation
                mData.NumZeros = histogramData.numZeros;
                sumOfAllOccurrences= mData.TotalOccurrences;
                
                % Add details on positive and negative bin counts
                mData.PosCounts = histogram(:,2);
                mData.NegCounts = histogram(:,3);
                
                % Normalize # positive value counts and negative value
                % count per bin to the total number of occurrences
                histogram(:, 2) = 100*(histogram(:,2)/sumOfAllOccurrences);
                histogram(:, 3) = 100*(histogram(:,3)/sumOfAllOccurrences);
                
                % Aggregate all data into mData
                mData.LastOver = xMax;
                mData.LastUnder = xMin;
                mData.BinEdges = histogram(:,1);
                mData.BinCounts = histogram(:,2) + histogram(:,3);
                mData.PosBinCounts = histogram(:,2);
                mData.NegBinCounts = histogram(:,3);
                mData.OverflowBins = overflowBins;
                mData.UnderflowBins = underflowBins;
                mData.ActualOverflows = ~isempty(result.OverflowWrap) || ~isempty(result.OverflowSaturation) || ~isempty(result.DivideByZero);
                mData.OverflowWrap = result.OverflowWrap;
                mData.OverflowSaturation = result.OverflowSaturation;
                mData.DivideByZero = result.DivideByZero;
                mData.ShowPotentialOverflows = allContainerTypes.ProposedDT.isFixed || ...
                    (allContainerTypes.SpecifiedDT.isFixed  && ...
                    allContainerTypes.CompiledDT.isFloat ) || ...
                    result.IsScaledDouble;
                
            end
            
            this.Data.Histogram = mData;
        end
        function dt = getDTContainerInfo(~, result)
            %% GETDTCONTAINERINFO function returns the SimulinkFixedPoint.DTContainerInfo of a result's specified / compiled type
            %
            % result is an instance of fxptds.AbstractResult
            
            % Get DTContainerInfo of a result's specified type
            dt = SimulinkFixedPoint.DTContainerInfo(result.getSpecifiedDT, []);
            if isempty(dt.evaluatedNumericType)
                % if specified type is inherited or empty (for
                % MATLABVARIABLERESULTS), use compiled type to get
                % the container information
                dt = SimulinkFixedPoint.DTContainerInfo(result.getCompiledDT, []);
            end
        end
        %%
        function [isInSubsysToScale, blkOutofSysStr] = isResultInSubsysToScale(~,result)
            % check the comments to verify this
            isInSubsysToScale = true;
            try
                blkOutofSysStr = DAStudio.message('SimulinkFixedPoint:autoscaling:blockOutsideSubSystem');
                notInSubsys = ismember(result.getComment, blkOutofSysStr);
                
                if any(notInSubsys)
                    isInSubsysToScale = false;
                end
            catch
            end
        end
        
        function blkNameStr = removeMdlNameFromBlkPath(~,originalFullName)
            blkNameStr = '';
            if ischar(originalFullName)
                mdlName = bdroot(originalFullName);
                pat = [regexptranslate('escape',mdlName),'/'];
                blkNameStr = regexprep(originalFullName, pat , '', 1);
            end
        end
        
        function constraintMessage = getConstrainedInformation(this, result)
            constraintMessage = '';
            if(result.hasDTConstraints)
                constraints = result.getConstraints;
                for i=1:numel(constraints)
                    srcBlk = constraints{i}.Object;
                    if isa(srcBlk,'DAStudio.Object')
                        % Code for getConstrainedDTHTML
                        constraintSet = constraints{i};
                        fullName = srcBlk.getFullName;
                        if isa(srcBlk,'Simulink.Block')
                            this.Data.sourceBlockName = this.removeMdlNameFromBlkPath(fullName);
                        else
                            this.Data.sourceBlockName = fullName;
                        end
                        this.Data.collectConstrainedDTSummary = true;
                        this.Data.sourcePort = constraintSet.ElementOfObject;
                        this.Data.constraintSetComments = constraintSet.getComments;
                        if ~isa(result,'fxptds.MATLABVariableResult')
                            this.Data.isImmediateOwnerSourceBlk =  isequal(result.getUniqueIdentifier.getObject, srcBlk);
                        else
                            this.Data.isImmediateOwnerSourceBlk = false;
                        end
                    end
                end
            end
        end
        
        function isSignednessUnSpecified = getSignednessOfSpecifiedDT( ~, dataTypeValue)
            % return true if the signedness is auto, else return false.
            % g1147599
            isSignednessUnSpecified = false;
            if fxptds.isFixedPointType(dataTypeValue)
                dtType = eval(dataTypeValue);
                if strcmpi(dtType.Signedness,'Auto')
                    isSignednessUnSpecified = true;
                end
            end
        end
        
        function [dataTypeMin,dataTypeMax,dataTypePrecision] = getRangeAndPrecisionInformation(~, dataTypeValue) %ok
            dataTypePrecision = '';
            dataTypeMin='';
            dataTypeMax='';
            
            % the acceptable dataTypeValue are -
            % fixdt(...) || numerictype (....)
            % 'fixdt(''double || single '')' || 'numerictype(''double || single '')'
            % int, uint flavors
            % double || single
            
            % apart from the above values, this function should not get executed, as
            % the hasProposedDT should be false.
            
            if fxptds.isFixedPointType(dataTypeValue)
                % for fixedpoint type
                dtType = eval(dataTypeValue);
                try
                    [dataTypeMin, dataTypeMax] = SimulinkFixedPoint.DataType.getFixedPointRepMinMaxRwvInDouble(dtType);
                catch
                    % return. This should only happen for the unspecified
                    % signedness.
                    return;
                end
                dataTypePrecision = 2^(-dtType.FractionLength);
            elseif(fxptds.isIntegerType(dataTypeValue))
                % for integer type
                [dataTypeMin, dataTypeMax] = SimulinkFixedPoint.DataType.getFixedPointRepMinMaxRwvInDouble(fixdt(dataTypeValue));
                dataTypePrecision = 1;
                
            elseif(fxptds.isFloatingPointType(dataTypeValue))
                % for floatingpoint type
                % added switch case - g1148337 & g1148200
                switch dataTypeValue
                    case {'double','Double'}
                        dtForPrecision = 'double';
                    case {'single','Single'}
                        dtForPrecision = 'single';
                    otherwise
                        dataTypeValue = eval(dataTypeValue);
                        if (dataTypeValue.isdouble)
                            dtForPrecision = 'double';
                        else
                            dtForPrecision = 'single';
                        end
                end
                % g1149386 - use fi to get the range for double and single.
                fiObj = fi(0,'DataTypeMode',dtForPrecision);
                [dataTypeMin,dataTypeMax] = range(fiObj);
                dataTypePrecision = eps(fiObj);
            end
        end
        
        function setHighLevelSummary(this,result)
            %% setHighLevelSummary
            % populates HighLevelSummary with appropriate comments for the result to be
            % displayed in the result details pane
            
            this.Data.HighLevelSummary = fxptds.Utils.getResultComments(result);
            
        end
    end
    
    methods(Hidden)
        %%
        function sendDataForRowSelection(this, clientSelectedResult)
            result = fxptui.ScopingTableUtil.getResultForClientResultID(clientSelectedResult.id);
            if ~isempty(result)
                this.packageData(result);
                this.publishData;
            end
        end
        
        function dto =  getDTO(~, result)
            % Find the dominant DTO setting in the hierarchy containing the
            % block.
            dto = '';
            if isa(result,'fxptds.AbstractSimulinkObjectResult')
                return;
            end
            
            uniqueID = result.getUniqueIdentifier;
            if ~isa(uniqueID, 'fxptds.SimulinkIdentifier')
                return;
            end
            blkObj = uniqueID.getObject;
            parentSID = Simulink.ID.getParent(Simulink.ID.getSID(blkObj));
            parent = get_param(Simulink.ID.getHandle(parentSID),'Object');
            dto = get_param(parent.getFullName,'DataTypeOverride');
            
            % By default
            %loop until the model root is reached, we want to find the highest system
            %with a dominant setting (ie: anything but UseLocalSettings)
            while ~isa(parent,'Simulink.BlockDiagram')
                %if this parent doesn't have a dominant setting get the next parent
                if ~isa(parent, 'Stateflow.Object') && ~strcmp('UseLocalSettings', parent.DataTypeOverride)
                    %this parent contains dominant setting, hold on to it
                    dto = parent.DataTypeOverride;
                end
                parent = parent.getParent;
            end
        end
    end
end

%--------------------------------------------------------------------------
%-------------Local Helper %Funcitons--------------------------------------
%--------------------------------------------------------------------------

function decimalNumberStr = compactButAccurateNum2Str(origNumberInDouble)
    % find compact string for cases that are messy when crossing the
    % decimal to/from binary canyon
    % For example, 0.05 can't be represented perfectly in binary representations
    % such as IEEE floating point representations.
    % For proof of this try the following snippet of MATLAB code,
    %   ideallyEqualButNotBecauseOfErrorInBinaryRep = ( 3*0.01 == 0.15 )
    % Once the compact but accurate string is found, use the first 12
    % characters to display the value to the user.
    
    % reverting g1149135. We will add column resizer to the table.
    decimalNumberStr = '';
    
    if(isempty(origNumberInDouble))
        return;
    end
    if isa(origNumberInDouble,'embedded.fi')
        origNumberInDouble = double(origNumberInDouble);
    end
    numberToConvert = origNumberInDouble;
    
    for numDecimalDigits = 15:19
        decimalNumberStr = num2str(numberToConvert,numDecimalDigits);
        if (eval(decimalNumberStr) == origNumberInDouble)
            break;
        end
    end
end

% LocalWords:  FPTMATLAB
