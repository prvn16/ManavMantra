classdef DataTypeSelector < handle
% DataTypeSelector Return DataTypeSelector object
%
%     Syntax:
%        DTS = DataTypeSelector returns the
%        DataTypeSelector object with SafetyMargin, AbsTol, RelTol, Signedness,
%        WordLength and Scaling properties
%     
%        DTS = DataTypeSelector(varargin) return the 
%        DataTypeSelector object which takes in "name-value" pairs  
%        for the writable properties of the object
%        
%     
%
%   Examples:
%   % Create a DataTypeSelector object
%   a  = fixed.DataTypeSelector()
%
%   % Set writable properties of DataTypeSelector object  
%   % Sets safetyMargin of a DataTypeSelector object 
%   a = fixed.DataTypeSelector()
%   a.SafetyMargin = 0.1
%
%   % Read properties of DataTypeSelector object
%   % Reads proposed datatypes by DataTypeSelector object
%   a = fixed.DataTypeSelector();
%   [nt, qError] = a.propose([1, 1.1, 1.2, 1.3, 1.4, 1.5], numerictype(1,8,7))
%  
% %  nt =
% %  
% % 
% %           DataTypeMode: Fixed-point: binary point scaling
% %             Signedness: Unsigned
% %             WordLength: 8
% %         FractionLength: 7
% % 
% % 
% % qError = 
% % 
% %     Id    Values    RepresentableValues    QuantizationError    
% %     __    ______    ___________________    _________________    
% % 
% %     1     0.1       0.10156                0.0015625             
% %     2     0.2       0.20312                 0.003125             
% %     3     0.3       0.29688                 0.003125             

