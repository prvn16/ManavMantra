classdef MATLABExpressionResult < fxptds.AbstractResult
%MATLABExpressionResult

% Copyright 2014-2017 The MathWorks, Inc.
    properties(SetAccess = private)
        Size
        Complex
        Scope = 'Local';
        Fimath
    end % properties

    methods
        function this = MATLABExpressionResult(data)
            if nargin  == 0
                argList = {};
            else
                argList = {data};
            end
            this@fxptds.AbstractResult(argList{:});
            this.updateCompiledInformation;
        end % MATLABExpressionResult()

    end

    methods
        function icon = getDisplayIcon(~)
            icon = fullfile('toolbox','fixedpoint','fixedpointtool',...
                'resources','emlLogged.png');
        end % getDisplayIcon()
        
        calculateRangesForResult(this, proposalSettings);
        
        function updateResultData(this, data)

            % We need to update the identifier because although this is
            % still the same result the number of specializations may have
            % changed, so we need to update so the display makes sense.
            if isfield(data, 'uniqueID')
                this.UniqueIdentifier = data.uniqueID;
            end

            if isfield(data,'SimMin') && ...
                    ~isempty(this.SimMin) && ~isempty(data.SimMin) && ...
                    isequal(size(this.SimMin),size(data.SimMin))
                % Merge run data
                data.SimMin = min(this.SimMin,data.SimMin);
            end
            if isfield(data,'SimMax') && ...
                    ~isempty(this.SimMax) && ~isempty(data.SimMax) && ...
                    isequal(size(this.SimMax),size(data.SimMax))
                % Merge run data
                data.SimMax = max(this.SimMax,data.SimMax);
            end

            updateResultData@fxptds.AbstractResult(this, data);
            if isfield(data,'RatioOfRange') && ~isempty(data.RatioOfRange) && ~isempty(data.RatioOfRange{1})
                for i = 1:numel(data.RatioOfRange)
                    if data.RatioOfRange{i} > 1
                        this.PossibleOverflows = true;
                        break;
                    end
                end
            end

            if isfield(data,'SimMin') || isfield(data,'DerivedMin')
                % Create local to prevent multiple dependent property access
                masterInference = this.UniqueIdentifier.MasterInferenceReport;

                [DTstring,IsScaledDouble] = fixed.internal.mxInfoToDataTypeString(...
                    this.UniqueIdentifier.MxInfoID,...
                    masterInference.MxInfos,...
                    masterInference.MxArrays);
                this.CompiledDT = DTstring;
                this.IsScaledDouble = IsScaledDouble;
            end

            if isfield(data,'IsAlwaysInteger')
                this.WholeNumber = data.IsAlwaysInteger;
            end

            histogramData = [];
            if isfield(data, 'HistogramOfPositiveValues') && ~isempty(data.HistogramOfPositiveValues)
                histogramData(:,1) = data.HistogramOfPositiveValues';
            end
            if isfield(data, 'HistogramOfNegativeValues') && ~isempty(data.HistogramOfNegativeValues)
                histogramData(:,2) = data.HistogramOfNegativeValues';
            end
            if ~isempty(histogramData)
                newHistogramData = fxptds.HistogramUtil.getHistogramData(histogramData);
                if isfield(data, 'NumberOfZeros')
                    newHistogramData.numZeros = data.NumberOfZeros;
                end
                this.HistogramData = fxptds.HistogramUtil.mergeHistogramData(this.HistogramData, newHistogramData);
            end


            functionID = this.UniqueIdentifier.MATLABFunctionIdentifier;
            if isa(this.RunObject,'fxptds.FPTRun')
                this.RunObject.insertRootFunctionIDs(functionID.BlockIdentifier.UniqueKey, functionID.RootFunctionIDs);
            end
        end % updateResultData

        function val = getPropValue(this, prop)
            val = getPropValue@fxptds.AbstractResult(this, prop);
            if strcmpi(prop,'Accept')
                if this.hasProposedDT
                    % Display 'Manual' if Apply feature is off
                    if ~fxptui.isMATLABFunctionBlockConversionEnabled()
                        val  = fxptui.message('Manual');
                    end
                else
                    val = '';
                end
            elseif strcmp(prop,'OverflowWrap') || strcmp(prop,'OvfWrap')
                if ~this.IsScaledDouble && fxptds.isFixedPointType(this.CompiledDT)...
                        && strcmpi(this.OverflowMode,'Wrap')
                    val = 'unknown'; % overwrite value returned by superclass
                end
            elseif strcmp(prop,'OverflowSaturation') || strcmp(prop,'OvfSat')
                if ~this.IsScaledDouble && fxptds.isFixedPointType(this.CompiledDT)...
                        && strcmpi(this.OverflowMode,'Saturate')
                    val = 'unknown';  % overwrite value returned by superclass
                end
            end
        end

        function label = getDisplayLabel(this)
           label = getDisplayLabel@fxptds.AbstractResult(this);
        end
       
        function b = hasValidRootFunctionIDs(this)
            b = false;
            functionMap = this.RunObject.getRootFunctionIDsMap;
            functionID = this.UniqueIdentifier.MATLABFunctionIdentifier;
            if ~isempty(functionID.BlockIdentifier)
                uniqueKey = functionID.BlockIdentifier.UniqueKey;
                if ~isempty(uniqueKey) && functionMap.isKey(uniqueKey)
                    oldBlkRootFcns = functionMap.getDataByKey(uniqueKey);
                    b = isequal(oldBlkRootFcns{1}, functionID.RootFunctionIDs);
                end
            end
        end


        function varScope = getScope(this)
            varScope = this.Scope;
        end
        
        function subsystemId = getSubsystemId(this)
            subsystemId = '';
            uniqueId = this.getUniqueIdentifier;
            if ~isempty(uniqueId)
                functionUniqueIdentifier = uniqueId.MATLABFunctionIdentifier;
                if ~isempty(functionUniqueIdentifier)
                    subsystemId = {functionUniqueIdentifier.UniqueKey};
                    fxptds.Utils.cacheSubsystemIdentifier(functionUniqueIdentifier);
                end
            end
        end
        function actualSourceIDs =  getActualSourceIDs(this)
            actualSourceIDs = {this.getUniqueIdentifier};
        end
    end % methods


    methods(Access=protected)

         function uniqueID = createUniqueIdentifierForData(~, data)
             dh = fxptds.MATLABExpressionDataArrayHandler;
             uniqueID = dh.getUniqueIdentifier(data);
         end % createUniqueIdentifierForData()

        function actionHandler = createActionHandlerForResult(this, ~)
            actionHandler = fxptds.MATLABVariableActions(this);
        end % createActionHandlerForResult()

        function updateCompiledInformation(this)
            if isempty(this.UniqueIdentifier)
                return;
            end
            mxInfo = this.UniqueIdentifier.MasterInferenceReport.MxInfos{this.UniqueIdentifier.MxInfoID};
            this.Size = reshape(mxInfo.Size,1,[]);
            if isa(mxInfo, 'eml.MxNumericInfo') || isa(mxInfo, 'MxFiInfo')
                this.Complex = mxInfo.Complex;
            end
            if this.UniqueIdentifier.IsArgin
                this.Scope = 'Input';
            elseif this.UniqueIdentifier.IsArgout
                this.Scope = 'Output';
            elseif this.UniqueIdentifier.IsGlobal
                this.Scope = 'Global';
            elseif this.UniqueIdentifier.IsPersistent
                this.Scope = 'Persistent';
            end
            this.Fimath = this.UniqueIdentifier.FiMath;
        end

    end % methods(Access=protected)

    methods(Hidden)
        function batchSetAccept(this, value)
            if fxptui.isMATLABFunctionBlockConversionEnabled()
                notify(this,'SetAccept', fxptds.FPTEvents.AcceptDTEvent(value));
            else
                % Override default implementation and always set Accept to
                % false till the autoapply feature is available.
                this.Accept = false;
            end
        end
        function updateAcceptFlag(this)
            if fxptui.isMATLABFunctionBlockConversionEnabled()
                this.Accept = true;
            else
                % Override default implementation and always set Accept to
                % false till the autoapply feature is available.
                this.Accept = false;
            end
        end
        function updateAcceptFlagPostApply(this)
            % Update the accept flag on the result post apply
            % On successful apply, the fixpt variants created would contain the
            % proposed type applied as specified type
            % Hence the floating point run's result needs to be unset. 
            this.Accept = false;
        end
        function setSpecifiedDataType(this, ~)
            % Override default implementation to set the specified data type after
            % gathering the specifiedDT & auto-apply. We do not currently have a
            % way of knowing the specifiedDT for MATLAB code. This property will
            % always be empty till we have a solution.
            this.SpecifiedDT = '';
        end

        function b = isReadonlyProperty(this, propName)
            b = true;
            % Cannot change the Accept column for MATLAB results in v1
            if strcmpi(propName,'Accept')
                if ~fxptui.isMATLABFunctionBlockConversionEnabled()
                    return;
                end
            end
            b = isReadonlyProperty@fxptds.AbstractResult(this, propName);
        end

        function ovfAction = getOverflowMode(this)
            varID = this.getUniqueIdentifier;
            fMath = varID.FiMath;
            if ~isempty(fMath)
                ovfAction = fMath.OverflowAction;
            else
                ovfAction = 'Saturate';
            end
        end
        % computeIfInheritanceReplaceable API verifies if a result is a
        % candidate for fixed point proposal on having an inheritance
        % rule as specified type.
        % For MATLAB Expression Result, this API always sets IsInheritanceReplaceable
        % property to false
        function computeIfInheritanceReplaceable(this)
            this.IsInheritanceReplaceable  = false;
        end
        
    end % methods(Hidden)

end

% LocalWords:  Ovf proposedtinvalid fixedpoint fxptui fxptds fixedpointtool
% FPT
