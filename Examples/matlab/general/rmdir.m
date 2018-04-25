%RMDIR Remove directory.
%   RMDIR(DIRECTORY) removes DIRECTORY from the parent directory, subject
%   to access rights. DIRECTORY must be empty.
%
%   RMDIR(DIRECTORY, 's') removes DIRECTORY, including the subdirectory 
%   tree and all files, from the parent directory. See NOTE 1.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = RMDIR(DIRECTORY) removes DIRECTORY from 
%   parent directory, returning status and error information as described
%   below under Return Parameters.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = RMDIR(DIRECTORY,MODE) removes DIRECTORY from
%   the parent directory, subject to access rights. RMDIR can remove
%   subdirectories recursively.
%
%   INPUT PARAMETERS:
%       DIRECTORY: Character vector or string scalar specifying a directory, 
%                  relative or absolute. See NOTE 2.
%       MODE:      Character or string scalar indicating the mode of operation.
%                  's': indicates that the subdirectory tree, implied by DIRECTORY,
%                  will be removed recursively.
%
%   RETURN PARAMETERS:
%       SUCCESS:   Logical scalar, defining the outcome of RMDIR.
%                  1 : RMDIR executed successfully.
%                  0 : an error occurred.
%       MESSAGE:   Character vector, defining the error or warning message.
%                  empty character array : RMDIR executed successfully.
%                  message : an error or warning message, as applicable.
%       MESSAGEID: Character vector, defining the error or warning identifier.
%                  empty character array : RMDIR executed successfully.
%                  message id: the MATLAB error or warning message identifier
%                  (see ERROR, MException, WARNING, LASTWARN).
%
%   NOTE 1: MATLAB removes the subdirectory tree regardless of the write
%           attribute of any contained file or subdirectory.
%   NOTE 2: UNC paths are supported.
%
%   See also CD, COPYFILE, DELETE, DIR, FILEATTRIB, MKDIR, MOVEFILE.

%   Copyright 1984-2017 The MathWorks, Inc.

%   Package: libmwbuiltins
%   Built-in function.