%   Copyright 2013-2016 The MathWorks, Inc.

    % SetObservable variables. On changing this property, dependent
    % variables will get recalculated
    properties (SetObservable, AbortSet)
        %SafetyMargin 
        % SafetyMargin constraint adjusts the min and max values of
        % input data by the given value to shift the range window
        SafetyMargin;
        %AbsTol 
        % AbsTol constraint specifies Absolute Tolerance
        % threshold set to meet the quantization error 
        AbsTol;
        %RelTol
        % RelTol constraint specifies Relative Tolerance
        % threshold set to meet the quantization error
        RelTol;
        %Signedness
        % Signedness constraint specifies if Signedness should
        % be auto determined from input data or used from input type
        Signedness;
        %WordLength
        % WordLength constraint specifies if WordLength can be 
        % auto or lock 
        WordLength;
        %Scaling
        % Scaling constraint specified if Scaling can be auto or lock
        Scaling;
    end
    properties (Hidden)
        AutoLockValues = {'Auto', 'Lock'};
        % selector object which is configured for chosen constraints and
        % chosen input data type to decide the strategy 
        Selector;
        SelectionCode;
        isSelectorSet = false;
    end
    methods 
        %DataTypeSelector   constructs a DataTypeSelector object with given set of arguments
        function DTS = DataTypeSelector(varargin)
            default = [];
            % construct an input parser
            p=inputParser; % input parser initialization 
            p.CaseSensitive=0; % set parser to case-insensitive
            p.KeepUnmatched=0; % set parser to unmatched argument set to allow var arg
            
            % set rules to check for input arguments
            checkSafetyMargin=@(x) DTS.validateSafetyMargin(x);
            checkAbsTol=@(x) DTS.validateAbsTol(x);
            checkRelTol=@(x) DTS.validateRelTol(x);
            checkSignedness=@(x)DTS.validateSignedness(x);
            checkWordLength=@(x)DTS.validateWordLength(x);
            checkScaling=@(x)DTS.validateScaling(x);
            
            % add parameters to input parser
            addParamValue(p, 'SafetyMargin', 0, checkSafetyMargin); %#ok % add check for safety margin 
            addParamValue(p, 'AbsTol', default, checkAbsTol); %#ok % add check for absolute tolerance
            addParamValue(p, 'RelTol', default, checkRelTol); %#ok % add check for relative tolerance
            addParamValue(p, 'Signedness', 'Auto', checkSignedness); %#ok % add check for signedness
            addParamValue(p, 'WordLength', 'Lock', checkWordLength); %#ok % add check for wordlength
            addParamValue(p, 'Scaling', 'Auto', checkScaling); %#ok % add check for scaling
            
            try
                % parse  arguments
                parse(p, varargin{:});
            catch err
                rethrow(err);
            end
            % set input arguments as DTS members
            DTS.SafetyMargin = p.Results.SafetyMargin;
            DTS.AbsTol = p.Results.AbsTol;
            DTS.RelTol = p.Results.RelTol;
            DTS.Signedness = p.Results.Signedness;
            DTS.WordLength = p.Results.WordLength;
            DTS.Scaling = p.Results.Scaling;          
        end
        % clone call for DTS
        function dtsClone = clone(DTS)
            dtsClone = fixed.DataTypeSelector;
            dtsClone.Signedness = DTS.Signedness;
            dtsClone.WordLength = DTS.WordLength;
            dtsClone.Scaling = DTS.Scaling;
            dtsClone.SafetyMargin = DTS.SafetyMargin;
            dtsClone.AbsTol = DTS.AbsTol;
            dtsClone.RelTol = DTS.RelTol;
        end
        
        %SafetyMargin   sets DataTypeSelector safety margin property
        function set.SafetyMargin(DTS, value)
            try
                DTS.validateSafetyMargin(value) % check if safetyMargin is valid
                DTS.SafetyMargin = value;
            catch invalidSMErr
                DAStudio.error('fixed:datatypeselector:invalidSafetyMarginConstraint');
            end
        end
        %AbsTol     sets DataTypeSelector AbsTol property
        function set.AbsTol(DTS, value) 
            try
                DTS.validateAbsTol(value) % check if absoluteTolerance is valid
                DTS.AbsTol = value;
                DTS.isSelectorSet = false; %#ok
            catch invalidAbsTolErr
                DAStudio.error('fixed:datatypeselector:invalidAbsTolConstraint');
            end
        end
        %RelTol     sets DataTypeSelector RelTol property
        function set.RelTol(DTS, value) 
            try
                DTS.validateRelTol(value) % check if relativeTolerance is valid
                DTS.RelTol= value;
                DTS.isSelectorSet = false; %#ok
            catch err
                id = 'fixed:datatypeselector:invalidRelTolConstraint';
                messageStr = message(id).getString;
                err = MException(id, messageStr);
                throw(err);
            end
        end
        %Signedness     sets Signedness property
        function set.Signedness(DTS,value)
            try
                DTS.validateSignedness(value) % check if signedness is valid
                DTS.Signedness = value;
                DTS.isSelectorSet = false; %#ok
            catch invalidSignednessErr
                DAStudio.error('fixed:datatypeselector:invalidSignednessConstraint');
            end
        end
        %WordLength     sets DataTypeSelector WordLength property
        function set.WordLength(DTS, value)
            try
                DTS.validateWordLength(value) % check if Mode is valid
                DTS.WordLength = value;
                DTS.isSelectorSet = false; %#ok
            catch invalidWLErr
                DAStudio.error('fixed:datatypeselector:invalidWordLengthConstraint');
            end
        end
        %Scaling    sets DataTypeSelector Scaling property
        function set.Scaling(DTS, value)
            try
                DTS.validateScaling(value) % check if Mode is valid
                DTS.Scaling = value;
                DTS.isSelectorSet = false; %#ok
            catch invalidScalingErr
               DAStudio.error('fixed:datatypeselector:invalidScalingConstraint');
            end
        end
    end
    methods(Access = public)
        function [proposedDataType, qErr] = propose(DTS, values, inputType)
            %propose    Propose datatype for user given input data and constraints
            %   [proposedDataType, qErr] = propose(values, inputType) will
            %   return output numerictype  and quantization error observed
            %   based on input numerictype (inputType) and input data (values)
           try
               DTS.validateValues(values) 

               % Parse input values to handle row vectors, values of non-double numeric
               % types and complex values.
               values = DTS.getParsedValues(values);
           catch invalidValuesErr
               DAStudio.error('fixed:datatypeselector:invalidValues');
           end
           
           try
               DTS.validateInputType(inputType)
           catch err
               DAStudio.error('fixed:datatypeselector:invalidType');
           end
           
           [DTS.Selector, DTS.SelectionCode] = DTS.chooseSelectionStrategy();
           % initialize scaling factory 
           scalingFactory = DTS.initScalingFactory(inputType);

           % select strategy based on user configured constraints
           DTS.Selector = DTS.chooseSelectionStrategyOnType(inputType);

           if(DTS.Selector ~= 0)
                % Initiate DTS
                DTS.Selector.Parent = DTS;
           end
           
           % apply safety margin on data
           values = DTS.applySafetyMarginOnData(values);

           % apply signedness from constraints
           inputType = DTS.determineSignednessFromConstraint(values, inputType);
           
           % Simulink does not support fixed point types that are signed with word length 1.
           % Ex: fixdt(1,1,0) is not a valid type in Simulink.
           if fixed.isSignedOneBit(inputType)
               % Ex:
               % baseDataType = fixdt(0,1,0)
               % groupRange   = [-1 1]
               % proposedDataType = fixdt(1,1,-2) -> dataTypeSelector gives this as the
               % output for fraction length selection policy
               % proposedDataType after correction of wordlength -> fixdt(1,2,0)
               inputType.WordLength = 2;
           end

           if DTS.SelectionCode ~= 0
               % use selector to propose data type
               proposedDataType = DTS.Selector.propose(values, inputType, scalingFactory);

               if (~isempty(DTS.RelTol) || ~isempty(DTS.AbsTol))
                   % check if quantization error meets set tolerance constraints
                   [isErrorToleranceMet, expectedErrorTolerance] = checkErrorTolerance(DTS, values, proposedDataType);

                   % calculate quantization error
                   qErr = quantizationError(DTS, values, proposedDataType, expectedErrorTolerance);

                   if ~isErrorToleranceMet
                        DAStudio.warning('fixed:datatypeselector:noTolerancesMet');
                   end
               else
                   qErr = [];
               end
           else
               proposedDataType = inputType;
               qErr = [];
           end
        end
         % Get QuantizationError
        % Computes quantization error observed on representing input values
        % using input numerictype
        %
        % Arguments:
        %   values : array of finite, real, double values 
        % inputType: Simulink.NumericType or embedded.numerictype of fixed point data type
        %
        % Returns:
        %   stats: matlab table object representing quantization error while representing values using inputType
        %
        function stats = quantizationError(DTS, values, inputType, expectedError)
            [qError, repValues] = DTS.getQError(values, inputType);
            id = (1:length(values))';
            if ~isempty(DTS.AbsTol) || ~isempty(DTS.RelTol)
                stats = table(id, values,  repValues,  qError, expectedError, 'VariableNames', {'Id', 'Values' 'RepresentableValues' 'QuantizationError' 'ErrorTolerance'});
            end
        end
    end
    methods(Hidden = true)
        function [isErrorToleranceMet, expectedError] = checkErrorTolerance(DTS, values, proposedDataType)
        % CheckErrorTolerance
        % checks if a difference between input values and representable
        % values are within set AbsTol and RelTol constraints
        %
        % Arguments:
        %                   values: desired set of double values
        %                   quantizationError: difference between values and representable values
        % Returns:
        %        isErrorToleranceMet: 1 if quantization error is within tolerance limits given the AbsTol, RelTol constraints.Tolerance is calculated as  max(AbsTol, RelTol * abs(val))
        %
            quantizationError = DTS.getQError(values, proposedDataType);
            expectedError = zeros(size(values));
            if ~isempty(DTS.RelTol)
                expectedError = abs(values).*DTS.RelTol;
            end
            if ~isempty(DTS.AbsTol)
                expectedError = max(DTS.AbsTol, expectedError);
            end
            result = quantizationError <= expectedError;
            if ( min(result) || (isempty(DTS.AbsTol) && isempty(DTS.RelTol)))
                isErrorToleranceMet =1;
            else
                isErrorToleranceMet = 0;
            end
            
        end
    end
    methods(Access = private)
        % initScalingFactory
        function scalingFactory = initScalingFactory(DTS, inputType)
            if DTS.isSlopeBiasScaling(inputType)
                scalingFactory = fixed.SlopeBiasScaling;
            else
                scalingFactory = fixed.BinaryPointScaling;
            end
        end
        % DetermineSignednessFromConstraint
        % Determine signedness of input type based on values if
        % AutoSignedness is on or use input type's signedness if 
        %
        % Arguments:
        %      values: input values
        %   inputType: input numerictype
        %
        % Returns:
        %   inputType: with Signedness set as that of DTS.constraints
        %
        function inputType = determineSignednessFromConstraint(DTS, values, inputType)
            if DTS.isAutoSignedness()
                % auto-determine signedness from the range of values
                signednessFromData = DTS.getSignedness(min(values));
                if inputType.Signed ~= signednessFromData
                    inputType.Signed = signednessFromData;
                end
            end
        end
        % choose selection strategy 
        % Choose selection strategy based  on constraints
        % Arguments: 
        %   inputType: input numerictype
        % Returns:
        %    selector: selector object configured for proposal
        % 
        function [selector, code] = chooseSelectionStrategy(DTS)
             % NumericTypeSelector could have been set because of input type.
             % Need to reevaluate selector in that case.
            if ~DTS.isSelectorSet || isa(DTS.Selector, 'fixed.NumericTypeSelector')
                code = 0;
                if strcmpi(DTS.WordLength, 'Auto') == 1
                    code = 1;
                end
                code = code*2;
                if strcmpi(DTS.Scaling, 'Auto') == 1
                    code = code + 1;
                end
                if code == 1 || ( code == 3 && isempty(DTS.AbsTol) && isempty(DTS.RelTol) )
                    if code == 3
                        DAStudio.warning('fixed:datatypeselector:switchModeOnUnspecifiedConstraints');
                    end
                    selector = fixed.BestPrecisionScalingSelector;
                elseif code == 2 
                    selector = fixed.MinWordSizeSelector;
                elseif code == 0
                    selector = 0;
                else
                    selector = fixed.NumericTypeSelector;
                end
                DTS.isSelectorSet = true;
            else
                selector = DTS.Selector;
                code = DTS.SelectionCode;
            end
        end
        % choose selection strategy on inputType
        % Choose selection strategy based  on inputType
        % Arguments: 
        %   inputType: input numerictype
        % Returns:
        %    selector: selector object configured for proposal
        % 
        function selector = chooseSelectionStrategyOnType(DTS, inputType)
            if (DTS.SelectionCode == 2 && DTS.isScalingUnSpecified(inputType))
                DAStudio.warning('fixed:datatypeselector:switchModeOnUnspecifiedScaling');
                selector = fixed.NumericTypeSelector;
            else
                selector = DTS.Selector;
            end
        end
        % validate Signedness
        % Check if signedness is 'Lock' or 'Auto'
        % Arguments: 
        %     value: Signedness value
        % Returns:
        %   Boolean value indicating if Signedness is valid value or
        %   not
        function validateSignedness(DTS, value)
            isValidSignedness = false;
            if ~isnumeric(value) && ischar(value) 
               if any(ismember(DTS.AutoLockValues, value))
                    isValidSignedness = true;
               end
            end
            if ~isValidSignedness
                DAStudio.error('fixed:datatypeselector:invalidSignednessConstraint');
            end
            
        end
        % validate Scaling
        % Check if scaling is 'Lock' or 'Auto'
        % Arguments: 
        %     value: scaling value
        % Returns:
        %   Boolean value indicating if scaling is valid value or
        %   not
        function validateScaling(DTS, value)
            isValidScaling = false;
            if ~isnumeric(value) && ischar(value) 
               if any(ismember(DTS.AutoLockValues, value))
                    isValidScaling = true;
               end
            end
            if ~isValidScaling
               DAStudio.error('fixed:datatypeselector:invalidScalingConstraint');
            end
        end
        % validate WordLength
        % Check if wordlength is 'Lock' or 'Auto'
        % Arguments: 
        %     value: Wordlength value
        % Returns:
        %   Boolean value indicating if WordLength is valid value or
        %   not
        function validateWordLength(DTS, value)
            isValidWordLength = false;
            if ~isnumeric(value) && ischar(value) 
               if any(ismember(DTS.AutoLockValues, value))
                    isValidWordLength = true;
               end
            end
            if ~isValidWordLength
                DAStudio.error('fixed:datatypeselector:invalidWordLengthConstraint');
            end
        end
        % validateInputType
        % Check if inputType value is valid. 
        % Simulink.NumericType, embedded.numerictype are allowable values.
        % Arguments: 
        %     value: inputType 
        % Returns:
        %   Boolean value indicating if inputType is valid type or
        %   not
        function validateInputType(DTS, value)
            if ~((isa(value,'embedded.numerictype') == 1 || strcmpi(class(value), 'Simulink.NumericType') == 1 ) && DTS.isFixedPoint(value))
                DAStudio.error('fixed:datatypeselector:invalidType');
            end
        end

       
        % applySafetyMarginOnData
        % Calculates maximum and minimum value of input values given the safetyMargin 
        %
        % Arguments:
        %       values: input values for which safetyMargin is given
        % safetyMargin: valid safetyMargin value between [-100, 100]
        % Returns:
        %       values: input values where the min and max values have
        %       safetyMargin applied on them. 
        %
        function values = applySafetyMarginOnData(DTS, values)
            [ytmax] = max(values);
            [ytmin] = min(values);
            ymax = ytmax * (1  + (DTS.SafetyMargin/100) );
            ymin = ytmin * (1  + (DTS.SafetyMargin/100) );
            values(values == ytmax) = ymax;
            values(values == ytmin) = ymin;
        end
        % isAutoSignedness
        % Check if auto-signedness is turned on
        %
        % Arguments:
        %       N/A
        % Returns:
        %   isAutoSignedness : 1 if Signedness is constraint is set of
        %   'Auto', 0 other wise
        %
        function isAuto=isAutoSignedness(DTS)
            if strcmpi(DTS.Signedness, 'Auto') == 1
                isAuto = 1;
            else
                isAuto = 0;
            end
        end
    end
    methods(Static = true, Hidden = true)
        % isSlopeBiasScaling
        % Check if slope bias scaling - determines if the numerictype is of slope bias scaling or binary point scaling
        %
        % Arguments:
        %                nt: input numerictype of fixed point data type
        % Returns:
        %       isSlopeBias: 1 if scaling of nt is slope bias, 0 otherwise
        function isSlopeBias=isSlopeBiasScaling(nt)
            isSlopeBias =  (strcmpi(nt.DataTypeMode, 'Fixed-point: slope and bias scaling') == 1);
        end
        % isScalingSpecified
        % check if input type is of fixed point data type of unspecified
        % scaling, if so, returns false
        function unspecifiedScaling = isScalingUnSpecified(inputType)
            dtm = inputType.DataTypeMode;
            if strcmpi(dtm, 'Fixed-point: unspecified scaling') == 1
                unspecifiedScaling = 1;
            else
                unspecifiedScaling = 0;
            end
        end
        
        % validateAbsTol
        % Check if AbsTol value is valid
        % Valid values are [0,Inf)
        % Arguments: 
        %     value: AbsTol value
        % Returns:
        %   Boolean value indicating if AbsTol is valid value or
        %   not
        function validateAbsTol(value)
            if ~(isempty(value) || ( max(value >=0 )==1 && isnumeric(value) && isreal(value) && min(isfinite(value))==1 && numel(value) == 1)) % AbsTol in [0, Inf)
                DAStudio.error('fixed:datatypeselector:invalidAbsTolConstraint');
            end
        end
        % validateSafetyMargin
        % Check if safetyMargin value is valid
        % Valid values are [0,1]
        % Arguments: 
        %     value: safetyMargin value
        % Returns:
        %   Boolean value indicating if safetyMargin is valid value or
        %   not
        function validateSafetyMargin(value)
            if ~(isnumeric(value) && isreal(value) && isfinite(value))  % safetyMargin in [-100, 100]
                DAStudio.error('fixed:datatypeselector:invalidSafetyMarginConstraint');
            end
        end
        % validateRelTol
        % Check if relativeTolerance value is valid
        % Valid values are non negative, real and finite
        % Arguments: 
        %     value: relativeTolerance value
        % Returns:
        %   Boolean value indicating if relativeTolerance is valid value or
        %   not
        function validateRelTol(value)
            if ~((isempty(value)) || ( max(value >=0 )==1 && isnumeric(value) && isreal(value) && min(isfinite(value))==1 && numel(value) == 1)) % RelTol [0,1]
                DAStudio.error('fixed:datatypeselector:invalidRelTolConstraint');
            end
        end
       
        % validateValues
        % Check if inputValues is valid. 
        % 
        % Arguments: 
        %     value: finite real double array of values
        % Returns:
        %   Boolean value indicating if input data is valid or
        %   not
        function validateValues(value)
            if ~(~isempty(value) && isnumeric(value) && all(isfinite(value(:)))) % values should be real, finite and double
                DAStudio.error('fixed:datatypeselector:invalidValues');
            end
        end
        % GetSignedness
        % Determines the signedness of the proposed data type given the range of input values
        %
        % Arguments:
        %       rangeMin: minimum value of the input range
        % Returns:
        %       isSigned: 1 if rangeMin < 0, 0 otherwise
        %
        function isSigned = getSignedness(rangeMin)
            if rangeMin >= 0
                    isSigned = 0;
            else
                isSigned = 1;  
            end
        end
        % GetQError
        % Determines the maximum abs and rel error given the input values and representable values via the proposed data types
        %
        % Arguments:
        %       inputNumericType: input numerictype required to represent values
        %                 values: double array of values
        % Returns:
        %      quantizationError: observed quantizationError while
        %      representing input values and representable values
        %      representedValues: values represented by input numerictype
        % 
        function [quantizationError, rVal] = getQError(values, inputNumericType)
            fiObjs = fi(values, inputNumericType);             % construct fi obj
            rVal = fiObjs.data;
            quantizationError = abs(rVal - values);          % actual error induced by fixpt representation
        end
        % isFixedPoint
        % Check if numerictype is a fixed point data type
        %
        % Arguments: 
        %               nt: input numerictype of fixed point data type
        % Returns:
        %       isFixPoint: 1 if input numerictype is fixed point data type, 0 otherwise
        %
        function isFixPoint=isFixedPoint(nt)
            isSlopeBias =  (strcmpi(nt.DataTypeMode, 'Fixed-point: slope and bias scaling') == 1);
            isBinaryPoint =  (strcmpi(nt.DataTypeMode, 'Fixed-point: binary point scaling') == 1);
            isUnspecified =  (strcmpi(nt.DataTypeMode, 'Fixed-point: unspecified scaling') == 1);
            isFixPoint = isSlopeBias || isBinaryPoint || isUnspecified;
        end
        % getFractionLengthFromError
        % get fraction length from quantization error.
        %
        % Arguments: 
        %            value: input quantization error value
        % Returns:
        %               fl: fractionlength required to represent value
        %
        function fl = getFractionLengthFromError(value)
            nt = numerictype(0, 1, value,1);
            fl = nt.FractionLength;
        end
        % getParsedValues
        % Parse input values to handle row vectors, types and complex values
        %
        % Arguments: 
        %           value: input values from user
        % Returns:
        %           parsedValues: parsed values
        %
        function parsedValues = getParsedValues(values)
            parsedValues = double(values(:));
            if ~isreal(parsedValues)
                parsedValues = [real(parsedValues); imag(parsedValues)];
            end
        end
    end
end
