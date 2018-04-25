function B = intlut(varargin)
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

%   Copyright 2013 The MathWorks, Inc.

narginchk(2,2);
[A, classA, LUT, ~] = parseInputs(varargin{:});

%% B = LUT(A)
if strcmp(classA,'int16')
    B = arrayfun(@lookupInt16,A);
else
    B = arrayfun(@lookup,A);
end
    %----------------------------------------------------------------------
    function out = lookup(img)
        % 1-based indexing
        out = LUT(int32(img)+int32(1));
        
    end
    %----------------------------------------------------------------------
    function out = lookupInt16(img)
        % 1-based indexing
        % int16 special case for negative index value lookup
        out = LUT(int32(img)+int32(1)+int32(32768));
        
    end
end

function [A, classA, LUT, classLUT] = parseInputs(varargin)

A   = gpuArray(varargin{1});
LUT = gpuArray(varargin{2});

hValidateAttributes(A,...
    {'uint8','uint16','int16'},...
    {'real'},mfilename, 'A', 1);
hValidateAttributes(LUT,...
    {'uint8','uint16','int16'},...
    {'vector','real'},mfilename, 'LUT', 2);


classA   = classUnderlying(A);
classLUT = classUnderlying(LUT);

if ~isequal(classA,classLUT)
    error(message('images:intlut:inputsHaveDifferentClasses'))
end

if strcmp(classLUT,'uint8') && length(LUT) ~= 256
    error(message('images:intlut:wrongNumberOfElementsInLUT8Bit'))
end

if (strcmp(classLUT,'uint16') || strcmp(classLUT,'int16'))  && ...
        length(LUT) ~= 65536
    error(message('images:intlut:wrongNumberOfElementsInLUT16Bit'))
end
end
