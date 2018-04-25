function value = UNDEFINED_LENGTH
%UNDEFINED_LENGTH   Return the UINT32 value 0xFFFFFFFF.
%
%   VALUE = images.internal.dicom.UNDEFINED_LENGTH() returns the constant
%   value representing an undefined length.

%   Copyright 1993-2017 The MathWorks, Inc.

value = intmax('uint32');   % 0xFFFFFFFF == 4294967295
