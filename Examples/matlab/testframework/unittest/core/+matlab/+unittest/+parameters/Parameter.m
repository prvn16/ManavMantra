classdef Parameter < matlab.mixin.Heterogeneous
    % Parameter - Abstract interface for parameters.
    %
    %   Parameters provide the ability to pass data to methods defined in a
    %   TestCase class.
    %
    %   Parameter properties:
    %       Property - Name of the property that defines the Parameter
    %       Name     - Name of the Parameter
    %       Value    - Value of the Parameter
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    
    properties (SetAccess=private)
        % Property - Name of the property that defines the Parameter
        %
        %   This property is a string which identifies property
        %   that defines the Parameter.
        Property = '';
        
        % Name - Name of the Parameter
        %
        %   The Name property is a string which uniquely identifies a
        %   particular value for a Parameter.
        Name = '';
        
        % Value - Value of the Parameter
        %
        %   The Value property holds the data that the Test Runner passes
        %   into the parameterized method that uses the Parameter.
        Value = [];
    end
    
    
    properties (Constant, Access=protected)
        DefaultCombinationAttribute = 'exhaustive';
    end

    
    methods (Hidden, Static, Abstract)
        % getParameters - Get Parameters for a class.
        %
        %   The getParameters method returns parameter information.
        parameters = getParameters(testClass);
        
        % fromName - Construct a single Parameter given the Name.
        %
        %   The fromName method constructs a scalar Parameter instance
        %   given the Property Name and Name of a parameter.
        parameter = fromName(testClass, propName, name);
    end
    
    
    methods (Access=protected)
        function param = Parameter(prop, name)
            % Parameter - Construct a Parameter array from a matlab.unittest.meta.property.
            %
            %   This method constructs an array of Parameter objects based on the
            %   parameter values defined by the property.
            
            import matlab.unittest.internal.parameters.getParameterNames;
            
            % Allow zero-input constructor for pre-allocation.
            if nargin == 0
                return;
            end
            
            validateattributes(prop, {'matlab.unittest.meta.property'}, {'scalar'}, '', 'property');
            
            % Parameter properties must define a default value which is a
            % scalar structure with at least one field or a non-empty cell
            % array. For the cellstr case, use makeUniqueStrings/makeValidName
            % to generate valid names. For an arbitrary cell, just make up
            % names 'value1', 'value2', etc.
            default = prop.DefaultValue(:);
            
            if iscell(default)
                names = getParameterNames(default);
                default = cell2struct(default, names);
            end
            
            if nargin > 1
                % Keep only the specified field
                singleField.(name) = default.(name);
                default = singleField;
            end
            
            flds = fieldnames(default);
            vals = struct2cell(default);
            
            % Create an array with one element for each field in the structure.
            param(1:numel(flds)) = param;
            
            [param.Property] = deal(prop.Name);
            [param.Name] = flds{:};
            [param.Value] = vals{:};
        end
    end
    
    
    methods (Hidden, Static)
        function param = fromData(paramConstructor, prop, name, value)
            param = paramConstructor();
            param.Property = prop;
            param.Name = name;
            param.Value = value;
        end
    end
    
    
    methods (Hidden, Sealed)
        function params = filterByClass(params, desiredClass)
            % filterByClass - Return the elements of the Parameter array
            %   that are of the specified class.
            
            actualClasses = cell(1, numel(params));
            for idx = 1:numel(params)
                actualClasses{idx} = class(params(idx));
            end
            
            params = params(strcmp(actualClasses, desiredClass));
        end
        
        function inputs = getInputsFor(testParams, method)
            % getInputsFor - Get input parameter values for a method.
            %
            %   getInputsFor returns a cell array of parameter values to be passed to a
            %   method. The values are taken from the specified array of Parameters. If
            %   the method does not belong to a matlab.unittest.TestCase class or if
            %   the method is not parameterized, an empty cell array is returned.
            
            import matlab.unittest.parameters.Parameter;
            
            % Only methods defined inside a matlab.unittest.TestCase class
            % can be parameterized.
            if ~(metaclass(method) <= ?matlab.unittest.meta.method)
                inputs = cell(1,0);
                return;
            end
            
            parameterNames = Parameter.getParameterNamesFor(method);
            paramProps = {testParams.Property};
            numInputs = numel(parameterNames);
            
            inputs = cell(1,numInputs);
            for idx = 1:numInputs
                % There should be exactly one Parameter in the array whose
                % Property matches the desired parameter name.
                inputs{idx} = testParams(strcmp(parameterNames{idx}, paramProps)).Value;
            end
        end
    end
    
    
    methods (Hidden, Sealed, Static, Access=protected)
        function instance = getDefaultScalarElement
            instance = matlab.unittest.parameters.EmptyParameter;
        end
        
        function parameterNames = getParameterNamesFor(method)
            % getParameterNamesFor - Get the names of the parameters a method references.
            
            parameterNames = method.InputNames;
            
            % Remove TestCase input argument
            if numel(parameterNames) > 0
                parameterNames(1) = [];
            end
            
            % Always return a row vector
            parameterNames = reshape(parameterNames, 1, []);
        end
        
        function combined = combineParameters(parameters, combinationAttribute)
            % combineParameters - Combine a cell array of parameters
            %   according to the value of the ParameterCombination attribute.
            
            import matlab.unittest.parameters.Parameter;
            
            if strcmp(combinationAttribute, '')
                combinationAttribute = Parameter.DefaultCombinationAttribute;
            end
            
            switch combinationAttribute
                case 'exhaustive'
                    combined = combineExhaustively(parameters);
                case 'sequential'
                    combined = combineSequentially(parameters);
                case 'pairwise'
                    combined = combinePairwise(parameters);
            end
        end
    end
