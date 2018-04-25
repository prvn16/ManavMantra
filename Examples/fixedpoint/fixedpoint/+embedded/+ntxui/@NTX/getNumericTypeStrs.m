function s = getNumericTypeStrs(ntx)
% Returns structure with strings describing numeric type

%   Copyright 2010-2014 The MathWorks, Inc.

% Include guard- and precision-bits
[~,fracBits,wordBits,isSigned] = getWordSize(ntx,1);

% Setup common strings
if isSigned
    s.signedStr = 'Signed';
else
    s.signedStr = 'Unsigned';
end
if isempty(wordBits)
    wordBits = 2;
end
if isempty(fracBits)
    fracBits = 3;
end
dt = numerictype(isSigned, wordBits, fracBits);
s.typeStr = dt.tostring;

s.typeTip = sprintf([ ...
    'Signedness: %s\n' ...
    'WordLength: %d\n', ...
    'FractionLength: %d'], ...
    s.signedStr,wordBits,fracBits);

s.warnTip = ...
    getString(message('fixed:NumericTypeScope:WarnTipUnsignedAndNegVals'));

s.isWarn = ~ntx.IsSigned && (ntx.DataNegCnt > 0);
