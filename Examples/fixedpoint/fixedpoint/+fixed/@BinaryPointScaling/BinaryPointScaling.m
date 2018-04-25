%% BinaryPointScaling 
% Binary Point Scaling Class
% Sub class inherits from +fixed/ScalingFactory class
% This class computes binary point scaling specific wordlength, fraction length
% given input data and additional constraints

% Copyright 2013-2016 The MathWorks, Inc.

classdef BinaryPointScaling < fixed.ScalingFactory
    
    methods(Static=true)
        %% GetBestPrecisionFractionLength
        % Calculate fraction length given values, inputNumericType
        %
        % Arguments:
        %             values: array of finite double values 
        %   inputNumericType: input numerictype 
        % Returns:
        %                 fl: returns the best precision fractionlength required to represent values using the wordlength
        %          
        function proposedDataType = getBestPrecisionScaling(values, inputType)
            isSigned = inputType.Signed;
            wordLength = inputType.WordLength;
            
            proposedDataType = inputType;
            proposedDataType.DataTypeMode = 'Fixed-point: binary point scaling';
            proposedDataType.FractionLength =  fixed.GetBestPrecision(values, wordLength, isSigned);
        end
        %% GetMinWordLength
        % Calculate word length given values, inputNumericType
        %
        % Arguments:
        %             values: array of finite double values 
        %   inputNumericType: input numerictype 
        % Returns:
        %                 wl: returns the minimum wordlength required to represent values using the fraction length
        % 
        function proposedDataType = getWordLength(values, inputType)
            proposedDataType = inputType;
            proposedDataType.WordLength = fixed.GetMinWordLength(values, inputType.FractionLength, inputType.Signed);
            % removing this temporarily for autoscaler support.
            %proposedDataType.WordLength = min(128, proposedDataType.WordLength );
        end
      
    end
end