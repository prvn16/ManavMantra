%FGETS Read line from file, keeping the newline character.
%   TLINE = FGETS(FID) returns the next line of a file associated with file
%   identifier FID as a MATLAB character vector. The line terminator is included. Use
%   FGETL to get the next line WITHOUT the line terminator. If just an end-of-file is
%   encountered then -1 is returned.
%
%   If an error occurs while reading from the file, FGETS returns an empty character
%   vector. Use FERROR to determine the nature of the error.
%
%   TLINE = FGETS(FID, NCHAR) returns at most NCHAR characters of the next line. No
%   additional characters are read after the line terminator(s) or an end-of-file.
%
%   MATLAB reads characters using the encoding scheme associated with the file. See
%   FOPEN for more information.
%
%   FGETS is intended for use with files that contain newline characters. Given a
%   file with no newline characters, FGETS may take a long time to execute.
%
%   See also FGETL, FOPEN, FERROR.

%   [TLINE, LTOUT] = FGETS(...) also returns the line terminator(s), if any, in
%   LTOUT.

%   Copyright 1984-2016 The MathWorks, Inc. Built-in function.

