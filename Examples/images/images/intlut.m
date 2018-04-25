function B = intlut(A, lut) %#codegen
%INTLUT Convert integer values using lookup table.
%   B = INTLUT(A,LUT) converts values in array A based on lookup table
%   LUT and returns these new values in array B. 
%   
%   For example, if A is a uint8 vector whose kth element is equal
%   to alpha, then B(k) is equal to the LUT value corresponding
%   to alpha, i.e., LUT(alpha+1).
%
%   Class Support
%   -------------
%   A can be uint8, uint16, or int16. If A is uint8, LUT must be
%   a uint8 vector with 256 elements. If A is uint16 or int16, 
%   LUT must be a vector with 65536 elements that has the same class 
%   as A. B has the same size and class as A.
%
%   Example
%   -------
%        A = uint8([1 2 3 4; 5 6 7 8;9 10 11 12])
%        LUT = repmat(uint8([0 150 200 255]),1,64);
%        B = intlut(A,LUT)

%   Copyright 1993-2017 The MathWorks, Inc.

%#ok<*EMCA>

validateattributes(A, {'uint8','uint16','int16'}, ...
    {'real'}, mfilename, 'A', 1);
validateattributes(lut, {'uint8', 'uint16','int16'}, ...
    {'vector','real'}, mfilename, 'LUT', 2);

% Ensure A and LUT are of the same class
coder.internal.errorIf((~isequal(class(A), class(lut))), ...
    'images:intlut:inputsHaveDifferentClasses');

% Max number of elements LUT contains appropriate number of elements
coder.internal.errorIf((isa(lut,'uint8') && numel(lut)~=256), ...
    'images:intlut:wrongNumberOfElementsInLUT8Bit');

coder.internal.errorIf(((isa(lut,'uint16')||isa(lut,'int16')) && ...
    numel(lut)~=65536), 'images:intlut:wrongNumberOfElementsInLUT16Bit');

coder.extrinsic('images.internal.coder.useSharedLibrary');
useSharedLibrary = coder.const(images.internal.coder.useSharedLibrary()) ...
    && coder.internal.isTargetMATLABHost() ...
    && ~(coder.isRowMajor && numel(size(A))>2);

% Choose to execute in MATLAB or code-generation target
if coder.target('MATLAB')
    B = intlutmex(A, lut);
elseif useSharedLibrary
    images.internal.coder.checkSupportedCodegenTarget(mfilename);
    B = images.internal.coder.intlutmex(A, lut);
else
    if isa(A,'int16')
        offset = coder.const(coder.internal.indexInt(32769));
    else
        offset = coder.const(coder.internal.indexInt(1));
    end
    B = intlutPortableCode(A,lut,offset);
end

function B = intlutPortableCode(A,lut,offset)

coder.inline('always');
coder.internal.prefer_const(A,lut,offset);

numElems = numel(A);
B = coder.nullcopy(zeros(size(A),'like',A));

for k = 1:numElems
    idx = coder.internal.indexPlus(A(k), offset);
    B(k) = lut(idx);
end
