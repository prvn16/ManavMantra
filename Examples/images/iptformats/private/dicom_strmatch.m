function idx = dicom_strmatch(str, cellOfStrings)
%DICOM_STRMATCH   Find substrings at beginning of larger string.
%   IDX = DICOM_STRMATCH(STR, CELLOFSTRINGS) looks and acts like
%   STRMATCH but isn't STRMATCH.

% Copyright 2011 The MathWorks, Inc.

idx = find(strncmpi(str, cellOfStrings, numel(str)));