end


function allCombinations = combineExhaustively(parameters)
% combineExhaustively - Combine parameters exhaustively.
%
%   combineExhaustively returns a cell array of all combinations of the parameters.

parameterSizes = cellfun(@numel, parameters);
numParameters = numel(parameters);

% Define grids for indexing into the Parameters to create all combinations.
% Use FLIPLR twice to get canonical ordering.
indices = fliplr(arrayfun(@(sz)1:sz, parameterSizes, 'UniformOutput',false));
[grids{1:numParameters}] = ndgrid(indices{:});
grids = fliplr(grids);

% Covert to an array of indices
grids = cellfun(@(g)g(:), grids, 'UniformOutput',false);
allCombIdx = [grids{:}];

allCombinations = combineAccordingToIndices(parameters, allCombIdx);
end


function sequentialOrdering = combineSequentially(parameters)
% combineSequentially - Combine test parameters sequentially.
%
%   Create a cell array of a sequential ordering of the parameters.
%   Corresponding elements are selected from each vector of parameters in
%   the input cell array. Each vector of parameters must have the same
%   number of elements.

parameterSize = numel(parameters{1});
parameters = cellfun(@(p)reshape(p,[],1), parameters, 'UniformOutput',false);
sequentialOrdering = rot90(mat2cell([parameters{:}], ones(1,parameterSize), numel(parameters)));
end


function combined = combinePairwise(parameters)
% combinePairwise - Combine to cover all pairs of parameter values.
%
%   Reference:
%   Kuo-Chung Tai and Yu Lei, "A Test Generation Strategy for Pairwise Testing,"
%   IEEE Transactions on Software Engineering, vol. 28, no. 1, pp. 109-111, 2002.


parameterSizes = cellfun(@numel, parameters);
numParameters = numel(parameters);

if numParameters < 2
    % Nothing to combine
    combinedIdx = (1:parameterSizes).';
else
    % Start by generating all pairs of the first two parameters
    [X, Y] = meshgrid(1:parameterSizes(1), 1:parameterSizes(2));
    combinedIdx = [X(:), Y(:)];
end

% Loop over the remaining parameters and add pairs. For each loop
% iteration, add rows/columns to cover all pairs of existing parameters
% with the parameter being introduced that iteration.
for parameterIdx = 3:numParameters
    numValsCurrentParam = parameterSizes(parameterIdx);
    numExistingParameters = parameterIdx - 1;
    
    % Define masks to keep track of which pairs have been covered.
    % uncovered{i}(j,k) tells us whether parameter i, value j has been
    % paired with the current parameter (referred to by parameterIdx), value k.
    uncovered = arrayfun(@(rows)true(rows,numValsCurrentParam), ...
        parameterSizes(1:numExistingParameters), 'UniformOutput',false);
    
    % Horizontal and Vertical growth
    [combinedIdx, uncovered] = horizontalGrowth(parameterIdx, ...
        parameterSizes, combinedIdx, uncovered);
    growth = verticalGrowth(parameterIdx, uncovered);
    combinedIdx = [combinedIdx; growth]; %#ok<AGROW>
end

% Any remaining unused slots can be filled with any value. Use row and
% column indices to generate values deterministically but with some variety.
for row = 1:size(combinedIdx,1)
    for col = 1:numParameters
        if combinedIdx(row,col) == 0
            combinedIdx(row,col) = mod(row+col, parameterSizes(col)) + 1;
        end
    end
end

% Use the generated indices to create the specific parameter realizations
combined = combineAccordingToIndices(parameters, combinedIdx);
end

function [combinedIdx, uncovered] = horizontalGrowth(whichParam, paramSizes, combinedIdx, uncovered)
% horizontalGrowth - Extend pairwise coverage for an additional parameter

numVals = paramSizes(whichParam);
numExistingParameters = whichParam - 1;

