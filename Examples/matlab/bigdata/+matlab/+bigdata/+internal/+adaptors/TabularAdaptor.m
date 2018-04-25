%TabularAdaptor Base class for TableAdaptor and TimetableAdaptor

% Copyright 2016-2017 The MathWorks, Inc.

classdef TabularAdaptor < matlab.bigdata.internal.adaptors.AbstractAdaptor
    
    properties (SetAccess = immutable, GetAccess = protected)
        % The name of the "row" property
        % - either 'RowNames' for a table, or 'RowTimes' for a timetable
        RowPropertyName
    end
    
    properties (SetAccess = private, GetAccess = protected)
        DimensionNames
        VariableNames
        OtherProperties
        
        % Map of variable name to tall array. Cache these so that repeated extractions
        % of variables from the tall table get precisely the same tall array -
        % complete with metadata if possible. The implementation uses a
        % containers.Map to cache tall arrays. This is a handle type, which
        % allows the cache to function even though the adaptor is a value
        % type. However, this means that we must be careful to build a fresh
        % containers.Map instance when the adaptor is made aware of a
        % modification that invalidates the cache.
        VariableTallArraysCache
        
        VariableAdaptors
        
        % This might be empty if there is no Row
        RowAdaptor
    end
    
    properties (Constant, GetAccess = protected)
        % This is the list of properties that OtherProperties must contain.
        OtherPropertiesFields = { ...
            'Description'; 'UserData'; 'VariableDescriptions'; 'VariableUnits';...
            'VariableContinuity'};
    end
    
    methods (Abstract, Access = protected)
        obj = buildDerived(obj, varNames, varAdaptors, dimNames, rowAdaptor, newProps);
        data = fabricatePreview(obj);
        
        % Return the RowNames / RowTimes
        props = getRowProperty(obj, pa);
        
        % This is called when someone attempts to delete the 'Row' property. This
        % assumes that it is never possible. If we ever support deleting 'Row'
        % for a table, then we'd need to change this.
        throwCannotDeleteRowPropertyError(obj);
        
        % Throw error if row indexing is not support;
        errorIfFirstSubSelectingRowsNotSupported(obj,firstSub);
        
        % Set the special row property (RowNames, RowTimes)
        out = subsasgnRowProperty(adap, pa, szPa, b)
    end
    
    methods (Access = private)
        function obj = copyTallSizeToAllSubAdaptors(obj)
            for idx = 1:numel(obj.VariableAdaptors)
                obj.VariableAdaptors{idx} = copyTallSize(obj.VariableAdaptors{idx}, obj);
            end
            if ~isempty(obj.RowAdaptor)
                obj.RowAdaptor = copyTallSize(obj.RowAdaptor, obj);
            end
        end
        
        function [varNames, varIdxs] = resolveVarNameSubscript(obj, subscript)
            % Subscript type conversions - resolve certain types up-front.
            if isa(subscript, 'matlab.bigdata.internal.util.EndMarker')
                % For table indexing, we must resolve EndMarkers in the second subscript at the
                % client right away.
                szVec = [0, numel(obj.VariableNames)];
                subscript = resolve(subscript, szVec, 2);
            end
            [varNames, varIdxs] = matlab.bigdata.internal.util.resolveTableVarSubscript(...
                obj.VariableNames, subscript);
        end
        
        % Resolve a single dot-subscript
        function varName = resolveDotSubscript(obj, subscript, allowMissing)
            % For cases tt.Foo and equivalently tt.('Foo'), we allow the subscript to be
            % only: scalar string, char-vector, and numeric integer scalar.
            
            % Handle scalar strings by converting to char.
            if isstring(subscript) && isscalar(subscript)
                subscript = char(subscript);
            end
            
            if ischar(subscript) || ...
                    (isnumeric(subscript) && isscalar(subscript) && round(subscript) == subscript)
                
                if allowMissing && ischar(subscript)
                    % Missing variables are allowed - check valid variable name though
                    if ~isvarname(subscript)
                        error(message('MATLAB:table:VariableNameNotValidIdentifier', subscript));
                    end
                    varName = subscript;
                elseif allowMissing && isnumeric(subscript)
                    % Numeric integer scalar - must be in range, or one off the end.
                    if subscript <= numel(obj.VariableNames)
                        varName = obj.VariableNames{subscript};
                    elseif subscript == (1 + numel(obj.VariableNames))
                        % Appending a new variable with generated name
                        varName = sprintf('Var%d', subscript);
                        idx     = 1;
                        while ismember(varName, obj.VariableNames)
                            varName = sprintf('Var%d_%d', subscript, idx);
                            idx     = idx + 1;
                        end
                    else
                        % Outside allowed bounds
                        error(message('MATLAB:table:DiscontiguousVars'));
                    end
                elseif matlab.bigdata.internal.util.isColonSubscript(subscript)
                    error(message('MATLAB:table:UnrecognizedVarName', subscript));
                else
                    % Finally, get here to resolve numeric integer scalars or char-vectors against
                    % known variable names, re-use resolveVarNameSubscript.
                    varNames = obj.resolveVarNameSubscript(subscript);
                    assert(isscalar(varNames), ...
                        'Unexpectedly resolved dot-subscript to multiple variables.');
                    varName = varNames{1};
                end
            else
                error(message('MATLAB:table:IllegalVarSubscript'));
            end
        end
    end
    
    methods (Access = protected)
        function obj = TabularAdaptor(className, dimNames, varNames, varAdaptors, ...
                rowPropName, rowAdaptor, otherProps)
            obj@matlab.bigdata.internal.adaptors.AbstractAdaptor(className);
            
            assert(numel(dimNames) == 2 && iscellstr(dimNames), ...
                'Assertion failed: Dimension names must be a 2 x 1 cell array of character vectors.');
            assert(numel(varNames) == numel(varAdaptors) && iscellstr(varNames), ...
                'Assertion failed: Variable names must be a cell array of characters that matches the number of variables.');
            assert(ischar(rowPropName) && isrow(rowPropName), ...
                'Assertion failed: RowPropertyName must be a character row vector.');
            
            % Trim fields from properties if present.
            otherProps = iTrimOtherProperties(otherProps);
            
            % Assert correct contents of 'otherProps'.
            numVars = numel(varNames);
            assert(ismember(numel(otherProps.VariableDescriptions), [0 numVars]), ...
                'Assertion failed: VariableDescriptions must be empty or match number of variables.');
            assert(ismember(numel(otherProps.VariableUnits), [0 numVars]), ...
                'Assertion failed: VariableUnits must be empty or match number of variables.');
            if isfield(otherProps, 'VariableContinuity')
                assert(ismember(numel(otherProps.VariableContinuity), [0 numVars]), ...
                    'Assertion failed: VariableContinuity must be empty or match number of variables.');
            end
            
            asRow = @(x) reshape(x, 1, []);
            
            obj.DimensionNames   = asRow(dimNames);
            obj.VariableNames    = asRow(varNames);
            obj.VariableAdaptors = asRow(varAdaptors);
            obj.RowPropertyName  = rowPropName;
            obj.RowAdaptor       = rowAdaptor;
            obj.OtherProperties  = otherProps;
            
            obj = setSmallSizes(obj, length(obj.VariableNames));
            for idx = 1:numel(obj.VariableAdaptors)
                obj.VariableAdaptors{idx} = copyTallSize(obj.VariableAdaptors{idx}, obj);
                obj.VariableAdaptors{idx}.ComputeMetadata = true;
            end
            if ~isempty(obj.RowAdaptor)
                obj.RowAdaptor = copyTallSize(obj.RowAdaptor, obj);
            end
            obj.ComputeMetadata = true;
            
            obj.VariableTallArraysCache = iBuildMap();
        end
        
        function previewData = fabricateTabularPreview(obj, varNames)
            % Fabricate a preview table. If size is known and small,
            % make it the correct size, otherwise pretend it's unknown.
            if ~isnan(obj.Size(1)) && obj.Size(1)<matlab.bigdata.internal.util.defaultHeadTailRows()
                numRowsDesired = obj.Size(1);
            else
                % Default to 3
                numRowsDesired = 3;
            end
            
            % table constructor cannot handle a char row-vector as variable data, so we must
            % always ensure there are multiple rows, as per g1508983.
            var  = repmat('?', max(numRowsDesired, 2), 1);
            vars = repmat({var}, 1, numel(varNames));
            previewData = table(vars{:}, 'VariableNames', varNames);
            % We might have made more rows than we intended, so truncate if required.
            previewData = previewData(1:numRowsDesired, :);
        end
        
        function sample = buildTabularSampleImpl(obj, constructor, defaultType, sz)
            %buildTabularSampleImpl Common implementation of
            % buildSampleImpl for tabular types.
            varAdaptors = obj.VariableAdaptors;
            % Use of max(..,2) is a workaround since creating a table
            % with a single row errors if one variable is a character
            % array.
            height = max(sz(1), 2);
            if isempty(obj.RowAdaptor)
                rowLabelSample = {};
            else
                rowLabelSample = buildSample(obj.RowAdaptor, defaultType, height);
            end
            varSamples = cellfun(@(a) buildSample(a, defaultType, height), ...
                varAdaptors, 'UniformOutput', false);
            sample = constructor(rowLabelSample, varSamples{:}, ...
                'VariableNames', obj.VariableNames);
            if isempty(varSamples) && isempty(rowLabelSample)
                % If there were no actual input, sample has size [0,0]
                % instead of [height,0]. We need to correct this.
                sample.TestVar = zeros(sz(1), 0);
                sample.TestVar = [];
            else
                % Otherwise, we just correct for the workaround above.
                sample = sample(1 : sz(1), :);
            end
            sample.Properties = obj.OtherProperties;
            sample.Properties.DimensionNames = obj.DimensionNames;
        end
        
        function props = getPropertiesStruct(obj, pa)
            % Return Properties struct
            p = obj.OtherProperties;
            props = struct( ...
                'Description',          {p.Description}, ...
                'UserData',             {p.UserData}, ...
                'DimensionNames',       {obj.DimensionNames}, ...
                'VariableNames',        {obj.VariableNames}, ...
                'VariableDescriptions', {p.VariableDescriptions}, ...
                'VariableUnits',        {p.VariableUnits}, ...
                'VariableContinuity',   {p.VariableContinuity}, ...
                obj.RowPropertyName,    {obj.getRowProperty(pa)});
        end
    end
    
    methods
        function names = getVariableNames(obj, optIdx)
            % Return the list of variable names for this table. If an index
            % is supplied, only the specified names are returned. optIdx
            % must be a numeric vector within indexing range or a logical
            % vector.
            if nargin>1
                names = obj.VariableNames(optIdx);
            else
                names = obj.VariableNames;
            end
        end
        
        function names = getDimensionNames(obj)
            % Return the dimension names.
            names = obj.DimensionNames;
        end
        
        function clz = getVariableClass(obj, varIdentifier)
            % getVariableClass - get the class of a variable.
            % varIdentifier can be a scalar index or a char vector.
            [~, varIdx] = resolveVarNameSubscript(obj, varIdentifier);
            assert(isscalar(varIdx), 'getVariableClass operates only on scalar variables');
            clz = obj.VariableAdaptors{varIdx}.Class;
        end
        
        function adpt = getVariableAdaptor(obj, varIdentifier)
            % getVariableAdaptor - get the Adaptor of a variable.
            % varIdentifier can be a scalar index or a char vector.
            [~, varIdx] = resolveVarNameSubscript(obj, varIdentifier);
            assert(isscalar(varIdx), 'getVariableAdaptor operates only on scalar variables');
            adpt = obj.VariableAdaptors{varIdx};
        end
        
        function sz = getVariableSize(obj, varIdentifier)
            % getVariableSize - get the size of a variable.
            % varIdentifier can be a scalar index or a char vector.
            [~, varIdx] = resolveVarNameSubscript(obj, varIdentifier);
            assert(isscalar(varIdx), 'getVariableSize operates only on scalar variables');
            sz = obj.VariableAdaptors{varIdx}.Size;
        end
        
        function out = cat(dim, varargin)
            if dim == 1
                out = vertcat(varargin{:});
            else
                out = horzcat(varargin{:});
            end
        end
        
        function out = vertcat(varargin)
            % Combine multiple TableAdaptors for vertical concatenation of the underlying
            % tables. Note that varargin is a 1 x nargin cell array.
            varNames = cellfun(@(x) x.VariableNames, varargin, 'UniformOutput', false);
            nVars = cellfun(@(x) numel(x), varNames, 'UniformOutput', false);
            allVarNames = [varNames{:}];
            
            uniqueNumberOfVars = unique([nVars{:}]);
            uniqueVarNames = unique(allVarNames);
            if numel(uniqueNumberOfVars) ~= 1
                error(message('MATLAB:table:vertcat:SizeMismatch'));
            elseif ~isequal(numel(uniqueVarNames), uniqueNumberOfVars)
                error(message('MATLAB:table:vertcat:UnequalVarNames'));
            end
            
            firstTableAdaptor = varargin{1};
            dimNames          = firstTableAdaptor.DimensionNames;
            rowAdaptor        = firstTableAdaptor.RowAdaptor;
            newAdaptors       = iVertcatVariableAdaptors(varargin{:});
            oldProperties     = cellfun(@(x) x.OtherProperties, varargin, 'UniformOutput', false);
            newProperties     = iVertcatProperties(oldProperties);
            tallSizes         = cellfun(@(x) x.VariableAdaptors{1}.TallSize.Size, varargin);
            newSize           = sum(tallSizes);
            
            out = buildDerived(firstTableAdaptor, uniqueVarNames, newAdaptors, ...
                dimNames, rowAdaptor, newProperties);
            
            % Set the tall size of the out table adaptor to newSize
            out = setSizeInDim(out, 1, newSize);
            
            % We know that each column's tall size must be the same as the table's tall
            % size
            for i = 1:numel(out.VariableAdaptors)
                out.VariableAdaptors{i} = copyTallSize(out.VariableAdaptors{i}, out);
            end
            
        end
        
        function out = horzcat(varargin)
            % Combine multiple TableAdaptors for horizontal concatenation of the underlying
            % tables.
            allVarNames = cellfun(@(x) x.VariableNames, varargin, 'UniformOutput', false);
            allVarNames = [allVarNames{:}];
            
            [uniqueVarNames, ~, ic] = unique(allVarNames);
            if numel(allVarNames) ~= numel(uniqueVarNames)
                % find first duplicate, and error as per table/cat ...
                occurenceCount     = accumarray(ic, 1);
                firstNonUnique     = find(occurenceCount > 1, 1, 'first');
                assert(isscalar(firstNonUnique), ...
                    'Assertion failed: Could not find non-unique variable name.');
                firstNonUniqueName = uniqueVarNames{firstNonUnique};
                error(message('MATLAB:table:DuplicateVarNames', firstNonUniqueName));
            else
                %RowtimesName      = varargin{1}.DimensionNames{1};
                dimNames          = varargin{1}.DimensionNames;
                rowAdaptor        = varargin{1}.RowAdaptor;
                numVarsPerElement = cellfun(@(x) numel(x.VariableNames), varargin);
                oldProperties     = cellfun(@(x) x.OtherProperties, varargin, 'UniformOutput', false);
                newProperties     = iHorzcatProperties(oldProperties, numVarsPerElement);
                newVarNames       = reshape(allVarNames, 1, []);
                allAdaptors       = cellfun(@(x) x.VariableAdaptors, varargin, 'UniformOutput', false);
                newAdaptors       = [allAdaptors{:}];
                out               = buildDerived(varargin{1}, newVarNames, newAdaptors, ...
                    dimNames, rowAdaptor, newProperties);
                
                % Since we know that HORZCAT must involve only arrays that have the same size,
                % we can copy across the tall size from the first input.
                out = copyTallSize(out, varargin{1});
            end
        end
        
        function [newAdaptor, newVarNames] = joinBySample(fcn, requiresVarMerging, varargin)
            % Apply a join-like function handle to samples generated from
            % the provided adaptors. The provided function handle must
            % return tabular output such that:
            %  1) Has the correct width and VariableNames
            %  2) Propagate VariableDescriptions from the input.
            %
            % Syntax:
            %  [newAdaptor,newVarNames] = joinBySample(fcn,requiresVarMerging,adaptor1,adaptor2,..)
            %
            % Inputs:
            %   - fcn is a function handle with the signature:
            %
            %     sampleOut = fcn(sample1,sample2,..)
            %
            %     Where sampleN is a sample table of height 1 generated by
            %     adaptorN and sampleOut must be a table.
            %
            %   - requiresVarMerging must a scalar logical that is true if
            %     and only if an output table variable can consist of the
            %     merger of two input table variables. If true, joinBySample
            %     will take extra care with unknown sizes and types.
            %
            %   - adaptor1,adaptor2,.. each is a TabularAdaptor.
            %
            % Outputs:
            %   - newAdaptor is a TabularAdaptor that matches the output of
            %     invoking fcn on samples generated from the input
            %     adaptors. Uncertainty about size/type will be carried
            %     across.
            %
            %   - newVarNames is a cell array of character vectors of
            %     variable names from sampleOut.
            
            % For join/innerjoin, if any information is incomplete, we remove
            % all information of the same class for the purposes of sample
            % generation. This is to avoid comparing a sample against a sample
            % of unknown type.
            if requiresVarMerging
                isAllTypesKnown = all(cellfun(@isNestedTypeKnown, varargin));
                if ~isAllTypesKnown
                    varargin = cellfun(@resetNestedGenericType, varargin, 'UniformOutput', false);
                end
                
                isAllSmallSizesKnown = all(cellfun(@isNestedSmallSizeKnown, varargin));
                if ~isAllSmallSizesKnown
                    varargin = cellfun(@resetNestedSmallSizes, varargin, 'UniformOutput', false);
                end
            end
            
            % Sample generation.
            inSamples = cell(size(varargin));
            inVarDesc = cell(size(varargin));
            for ii = 1 : numel(varargin)
                inSamples{ii} = buildSample(varargin{ii}, 'double');
                % There are some instances where the data has row names but
                % the adaptor isn't aware of it. For safety, we ensure row
                % names in all cases.
                if istable(inSamples{ii}) && isempty(inSamples{ii}.Properties.RowNames)
                    inSamples{ii}.Properties.RowNames = {'1'};
                end
                % Keep the original variable descriptions for later.
                inVarDesc{ii} = inSamples{ii}.Properties.VariableDescriptions;
                % And set variable description for all inputs to JoinOrigin
                % reference strings used below.
                inSamples{ii}.Properties.VariableDescriptions = cellstr(...
                    "JoinOrigin_" + string(ii) + "_" + string(1:width(inSamples{ii})) );
            end

            % Apply the provided function to the sample tables.
            %
            % We will use the output of this for two purposes:
            %  1. Generate an Adaptor to use to create the output adaptor
            %  2. Map output variables to input variables
            %
            % Item (2) is done by using "JoinOrigin_M_N" reference strings
            % in variable descriptions. For all input samples, the variable
            % description is set to "JoinOrigin_M_N", which represents
            % table variable N of input table M. The output table sample
            % descriptions  will contain either of the following:
            %  - "JoinOrigin_M_N": From the corresponding input sample
            %  - "Data indicator": Hard-coded string from table/stack
            try
                outSample = fcn(inSamples{:});
            catch err
                matlab.bigdata.internal.throw(err);
            end
            assert(istable(outSample) || istimetable(outSample), ...
                'Assertion failed: joinBySampleImpl requires fcn to emit a table.');
            
            % Now generate an adaptor for each output variable. This uses
            % the map of input to output variable to carry across
            % uncertainty about type and small sizes.
            %
            % Note, if an output table variable is derived from multiple
            % input variables, it's type is defined by first one wins. This
            % will be the input variable referenced by "JoinOrigin_M_N".
            origins = string(outSample.Properties.VariableDescriptions);
            newVarAdaptors = cell(width(outSample), 1);
            newVarDesc = repelem(string(missing), width(outSample));
            varDescHasUserString = false;
            for ii = 1:width(outSample)
                origin = origins(ii);
                newAdaptor = matlab.bigdata.internal.adaptors.getAdaptor(outSample.(ii));
                if startsWith(origin, "JoinOrigin_")
                    idx = double(split(extractAfter(origin, 11), "_"));
                    assert(numel(idx) == 2 && all(~isnan(idx)), ...
                        'Assertion failed: Could not parse a JoinOrigin string');
                    % Carry across uncertainty about size/type from the
                    % origin input table variable from which this output
                    % variable is derived.
                    origAdaptor = varargin{idx(1)}.getVariableAdaptor(idx(2));
                    if ~origAdaptor.isNestedTypeKnown()
                        newAdaptor = resetNestedGenericType(newAdaptor);
                    end
                    if ~origAdaptor.isNestedSmallSizeKnown()
                        newAdaptor = resetNestedSmallSizes(newAdaptor);
                    end
                    % We have to carry actual varible descriptions across
                    % manually because the above logic repurposed it for
                    % the mapping between input and output.
                    if ~isempty(inVarDesc{idx(1)})
                        newVarDesc(ii) = inVarDesc{idx(1)} (idx(2));
                        varDescHasUserString = true;
                    end
                else
                    newVarDesc(ii) = origin;
                end
                newVarAdaptors{ii} = resetTallSize(newAdaptor);
            end
            
            % If any variable description from the user exists, then we
            % need to set this for all.
            if varDescHasUserString
                newVarDesc(ismissing(newVarDesc)) = "";
                newVarDesc = cellstr(newVarDesc);
            else
                newVarDesc = {};
            end
            
            otherProps = outSample.Properties;
            otherProps.VariableDescriptions = newVarDesc;
            newVarNames = otherProps.VariableNames;
            dimNames = otherProps.DimensionNames;
            
            newAdaptor = buildDerived(varargin{1}, newVarNames, newVarAdaptors, ...
                dimNames, varargin{1}.RowAdaptor, otherProps);
            newAdaptor = resetTallSize(newAdaptor);
        end
        
        function tf = isNestedTypeKnown(obj)
            % isTypeKnown Return TRUE if and only if this adaptor and all
            % of its children have known type. Children include table
            % variables.
            tf = isTypeKnown(obj);
            for idx = 1:numel(obj.VariableAdaptors)
                tf = tf && isNestedTypeKnown(obj.VariableAdaptors{idx});
            end
        end
        
        function tf = isNestedSmallSizeKnown(obj)
            % Return true if both this adaptor and all its children have
            % known small size. Children include table variables.
            tf = isSmallSizeKnown(obj);
            for idx = 1:numel(obj.VariableAdaptors)
                tf = tf && isNestedSmallSizeKnown(obj.VariableAdaptors{idx});
            end
        end
        
        function obj = resetNestedGenericType(obj)
            %resetNestedGenericType Reset the type of any GenericAdaptor
            % found among this adaptor or any children of this adaptor.
            for idx = 1:numel(obj.VariableAdaptors)
                obj.VariableAdaptors{idx} = resetNestedGenericType(obj.VariableAdaptors{idx});
            end
        end
        
        function idxs = resolveVarNamesToIdxs(obj, namesOrIdxs)
            [~, idxs] = obj.resolveVarNameSubscript(namesOrIdxs);
        end
        
        function obj = resetSizeInformation(obj)
            % Overloaded for TabularAdaptor - NDims and num variables don't change.
            obj.VariableTallArraysCache = iBuildMap();
            obj = resetTallSize(obj);
        end
        
        function obj = resetTallSize(obj)
            obj.VariableTallArraysCache = iBuildMap();
            obj = resetTallSize@matlab.bigdata.internal.adaptors.AbstractAdaptor(obj);
            obj = copyTallSizeToAllSubAdaptors(obj);
        end
        
        function obj = resetNestedSmallSizes(obj)
            %resetNestedSmallSizes Reset the small size of both this
            % adaptor and any children. Children include table variables.

            % This does not reset the RowAdaptor because that is required
            % by the tabular contract to be a column vector.
            for idx = 1:numel(obj.VariableAdaptors)
                obj.VariableAdaptors{idx} = resetNestedSmallSizes(obj.VariableAdaptors{idx});
            end
        end
        
        function obj = copySizeInformation(obj, copyFrom)
            % Overloaded for TableAdaptor - only copy the tall size, and propagate to
            % contained variables.
            obj.VariableTallArraysCache = iBuildMap();
            obj = copyTallSize(obj, copyFrom);
            obj = copyTallSizeToAllSubAdaptors(obj);
        end
        
        function displayImpl(obj, context, ~)
            if context.IsPreviewAvailable
                doDisplay(context);
            else
                previewData = fabricatePreview(obj);
                classOfPreview = obj.Class;
                doDisplayWithFabricatedPreview(context, previewData, classOfPreview, obj.NDims, obj.Size);
            end
        end
        
        function names = getProperties(obj)
            names = [obj.VariableNames, 'Properties', obj.DimensionNames];
        end
    end
    
    methods % Indexing
        function varargout = subsrefDot(obj, pa, ~, s)
            if isequal(s(1).subs, 'Properties')
                out = getPropertiesStruct(obj, pa);
            elseif isequal(s(1).subs, obj.DimensionNames{1})
                % Getting the rowtimes vector
                out = obj.getRowProperty(pa);
            elseif isequal(s(1).subs, obj.DimensionNames{2})
                if ~isscalar(s)
                    error(message('MATLAB:table:NestedSubscriptingWithDotVariables', ...
                        s(1).subs));
                end
                out = slicefun(iDotExtractVariableFunctor(s(1).subs), pa);
                dim = 2;
                adaptor = matlab.bigdata.internal.adaptors.combineAdaptors(...
                    dim, obj.VariableAdaptors);
                out = tall(out, adaptor);
            else
                allowMissing = false;
                varName = obj.resolveDotSubscript(s(1).subs, allowMissing);
                if isKey(obj.VariableTallArraysCache, varName)
                    % We have extracted this variable from the table before, so return it
                    % again. Safe because values inside tall arrays are
                    % immutable (i.e. SUBSASGN returns a fresh tall array).
                    out = obj.VariableTallArraysCache(varName);
                else
                    % Extract the variable from the table
                    out = slicefun(iDotExtractVariableFunctor(varName), pa);
                    adaptor = obj.VariableAdaptors{string(varName) == obj.VariableNames};
                    out = tall(out, adaptor);
                    obj.VariableTallArraysCache(varName) = out;
                end
            end
            [varargout{1:nargout}] = iRecurseSubsref(out, s(2:end));
        end
        
        function varargout = subsrefBraces(obj, pa, ~, s)
            if numel(s(1).subs) ~= 2
                error(message('MATLAB:table:NDSubscript'));
            end
            [firstSub, secondSub] = deal(s(1).subs{:});
            errorIfFirstSubSelectingRowsNotSupported(obj,firstSub);
            
            [~, secondSubNumeric] = obj.resolveVarNameSubscript(secondSub);
            shouldDereference = true;
            
            outValue = slicefun(iBraceExtractVariableFunctor(secondSubNumeric, shouldDereference), pa);
            dim      = 2;
            if isempty(secondSubNumeric)
                % table brace indexing selecting an empty list of variables returns Nx0 double.
                adaptor = matlab.bigdata.internal.adaptors.getAdaptorForType('double');
            elseif isscalar(secondSubNumeric)
                adaptor = obj.VariableAdaptors{secondSubNumeric};
            else
                adaptor = matlab.bigdata.internal.adaptors.combineAdaptors(...
                    dim, obj.VariableAdaptors(secondSubNumeric));
            end
            
            isFirstSubColon = matlab.bigdata.internal.util.isColonSubscript(firstSub);
            if isFirstSubColon
                % ensure the new array has linked tall size information from this object.
                adaptor = copyTallSize(adaptor, obj);
            end
            out = tall(outValue, adaptor);
            
            % Use tall subsref to select rows. Note that this is a rather imperfect
            % implementation as it presumes no more than 3 non-tall dimensions.
            if ~isFirstSubColon
                newSubs = cell(1,4);
                newSubs{1} = firstSub;
                newSubs(2:end) = {':'};
                out = subsref(out, substruct('()', newSubs));
            end
            
            [varargout{1:nargout}] = iRecurseSubsref(out, s(2:end));
        end
        
        function obj = subsasgnBraces(~, ~, ~, ~, ~) %#ok<STOUT>
            error(message('MATLAB:bigdata:table:SubsasgnBracesNotSupported'))
        end
        
        function out = subsrefParens(obj, pa, szPa, s)
            if numel(s(1).subs) ~= 2
                error(message('MATLAB:table:NDSubscript'));
            end
            
            [firstSub, secondSub] = deal(s(1).subs{:});
            errorIfFirstSubSelectingRowsNotSupported(obj,firstSub);
            
            % First off, subselect the columns specified by secondSub
            [varNames, varIdxs] = obj.resolveVarNameSubscript(secondSub);
            if ~isequal(varNames, obj.VariableNames)
                shouldDereference = false;
                selectedColumnsPa = slicefun(iBraceExtractVariableFunctor(varIdxs, shouldDereference), pa);
            else
                selectedColumnsPa = pa;
            end
            selectedAdaptors = obj.VariableAdaptors(varIdxs);
            newProps = obj.OtherProperties;
            
            % For each of the following properties, if they are non-empty, copy across only
            % the appropriate elements as indexed by varIdxs.
            propsToFilter = {'VariableUnits', 'VariableDescriptions', 'VariableContinuity'};
            for idx = 1:numel(propsToFilter)
                thisProp = newProps.(propsToFilter{idx});
                if ~isempty(thisProp)
                    newProps.(propsToFilter{idx}) = thisProp(varIdxs);
                end
            end
            
            % Make selected varNames unique then build the output adaptor
            varNames = matlab.lang.makeUniqueStrings(varNames, {}, namelengthmax);
            newAdaptor = buildDerived(obj, varNames, selectedAdaptors, ...
                obj.DimensionNames, obj.RowAdaptor, newProps);
            
            % Next, perform the row selection
            [selectedRowsAndColumnsPa, isTallSizeUnchanged, newTallSize] = ...
                subsrefParensImpl(selectedColumnsPa, szPa, ...
                substruct('()', {firstSub, ':'}));
            if isTallSizeUnchanged
                newAdaptor = copyTallSize(newAdaptor, obj);
            elseif ~isnan(newTallSize)
                % Update tall size in-place
                setTallSize(newAdaptor, newTallSize);
            end
            % Build the tall table
            tmp = tall(selectedRowsAndColumnsPa, newAdaptor);
            
            % and then recurse
            out = iRecurseSubsref(tmp, s(2:end));
        end
        
        function pa = subsasgnParens(obj, pa, szPa, s, b) %#ok<INUSD>
            error(message('MATLAB:bigdata:table:SubsasgnParensNotSupported', obj.Class));
        end
        
        function out = subsasgnParensDeleting(obj, pa, szPa, s)
            import matlab.bigdata.internal.util.isColonSubscript
            
            % The language front-end should not permit expressions where there is any form
            % of indexing following parens.
            assert(numel(s) == 1, ...
                'Assertion failed: Multiple levels of indexing passed to subsasgnParensDeleting implementation.');
            if numel(s(1).subs) ~= 2
                error(message('MATLAB:table:NDSubscript'));
            end
            
            [firstSub, secondSub] = deal(s(1).subs{:});
            
            if isColonSubscript(secondSub)
                % Delete whole slices
                if isColonSubscript(firstSub)
                    error(message('MATLAB:bigdata:table:DeleteWholeTableUsingIndexing'));
                elseif ~istall(firstSub)
                    error(message('MATLAB:bigdata:table:FirstSubscriptColonOrTallVariable'));
                end
                
                % Here we know we're left with a tall subscript in first place, we need to
                % negate it (providing it's logical)
                firstSub = tall.validateType(firstSub, 'subsasgn', {'logical'}, 1);
                out = obj.subsrefParens(pa, szPa, substruct('()', {~firstSub, secondSub}));
            else
                if matlab.bigdata.internal.util.isColonSubscript(firstSub)
                    % Deleting whole variables - negate the variable list
                    deleteNames = obj.resolveVarNameSubscript(secondSub);
                    keepNames = setdiff(obj.VariableNames, deleteNames, 'stable');
                    out = obj.subsrefParens(pa, szPa, substruct('()', {firstSub, keepNames}));
                else
                    error(message('MATLAB:table:InvalidEmptyAssignment'));
                end
            end
            
        end
        
        function out = subsasgnDot(obj, pa, szPa, s, b)
            if isequal(s(1).subs, 'Properties')
                out = subsasgnDotProperties(obj, pa, szPa, s, b);
                return
            end
            if isequal(s(1).subs, obj.DimensionNames{2})
                error(message('MATLAB:bigdata:table:SetVariablesUnsupported', ...
                    obj.DimensionNames{2}));
            end
            allowMissing = true;
            varName = obj.resolveDotSubscript(s(1).subs, allowMissing);
            
            if numel(s) == 1
                % Adding or updating a whole variable.
                if ~istall(b)
                    % Note there's no scalar expansion for "t.x = b".
                    error(message('MATLAB:bigdata:table:AssignVariableMustBeTall'));
                end
                
                bAdaptor = matlab.bigdata.internal.adaptors.getAdaptor(b);
                
                % Get the tall size of LHS and RHS - either can be NaN.
                objTallSize = obj.getSizeInDim(1);
                bTallSize   = bAdaptor.getSizeInDim(1);
                
                % If both tall sizes are non-NaN and non-equal, there's a problem.
                if ~isnan(objTallSize) && ~isnan(bTallSize) && objTallSize ~= bTallSize
                    error(message('MATLAB:bigdata:array:IncompatibleTallStrictSize'));
                end
                
                % Build a new adaptor
                names = obj.VariableNames;
                adaptors = obj.VariableAdaptors;
                
                rowPropName = obj.DimensionNames{1};
                
                if isequal(s(1).subs, rowPropName)
                    % Updating the row property
                    newAdaptor = buildDerived(obj, names, adaptors, obj.DimensionNames, ...
                        bAdaptor, obj.OtherProperties);
                else
                    newProps = obj.OtherProperties;
                    if ~ismember(varName, names)
                        names{end+1} = varName;
                        if ~isempty(newProps.VariableDescriptions)
                            newProps.VariableDescriptions{end+1} = '';
                        end
                        if ~isempty(newProps.VariableUnits)
                            newProps.VariableUnits{end+1} = '';
                        end
                    end
                    idx = find(strcmp(varName, names));
                    assert(isscalar(idx), ...
                        'Assertion failed: Could not find variable ''%s'' in subsasgnDot.', varName);
                    adaptors{idx} = bAdaptor;
                    
                    newAdaptor = buildDerived(obj, names, adaptors, obj.DimensionNames, ...
                        obj.RowAdaptor, newProps);
                end
                outPa = strictslicefun(@(t, v) iUpdateWholeVariable(t, varName, v), ...
                    pa, hGetValueImpl(b));
                out = tall(outPa, newAdaptor);
            else
                % Replacing part of variable - extract, update, replace.
                tallVar = obj.subsrefDot(pa, szPa, s(1));
                tallVar = subsasgn(tallVar, s(2:end), b);
                out     = obj.subsasgnDot(pa, szPa, substruct('.', varName), tallVar);
            end
        end
        
        function out = subsasgnDotDeleting(obj, pa, ~, S)
            if numel(S) > 1
                error(message('MATLAB:bigdata:table:DotDeletingSingleLevelIndexing'));
            end
            
            if isequal(S(1).subs, obj.DimensionNames{1})
                throwCannotDeleteRowPropertyError(obj);
            end
            if isequal(S(1).subs, obj.DimensionNames{2})
                error(message('MATLAB:bigdata:table:DeleteAllVariablesUnsupported', ...
                    obj.DimensionNames{2}));
            end
            
            allowMissing = false;
            deletingName = obj.resolveDotSubscript(S(1).subs, allowMissing);
            % Need to work out which index we're removing
            deletingTF = strcmp(deletingName, obj.VariableNames);
            outPa = slicefun(@(x) iRemoveVariable(x, deletingName), pa);
            
            newVars = obj.VariableNames(~deletingTF);
            newVarAdaptors = obj.VariableAdaptors(~deletingTF);
            newProps = obj.OtherProperties;
            if ~isempty(newProps.VariableUnits)
                newProps.VariableUnits = newProps.VariableUnits(~deletingTF);
            end
            if ~isempty(newProps.VariableDescriptions)
                newProps.VariableDescriptions = newProps.VariableDescriptions(~deletingTF);
            end
            
            newAdaptor = buildDerived(obj, newVars, newVarAdaptors, obj.DimensionNames, ...
                obj.RowAdaptor, newProps);
            out = tall(outPa, newAdaptor);
        end
        
        function out = subsasgnDotProperties(adap, pa, szPa, s, b)
            % Set the properties struct, or one of its fields. The error
            % checking for this is complex, so we use a local table to do
            % it for us.
            
            % First check for setting the row property (RowTimes, RowNames)
            % as this is the only property allowed to have tall input.
            rowSubs = substruct('.','Properties', '.', adap.RowPropertyName);
            if isequal(s, rowSubs)
                out = subsasgnRowProperty(adap, pa, szPa, b);
                return
            end
            
            % If assigning the whole properties struct, we must skip the
            % row property and do it afterwards.
            setPropStructWithRows = isequal(s, substruct('.','Properties')) ...
                 && isfield(b, adap.RowPropertyName);
             
            if setPropStructWithRows
                rowVals = b.(adap.RowPropertyName);
                b = rmfield(b, adap.RowPropertyName);
            end
            
            width = numel(adap.VariableNames);
            proto = adap.buildSample('double', [0, width]);
            proto = subsasgn(proto, s, b); % This will throw if incorrect
            
            % Now create a new adaptor with these properties
            adap.DimensionNames = proto.Properties.DimensionNames;
            adap.VariableNames = proto.Properties.VariableNames;
            adap.OtherProperties = iTrimOtherProperties(proto.Properties);
            
            % Apply the changes to the remote content too
            outPa = elementfun( @(x) iDoSubsasgn(x,s,b), pa );
            
            if setPropStructWithRows
                % Apply the row values. Note that this will build the tall array for us.
                out = subsasgnRowProperty(adap, outPa, szPa, rowVals);
            else
                % Nothing more to do. Build the output tall array.
                out = tall(outPa, adap);
            end
            
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function functor = iBraceExtractVariableFunctor(vars, shouldDereference)
functor = @fcn;
    function out = fcn(t)
        out = t(:, vars);
        if shouldDereference
            out = out{:,:};
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function functor = iDotExtractVariableFunctor(var)
functor = @fcn;
    function out = fcn(t)
        out = t.(var);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = iRemoveVariable(t, varName)
t.(varName) = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simply apply a new variable into the table, ensuring the new data is the
% correct size. The check here is only needed in rare cases (i.e. where the
% table is completely empty) - otherwise the table assignment itself actually
% throws this error. See g1367363.
function t = iUpdateWholeVariable(t, varName, v)
if size(t,1) ~= size(v,1)
    error(message('MATLAB:table:RowDimensionMismatch'));
end
t.(varName) = v;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Apply remaining indexing expressions
function varargout = iRecurseSubsref(data, S)
if isempty(S)
    varargout = {data};
else
    [varargout{1:nargout}] = subsref(data, S);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Combine 'OtherProperties' from a table during HORZCAT
function out = iHorzcatProperties(propCell, numVarsPerElement)

% Start out by copying the OtherProperties from the first item.
out               = propCell{1};

% Get an array describing how many variables each element of propCell
% corresponds to.
totalNumVars      = sum(numVarsPerElement);

% When building up the concatenating elements, we need to know where to start
% placing the outputs for each element of propCell.
varStartIdx       = cumsum([1, numVarsPerElement]);

% We need to concatenate VariableDescriptions and VariableUnits if any is non-empty
propsToConcat     = {'VariableDescriptions', 'VariableUnits', 'VariableContinuity'};
emptyVal          = {{''}, {''}, matlab.tabular.Continuity.unset };

for idx = 1:numel(propsToConcat)
    thisProp = propsToConcat{idx};
    if ~all(cellfun(@(x) isempty(x.(thisProp)), propCell))
        % Some are non-empty, need to concatenate all.
        thisEmptyVal = emptyVal{idx};
        newValue = repmat(thisEmptyVal, 1, totalNumVars);
        for jdx = 1:numel(propCell)
            propForThisElement = propCell{jdx}.(thisProp);
            if ~isempty(propForThisElement)
                assignRange = varStartIdx(jdx):(varStartIdx(jdx+1) - 1);
                newValue(assignRange) = propForThisElement;
            end
        end
        out.(thisProp) = newValue;
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Combine 'OtherProperties' from a table during VERTCAT
function out = iVertcatProperties(propCell)

% Start out by copying the OtherProperties from the first item.
out = propCell{1};

% Vertcat should take the first non-empty value for each property in the input
% tables
propNames = fieldnames(out);
for idx = 1:numel(propNames)
    thisProp = propNames{idx};
    idxFirstNonEmpty = find(cellfun(@(x) ~isempty(x.(thisProp)), propCell), 1);
    if ~isempty(idxFirstNonEmpty)
        out.(thisProp) = propCell{idxFirstNonEmpty}.(thisProp);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Combine table variable adaptors for VERTCAT
function out = iVertcatVariableAdaptors(varargin)
% For each vertcat input, use the rules defined in combineAdaptors to merge
% the variable adaptors for the final output table.

import matlab.bigdata.internal.adaptors.combineAdaptors

out = varargin{1}.VariableAdaptors;

for ii=2:numel(varargin)
    nextAdaptors = varargin{ii}.VariableAdaptors;
    
    for jj=1:numel(out)
        try
            out{jj} = combineAdaptors(1, {out{jj}, nextAdaptors{jj}});
        catch
            failedVariableName = varargin{1}.VariableNames{jj};
            
            error(message('MATLAB:table:vertcat:VertcatMethodFailed', ...
                failedVariableName));
        end
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build a name-value map
function map = iBuildMap()
map = containers.Map('KeyType', 'char', ...
    'ValueType', 'any');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trim a table properties structure to store in OtherProperties
function props = iTrimOtherProperties(props)
propsToRetain  = matlab.bigdata.internal.adaptors.TabularAdaptor.OtherPropertiesFields;
fieldsToRemove = setdiff(fieldnames(props), propsToRetain);
props          = rmfield(props, fieldsToRemove);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform a subsasgn on the remote content
function x = iDoSubsasgn(x,s,b)
x = subsasgn(x,s,b);
end
