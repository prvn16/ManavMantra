%% NumericTypeSelector    
% Sub class inheriting +fixed/DataTypeSelector class.
% This class is used to create DataTypes to suit the following
% DataTypeSelector constraints
% AbsTol, RelTol, WordLength = 'Auto' and Scaling = 'Auto'
% % BestPrecision scaling is chosen as a starting point. Depending on the
% error tolerance constraints, wordlength or fraction length is optimized.

% Copyright 2013-2016 The MathWorks, Inc.
classdef NumericTypeSelector < fixed.DataTypeSelector
    properties
        Parent; % to store parent object as member. 
    end
    methods
        %% NumericTypeSelector constructor
        function nts = NumericTypeSelector()
        end
        %% Set Parent
        function set.Parent(nts,value)
            nts.Parent = value; % store the parent object as member.
        end
        %% Propose 
        % Propose output numerictype based on input values and input type.
        %
        % Arguments:
        %            values: input data values
        %         inputType: input numeric type
        %    scalingFactory: scaling factory based on inputType scaling
        % Returns:
        %  proposedDataType: output numeric type of inputType scaling
        function proposedDataType = propose(nts, values, inputType, scalingFactory)
            proposedDataType = inputType;
            % Use scalingFactory information to calculate the best
            % precision scaling for given wordlength
            proposedDataType = scalingFactory.getBestPrecisionScaling(values, proposedDataType); 
            
            % check if error tolerances are met
            isErrorToleranceMet = nts.Parent.checkErrorTolerance(values, proposedDataType);
            if ~isErrorToleranceMet
                % if error tolerances are not met, choose the right
                % fraction bits
                proposedDataType = nts.chooseBestFractionBits(values, proposedDataType);
            else
                % if error tolerances are met, choose the minimal word
                % length required 
                proposedDataType = nts.chooseMinWordSize(values, proposedDataType, scalingFactory);
            end
            % once optimized wordlength by choosing fraction bits or
            % integer bits, check if best optimal solution is obtained,
            proposedDataType = nts.chooseMinWordSize(values, proposedDataType, scalingFactory);
        end
    end
    methods(Access = private)
        %% ChooseMinWordSize
        % Choose the min word size given input values and best precision
        % fraction length
        %  
        % Arguments:
        %            values: input array of double finite values
        %  proposedDataType: input data type of given best precision scaling used for best
        %  precision fraction length
        %    scalingFactory: scaling factory  which computes best precision
        %    / min word size for the input scaling, signedness and word lengths
        % 
        % Returns:
        %   proposedDataType: proposed data type which uses best fraction
        %   bits to represent input values given constraints
        %
        function proposedDataType = chooseMinWordSize(nts, values, proposedDataType, scalingFactory)
            prevDataType = proposedDataType;
            while(prevDataType.WordLength >= 2+prevDataType.Signed)
                tempType = prevDataType;
                % reduce wordlength by 1 bit
                tempType.WordLength = prevDataType.WordLength - 1;
                outNt = tempType;
                % calculate best precision scaling for input wordlength
                outNt = scalingFactory.getBestPrecisionScaling(values, outNt);
                % check if tolerances are met
                isErrorToleranceMet = nts.Parent.checkErrorTolerance(values, outNt); 
                if ~isErrorToleranceMet
                    % while error tolerance is not met and error tolerance
                    % is met for prev word length, quit.
                    break;
                end
                % else assign it as prev datatype
                prevDataType = outNt;
            end
            proposedDataType = prevDataType;
        end
        %% ChooseBestFractionBits
        % Choose the best fraction bits given input values and desired
        % integer bits
        % 
        % Arguments:
        %      values: input array of double finite values
        %   inputType: input numeric type used for input integer bits
        % 
        % Returns:
        %   proposedDataType: proposed data type which uses best fraction
        %   bits to represent input values given constraints
        
        function proposedDataType = chooseBestFractionBits(nts, values, inputType)
            proposedDataType = inputType;
            fbits = inputType.FractionLength + 1;
            minWordLength = fixed.GetMinWordLength(values, inputType.FractionLength, inputType.Signed);
            ibits = minWordLength - fbits - inputType.Signed;
            
            isErrorToleranceMet = 0;
            % if error tolerance is not met and fbits is within 128 bits of
            % wordlength
            while  ~isErrorToleranceMet && fbits <= 128 - ibits - inputType.Signed
               proposedDataType.FractionLength = fbits;
               if inputType.Signed + ibits + fbits > 0
                    proposedDataType.WordLength = inputType.Signed + ibits + fbits;
               end
               
               % check if error tolerance is met for given fraction bits
               [isErrorToleranceMet, qErr] = nts.Parent.checkErrorTolerance(values, proposedDataType);
               maxErrorValue = max(abs(qErr));
               nextIterBits = 0; %#ok
               
               % if error tolerance is not met, find the fractionlength
               % required to represent error.
               if ~isErrorToleranceMet && maxErrorValue > 0
                   flFromError = nts.Parent.getFractionLengthFromError(maxErrorValue);
                   nextIterBits = max(abs(flFromError), 1); % num of bits required to represent the precision error
                   %if fbits < 0
                       %nextIterBits = -1*nextIterBits;
                   %end
               else
                   break;
               end
               
               % assign new fraction bits
               if abs(fbits) >= abs(nextIterBits)
                   fbits = fbits + nextIterBits; % if seen fbits > no. of bits required to represent error, increment fbits
               else
                   fbits = nextIterBits; % assign fbits as the new no. of deduced bits
               end
            end
            proposedDataType.FractionLength = fbits;
        end
    end
end