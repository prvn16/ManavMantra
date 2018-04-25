function s = getSpecifiedSign(this)
%getSpecifiedSign Get Sign property and error if unspecified.
%   getSpecifiedSign(T) gets the Sign property of embedded.numerictype object
%   T and error if the Sign property is unspecified.
%
%   Examples:
%     T1 = numerictype(true, 16, 15);
%     s1 = getSpecifiedSign(T1)
%     %  returns true.
%
%     T2 = numerictype([], 16, 15);
%     s2 = getSpecifiedSign(T2)
%     %  errors because Sign is unspecified.
%
%   See also NUMERICTYPE.

%   Copyright 2008-2012 The MathWorks, Inc.

s = this.Signed;
if isempty(s)
    DAStudio.error('fixed:numerictype:signShouldBeSpecified');
end
