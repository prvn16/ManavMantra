%% SlopeBiasScaling class
% Sub class inherits from +fixed/ScalingFactory class
% This class computes slope bias scaling specific wordlength, fraction length
% given input data and additional constraints
 
% Copyright 2013-2016 The MathWorks, Inc.
classdef SlopeBiasScaling < fixed.ScalingFactory
    methods(Static=true)
        %%  GetBestPrecisionScaling
        % calculates fixed point data type with slope and bias scaling
        %
        % Arguments:
        %                 values: desired set of double values
        %              inputType: input numeric type
        % Returns:
        %       proposedDataType: output numerictype of fixed point data type of slope bias scaling
        %
        function proposedDataType = getBestPrecisionScaling(values, inputType)
            proposedDataType = inputType;
            
            sbs = fixed.SlopeBiasScaling;
            wl = inputType.WordLength;
            isSigned = inputType.Signed;
            xValMax = sbs.getMaxXVal(isSigned, wl);
            [slope, bias] = sbs.calculateSlopeBias(values, 2^wl -1, xValMax);   % calculate slope bias from values, wl 
            if sbs.isValidNumeric(slope) && sbs.isValidNumeric(bias)                
                proposedDataType.Signed = isSigned;
                proposedDataType.WordLength = wl;
                if slope < 0
                    if bias == 0
                        proposedDataType.Slope = 1;
                        proposedDataType.Bias = slope;           % if negative slope value and bias = 0, set slope to 1 and negative bias
                    end
                else
                    proposedDataType.Slope = slope;
                    proposedDataType.Bias = bias;
                end
            else
                DAStudio.warning('fixed:datatypeselector:unableToConstructSBScaling');
            end
        end
        %% GetWordLength
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
             proposedDataType.WordLength = min(128, fixed.GetMinWordLength(values, proposedDataType.FractionLength, proposedDataType.Signed));
        end
        %% CalculateSlopeBias 
        % Calculates slope and bias of scaling given the range of input, difference between maximum and minimum quantized integers, maximum possible quantized integer
        %
        % Arguments:
        %     range: input range of values 
        %    xrange: range of represented integer values 
        %   xValMax: maximum integer value represented  using underlying wordlength
        % Returns:
        %     slope: slope required to represent range using xrange and xValMax
        %      bias: bias induced for representing range using xrange and xValMax
        %
        function [slope,bias] = calculateSlopeBias(range, xrange, xValMax) %#ok
            ymax = max(range(:));
            ymin = min(range(:));
            if ymax ~= ymin %not single value
                if (ymax  > 0 && ymin < 0 ) || ismember(0, range)          % 0 is in range 
                    % calculate slope for (ymin,0) using (xmin, 0)
                    slopeUsingYMax = (ymax - 0)/xValMax;
                    % calculate slope for (0, ymax) using (0. xmax)
                    slopeUsingYMin = (0 - ymin)/xValMax;
                    % check which slope is higher
                    if(slopeUsingYMin > slopeUsingYMax)
                        slope = slopeUsingYMin;
                        bias = ymin - (-1*xValMax * slope);
                    else
                        slope = slopeUsingYMax;
                        bias = ymax - (xValMax * slope);
                    end
                    % use that slope for calculating bias
                    
                else
                    slope = (ymax - ymin)/xValMax;
                    bias  = ymax - (xValMax * slope);
                end
                
                if slope == 0                                           
                    if bias ~=0
                        slope = bias;                                   % if 0 slope, non zero bias, set slope to bias, bias=0
                    else
                        slope = 1;                                      % if 0 slope, 0 bias, set slope to 2^0, bias=0
                    end
                    bias  = 0;
                end
            else 
                if ymax == 0                                            %  single value, value = 0 , set slope to 2^0, bias = 0
                    slope = 2^0;
                else
                    slope = ymax;                                       % single value, value is not zero, set slope to value, bias = 0
                end
                bias = 0;
            end
        end
        %% isValidNumeric
        % checks if input is valid numeric input for slope or bias
        %
        % Arguments:
        %       input: any value for slope / bias
        % Returns:
        %       success: 1 if input is finite real number, 0 otherwise
        function success= isValidNumeric(input)
            success = 0;
            if isnumeric(input) && isreal(input) && isfinite(input)         
                success =1;
            end
        end
        %% GetMaxXVal
        % Get maximum fixed point integer for the given wordlength and signedness 
        %
        % Arguments:
        %      isSigned: signedness of numerictype whose wordlength is provided
        %    wordlength: wordlength of the numerictype 
        % Returns:
        %       xValMax: maximum representable value using input wordlength and
        %       signedness
        %
        function xValMax = getMaxXVal(isSigned, wl)
            xValMax = (2^wl) -1;                           
            if isSigned
                xValMax = pow2(wl-1) -1;
            end
        end
    end
end
