function b = isSystemUnderConversionDefined(this)
% isSystemUnderConversionDefined Return true if a SUD has been set on the
% model

% Copyright 2015 The MathWorks, Inc.

b = ~isempty(this.GoalSpecifier.getSystemForConversion) && this.isSUDVerified;