% Append parameters in order
for currentParamIdx = 1:min(numVals, size(combinedIdx,1))
    combinedIdx(currentParamIdx, whichParam) = currentParamIdx;
    
    % Record covered pairs
    for existingParamIdx = 1:numExistingParameters
        % Because we are just now introducing a new parameter, we can
        % increase coverage by filling in any empty slots with any value.
        if combinedIdx(currentParamIdx, existingParamIdx) == 0
            combinedIdx(currentParamIdx, existingParamIdx) = ...
                mod(currentParamIdx+existingParamIdx, paramSizes(existingParamIdx)) + 1;
        end
        
        uncovered{existingParamIdx}(combinedIdx(currentParamIdx, existingParamIdx), ...
            combinedIdx(currentParamIdx, whichParam)) = false;
    end
end

% For the remaining parameters, add the parameter value to each row that
% will cover the maximum number of uncovered pairs
for combIdx = numVals+1:size(combinedIdx,1)
    [coverage, emptySlotsUsed] = getParameterCoverage(combinedIdx(combIdx,:), numVals, uncovered);
    maxCoverage = max(coverage);
    if maxCoverage == 0
        % No coverage to be gained; leave open for future use
        continue;
    end
    
    % Handle ties by choosing the value that leaves the most empty slots
    % open for future use.
    maxCoverageIdx = find(coverage == maxCoverage);
    [~, minSlotsUsedIdx] = min(emptySlotsUsed(maxCoverageIdx));
    maxCoverageIdx = maxCoverageIdx(minSlotsUsedIdx);

    % Add and record the value
    combinedIdx(combIdx, whichParam) = maxCoverageIdx;
    for existingParamIdx = 1:numExistingParameters
        idx = combinedIdx(combIdx,existingParamIdx);
        if idx ~= 0
            uncovered{existingParamIdx}(idx, maxCoverageIdx) = false;
        end
    end
    
    % Fill in any empty slots that provide additional coverage
    for existingParamIdx = 1:numExistingParameters
        if combinedIdx(combIdx, existingParamIdx) == 0
            idx = combinedIdx(combIdx, whichParam);
            addIdx = find(uncovered{existingParamIdx}(:,idx));
            
            % If addIdx is empty, we already have maximum coverage and the
            % slot should be left open for future use.
            if ~isempty(addIdx)
                % Tie-break: use the parameter value with the most
                % uncovered pairs left to go.
                [~, maxValuesIdx] = max(sum(uncovered{existingParamIdx}(addIdx,:),2));
                addIdx = addIdx(maxValuesIdx);
                    
                % Fill the slot and record the covered pair.
                combinedIdx(combIdx, existingParamIdx) = addIdx;
                uncovered{existingParamIdx}(addIdx, idx) = false;
            end
        end
    end
end
end

function [coverage, emptySlotsUsed] = getParameterCoverage(combRow, numVals, uncovered)
% getParameterCoverage - Determine how many uncovered pairs would be covered
%   as a result of choosing each value for the parameter in the last column.
%   Also determine the number of empty "don't care" slots used in each case.

coverage = zeros(1, numVals);
emptySlotsUsed = zeros(1, numVals);

% Loop over all existing parameters
for paramIdx = 1:numel(combRow) - 1
    idx = combRow(paramIdx);
    if idx == 0
        % For empty slots, see if any possible pair would result in
        % additional coverage.
        newCoverage = any(uncovered{paramIdx});
        coverage = coverage + newCoverage;
        
        % Keep track of how many empty slots we have to use because we want
        % to avoid filling unused slots in tie-break scenarios.
        emptySlotsUsed = emptySlotsUsed + newCoverage;
    else
        % For already filled slots, check if each pair is uncovered.
        coverage = coverage + uncovered{paramIdx}(idx, :);
    end
end
end

function growth = verticalGrowth(whichParam, uncovered)
% verticalGrowth - Generate minimum number of new rows to cover parameters

growth = zeros(0, whichParam);

% Loop over all existing parameters
for paramIdx = 1:whichParam-1
    % Find all the uncovered pairs for this parameter
    [p1, p2] = find(uncovered{paramIdx});
    
    for pairIdx = 1:numel(p1)
        openSlot = find((growth(:,paramIdx)==0) & (growth(:,whichParam)==p2(pairIdx)), 1, 'first');
        
        if isempty(openSlot)
            % No empty slot; need to grow. Zero is "empty" placeholder.
            growth(end+1, [paramIdx, whichParam]) = [p1(pairIdx), p2(pairIdx)]; %#ok<AGROW>
        else
            % Fill in the empty slot
            growth(openSlot, paramIdx) = p1(pairIdx);
        end
    end
end
end


function combined = combineAccordingToIndices(parameters, indices)
% combineAccordingToIndices - Combine parameters given an array of indices

numParameters = numel(parameters);
numCombinations = size(indices,1);
combined = cell(1, numCombinations);

for combIdx = 1:numCombinations
    thisCombination = cell(1, numParameters);
    for paramIdx = 1:numParameters
        thisCombination{paramIdx} = parameters{paramIdx}(indices(combIdx, paramIdx));
    end
    combined{combIdx} = [thisCombination{:}];
end
end


% LocalWords:  flds vals sz Kuo Tai Yu codetools lang
