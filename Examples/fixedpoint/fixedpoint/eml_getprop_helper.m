function [propVal,errmsg] = eml_getprop_helper(a,propName)
% Helper function that returns the property value (best guess)
% for its property PROPNAME 
% Note: This function should ONLY be called to assist Simulink
% size propagation where input type is unknown


% Copyright 2012 The MathWorks, Inc.

narginchk(2,2);
errmsg = ''; propVal = [];
if ~isa(a, 'double')
    error(message('fixed:fi:inputMustBeDouble'));
end



%All properties of data and numerictype and fimath are also properties of fi.
%See <http://www.mathworks.com/help/fixedpoint/ug/fi-object-properties.html>.
knownFiNames = {
    'bin', 'data', 'dec', 'double', 'hex', 'int', 'oct', ...
    'DataType', 'Scaling', 'Signed', 'Signedness', 'WordLength', ...
    'FractionLength', 'FixedExponent', 'Slope', ...
    'SlopeAdjustmentFactor', 'Bias', 'fimath', 'RoundMode', ...
    'RoundingMethod', 'OverflowMode', 'OverflowAction', 'ProductMode', ...
    'SumMode', 'ProductWordLength', 'SumWordLength', ...
    'MaxProductWordLength', 'MaxSumWordLength', ...
    'ProductFractionLength', 'ProductFixedExponent', 'ProductSlope', ...
    'ProductSlopeAdjustmentFactor', 'ProductBias', ...
    'SumFractionLength', 'SumFixedExponent', 'SumSlope', ...
    'SumSlopeAdjustmentFactor', 'SumBias', 'CastBeforeSum', ...
    'numerictype', 'fimath'};
if strmatch(propName, knownFiNames)
    try
        tmpfi = fi(a);
        propVal = get(tmpfi,propName);
    catch ME
        errmsg = ME.message;
    end
else
    error(message('fixed:fi:unrecognizedProperty', propName));
end

%------------------------------------------------------------------