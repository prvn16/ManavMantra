function [eigVal1, eigVal2] = find2DEigenValues(Gxx, Gyy, Gxy)
% FIND2DEIGENVALUES finds the eigen values of a 2x2 real symmetric matrix 
%   [EIGVAL1, EIGVAL2] = FIND2DEIGENVALUES(GXX, GYY, GXY) computes the two
%   eigenvalues EIGVAL1, and EIGVAL2 for a real symmetric matrix whose
%   components are categorized by GXX, GYY, GXY. The eigen values are
%   sorted according to their absolute values (|EIGVAL1| <= |EIGVAL2|).
%   EIGVAL1 and EIGVAL2 have the same size as the inputs.
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within other toolbox classes and
%   functions. Its behavior may change, or the feature itself may be
%   removed in a future release.

%   Copyright 2016 The MathWorks, Inc.

supportedClasses = {'single','double'};
supportedAttributes = {'real','nonempty','nonsparse'};

validateattributes(Gxx,supportedClasses,supportedAttributes,mfilename,'Gxx');
validateattributes(Gyy,supportedClasses,supportedAttributes,mfilename,'Gyy');
validateattributes(Gxy,supportedClasses,supportedAttributes,mfilename,'Gxy');

if ~isequal(size(Gxx),size(Gyy))
    error(message('images:validate:unequalSizeMatrices','Gxx','Gyy'));
end

if ~isequal(size(Gxx),size(Gxy))
    error(message('images:validate:unequalSizeMatrices','Gxx','Gxy'));
end


eigVal1 = (Gxx + Gyy + sqrt((Gxx - Gyy).^2 + 4*Gxy.^2))/2;
eigVal2 = (Gxx + Gyy - sqrt((Gxx - Gyy).^2 + 4*Gxy.^2))/2;

% sort the values according to the absolute eigenvalues (ascending)
sortedIndex = abs(eigVal1) > abs(eigVal2);
temp = eigVal1;
eigVal1(sortedIndex) = eigVal2(sortedIndex);
eigVal2(sortedIndex) = temp(sortedIndex);