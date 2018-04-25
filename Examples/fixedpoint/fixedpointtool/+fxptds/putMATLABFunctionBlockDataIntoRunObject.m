function putMATLABFunctionBlockDataIntoRunObject(runObj,CompilationReport,loggedVariablesData,uniqueFileKey)
    % Loop over each function in this MATLAB Function block and put into the
    % run object.

    %   Copyright 2014-2017 The MathWorks, Inc.
    
    masterInference = fxptds.MATLABIdentifier.setCurrentInferenceReport(CompilationReport.inference, uniqueFileKey);
    numFunctions = length(loggedVariablesData.Functions);
    functionIds = zeros(1, numFunctions);
    for compReportFunctionIndex = 1:numFunctions
        functionIds(compReportFunctionIndex) = CompilationReport.InstrumentedData.InstrumentedFunctions(compReportFunctionIndex).FunctionID;
    end

    mxInfos  = loggedVariablesData.MxInfos;
    ed = fxptui.FPTEventDispatcher.getInstance;
    blockObject = get_param(loggedVariablesData.SID, 'Object');
    blockHandle = blockObject.Handle;
    functionIdentifiers = cell(numFunctions, 1);
    for j = 1:numFunctions
        % For each function, ...
        logged_function = loggedVariablesData.Functions(j);

        ScriptID = CompilationReport.inference.Functions(logged_function.FunctionID).ScriptID;
        function_identifier = fxptds.MATLABFunctionIdentifier(...
            loggedVariablesData.SID, ...
            CompilationReport.inference.Scripts(ScriptID).ScriptPath, ...
            logged_function.FunctionID, ...
            logged_function.InstanceCount, ...
            logged_function.NumberOfInstances, ...
            CompilationReport.inference.RootFunctionIDs, ...
            masterInference);
        functionIdentifiers{j} = function_identifier;
        
        compReportFunctionIndex = functionIds == logged_function.FunctionID;
        instrumentedLocations = CompilationReport.InstrumentedData.InstrumentedFunctions(compReportFunctionIndex).InstrumentedMxInfoLocations;
        numLocations = size(instrumentedLocations, 2);
        expressionIDs = fxptds.MATLABExpressionIdentifier.empty(0,numLocations);
        for locationCount = 1:numLocations
            currentLocation = instrumentedLocations(locationCount);
            data.MATLABFunctionIdentifier = function_identifier;
            data.MxInfoID = currentLocation.MxInfoID;
            data.TextStart = currentLocation.TextStart;
            data.TextLength = currentLocation.TextLength;
            data.NodeTypeName = currentLocation.NodeTypeName;
            data.IsArgin = currentLocation.IsArgin;
            data.IsArgout = currentLocation.IsArgout;
            data.IsGlobal = currentLocation.IsGlobal;
            data.IsPersistent = currentLocation.IsPersistent;
            data.SimMin = currentLocation.SimMin;
            data.SimMax = currentLocation.SimMax;
            data.IsAlwaysInteger = currentLocation.IsAlwaysInteger;
            data.NumberOfZeros = currentLocation.NumberOfZeros;
            data.NumberOfPositiveValues = currentLocation.NumberOfPositiveValues;
            data.NumberOfNegativeValues = currentLocation.NumberOfNegativeValues;
            data.TotalNumberOfValues = currentLocation.TotalNumberOfValues;
            data.SimSum = currentLocation.SimSum;
            data.HistogramOfPositiveValues = currentLocation.HistogramOfPositiveValues;
            data.HistogramOfNegativeValues = currentLocation.HistogramOfNegativeValues;
            data.LoggedFieldNames = currentLocation.LoggedFieldNames;
            data.LoggedFieldMxInfoIDs = currentLocation.LoggedFieldMxInfoIDs;
            data.ProposedSignedness = currentLocation.ProposedSignedness;
            data.ProposedWordLengths = currentLocation.ProposedWordLengths;
            data.ProposedFractionLengths = currentLocation.ProposedFractionLengths;
            data.OutOfRange = currentLocation.OutOfRange;
            data.RatioOfRange = currentLocation.RatioOfRange;
            data.SymbolName = currentLocation.SymbolName;
            data.Reason = currentLocation.Reason;
            
            % always create identifier class, but no creation of
            % results in the dataset
            expressionIDs(locationCount) = fxptds.MATLABExpressionIdentifier(...
                data.MATLABFunctionIdentifier,...
                data.MxInfoID,...
                data.TextStart,...
                data.TextLength,...
                data.IsArgin,...
                data.IsArgout,...
                data.IsGlobal,...
                data.IsPersistent,...
                data.Reason,...
                masterInference);
            
            %Suppress the insertion of expressionResults
            %only add results for expressions that have meaningful results
            if (data.SimMax >= data.SimMin)
                % slsvTestingHook('FxptuiExpr') == 0 would add no result
                if (slsvTestingHook('FxptuiExpr') == 1)
                    if (obj.Reason == REASON_ADD  ||...
                            obj.Reason == REASON_SUBTRACT ||...
                            obj.Reason == REASON_MULTIPLY ||...
                            obj.Reason == REASON_DIVIDE)
                        runObj.createAndUpdateResult(fxptds.MATLABExpressionDataArrayHandler(data));
                    end
                elseif (slsvTestingHook('FxptuiExpr') > 1)
                    runObj.createAndUpdateResult(fxptds.MATLABExpressionDataArrayHandler(data));
                end
            end
        end        
        
        % send event with the function identifier information. This data will be used to udpate the tree if the UI is up.
        % 1) create an independant event dispatcher class that takes this event and
        % broadcasts it to the registered clients
        % 2) UI will listen to the event on the dispatcher class
        % 3) Data will send the event on the dispatcher class.
        ed.broadcastEvent('FunctionAddedEvent',...
                          fxptui.FPTTreeUpdateEventData(...
                                                        function_identifier,...
                                                        Simulink.ID.getFullName(loggedVariablesData.SID)));
        named_variables = logged_function.NamedVariables;
        % Expand the fields of structs so they can be iterated over like
        % any other variable.
        % First, count the number of logged structs.  Only expand if there
        % are logged structs present.
        nvars_expanded = 0;
        nstructs = 0;
        for k = 1:length(named_variables)
            % For each variable, ...
            named_variable = named_variables(k);
            mxInfoID = named_variable.MxInfoID;
            mxInfo = mxInfos{mxInfoID};
            if isa(mxInfo,'eml.MxStructInfo') || named_variable.IsCppSystemObject
                nvars_expanded = nvars_expanded + length(named_variable.LoggedFieldNames);
                nstructs = nstructs + 1;
            else
                nvars_expanded = nvars_expanded + 1;
            end
        end
        if nstructs == 0
            % If there are no structs, then the named_variables struct is
            % identical to data_array.
            data_array = named_variables;
            for k = 1:length(named_variables)
                data_array(k).MATLABFunctionIdentifier = function_identifier;
                data_array(k).MxInfoID = data_array(k).MxInfoID;
                data_array(k).MATLABExpressionIdentifiers = expressionIDs(data_array(k).MxInfoLocationIDs);
            end
        else
            % There are structs in the data.  Pre-allocate the array by
            % assigning into the last element, then fill in the
            % rest.
            named_variable = named_variables(1);
            named_variable.MATLABFunctionIdentifier = function_identifier;
            named_variable.MATLABExpressionIdentifiers = expressionIDs(named_variable.MxInfoLocationIDs);
            data_array = named_variable;
            data_array(nvars_expanded) = named_variable;
            n_data_array = 0;
            for k = 1:length(named_variables)
                named_variable = named_variables(k);
                named_variable.MATLABFunctionIdentifier = function_identifier;
                mxInfoID = named_variable.MxInfoID;
                mxInfo = mxInfos{mxInfoID};
                if isa(mxInfo,'eml.MxStructInfo') || named_variable.IsCppSystemObject
                    if named_variable.IsCppSystemObject
                        mxInfoPropIdx = strcmpi({mxInfo.ClassProperties.PropertyName},'cSFunObject');
                        sysObjMxInfoID = mxInfo.ClassProperties(mxInfoPropIdx).MxInfoID;
                        sysObjInstanceID = mxInfos{sysObjMxInfoID}.SEACompID;
                        sysObjInstance = loggedVariablesData.MxArrays{sysObjInstanceID};
                        try
                            % This method is not yet implemented for all loggable C++
                            % System objects. So, protect with try-catch.
                            sysObjCompiledDataTypeInfo = getCompiledFixedPointInfo(sysObjInstance);
                        catch
                            % no need to rethrow the error - just discard it.
                            sysObjCompiledDataTypeInfo = [];
                        end

                    end
                    for m = 1:length(named_variable.LoggedFieldNames)
                        field_name = [named_variable.SymbolName,'.',...
                                      named_variable.LoggedFieldNames{m}];
                        n_data_array = n_data_array + 1;                        
                        named_variable.MATLABExpressionIdentifiers = expressionIDs(named_variable.MxInfoLocationIDs);
                        data_array(n_data_array) = named_variable;
                        % Update the fields.
                        data_array(n_data_array).SymbolName =                  field_name;
                        data_array(n_data_array).MxInfoID =                    named_variable.LoggedFieldMxInfoIDs{m}(end);
                        if (named_variable.SimMin(m) <= named_variable.SimMax(m))
                            data_array(n_data_array).SimMin = named_variable.SimMin(m);
                            data_array(n_data_array).SimMax = named_variable.SimMax(m);
                        else
							% in cases where the MATLAB variables are not instrumented, 
							% the compilation information will report the simulation ranges to be 
							% initialized as follows: SimMin=Inf, SimMax=-Inf. 
							% As an example, conditionally executed MATLAB code that was not
							% exercised during the conversion workflow, will result in results 
							% that have the ranges in this state. 
							% At this point, we make sure to insert results with empty ranges
							% in the fixed point tool's data set, rather than initialized to 
							% a reverse (Inf, -Inf). 
                            data_array(n_data_array).SimMin = [];
                            data_array(n_data_array).SimMax = [];
                        end
                        data_array(n_data_array).IsAlwaysInteger =             named_variable.IsAlwaysInteger(m);
                        data_array(n_data_array).NumberOfZeros =               named_variable.NumberOfZeros(m);
                        data_array(n_data_array).NumberOfPositiveValues =      named_variable.NumberOfPositiveValues(m);
                        data_array(n_data_array).NumberOfNegativeValues =      named_variable.NumberOfNegativeValues(m);
                        data_array(n_data_array).TotalNumberOfValues =         named_variable.TotalNumberOfValues(m);
                        data_array(n_data_array).SimSum =                      named_variable.SimSum(m);
                        data_array(n_data_array).HistogramOfPositiveValues =   named_variable.HistogramOfPositiveValues(m,:);
                        data_array(n_data_array).HistogramOfNegativeValues =   named_variable.HistogramOfNegativeValues(m,:);
                        if named_variable.IsCppSystemObject
                            % store the System object's info
                            data_array(n_data_array).LoggedFieldNames =        {named_variable.SymbolName};
                            data_array(n_data_array).LoggedFieldMxInfoIDs =    {mxInfoID};
                            data_array(n_data_array).SpecifiedDT =             loggedVariablesData.MxArrays{mxInfos{data_array(n_data_array).MxInfoID}.NumericTypeID};
                            propName = regexprep(named_variable.LoggedFieldNames{m},'Custom','');
                            if ~isempty(sysObjCompiledDataTypeInfo) && isfield(sysObjCompiledDataTypeInfo, propName)
                                data_array(n_data_array).CompiledDT = sysObjCompiledDataTypeInfo.(propName);
                            end
                        else 
                            data_array(n_data_array).LoggedFieldNames =        {};
                            data_array(n_data_array).LoggedFieldMxInfoIDs =    {};
                        end
                        data_array(n_data_array).ProposedSignedness =          named_variable.ProposedSignedness(m);
                        data_array(n_data_array).ProposedWordLengths =         named_variable.ProposedWordLengths(m);
                        data_array(n_data_array).ProposedFractionLengths =     named_variable.ProposedFractionLengths(m);
                        data_array(n_data_array).OutOfRange =                  named_variable.OutOfRange(m);
                        data_array(n_data_array).RatioOfRange =                named_variable.RatioOfRange(m);
                    end
                else
                    n_data_array = n_data_array + 1;
                    named_variable.MATLABExpressionIdentifiers = expressionIDs(named_variable.MxInfoLocationIDs);
                    data_array(n_data_array) = named_variable;
                end
            end
        end

        % Add the variables to the runObj
        dataHandler = fxptds.MATLABVariableDataArrayHandler(data_array);
        runObj.createAndUpdateResult(dataHandler);
    end % for j = 1:length(loggedVariablesData.Functions)
    runObj.addMLFBHierarchy(blockHandle, functionIdentifiers);
end
