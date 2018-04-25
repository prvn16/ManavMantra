%COPYFILE   Copy file or directory.
%   [SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE,DESTINATION,MODE) copies
%   the file or directory SOURCE to the new file or directory DESTINATION.
%   Both SOURCE and DESTINATION may be either an absolute pathname or a
%   pathname relative to the current directory. When the MODE is set to
%   'f', COPYFILE copies SOURCE to DESTINATION, even when DESTINATION is
%   read-only. The DESTINATION's writable attribute state is preserved. 
%
%   [SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE) attempts to copy SOURCE
%   to the current directory.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE, DESTINATION) attempts to
%   copy SOURCE to DESTINATION. If SOURCE constitutes a directory or
%   multiple files and DESTINATION does not exist, COPYFILE attempts to
%   create DESTINATION as a directory and copy SOURCE to DESTINATION. If
%   SOURCE constitutes a directory or multiple files and DESTINATION exists
%   as a directory, COPYFILE attempts to copy SOURCE to DESTINATION. If
%   SOURCE constitutes a directory or multiple files and none of the above
%   cases on DESTINATION applies, COPYFILE fails.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE,DESTINATION,'f') attempts
%   to copy SOURCE to DESTINATION, as above, even if DESTINATION is
%   read-only. The status of the writable attribute of DESTINATION will be
%   preserved.
%
%   INPUT PARAMETERS:
%       SOURCE:      Character vector or string scalar defining the source 
%                    file or directory.
%       DESTINATION: Character vector or string scalar defining destination 
%                    file or directory. The default is the current directory. 
%       MODE:        A character, or a string containing one character,
%                    defining the copy mode.
%                    'f' : force SOURCE to be written to DESTINATION. If
%                    omitted, COPYFILE respects the current writable status
%                    of DESTINATION. 
%
%   RETURN PARAMETERS:
%       SUCCESS:     Logical scalar, defining the outcome of COPYFILE.
%                    1 : COPYFILE executed successfully. 0 : an error
%                    occurred.
%       MESSAGE:     Character vector defining the error or warning message.
%                    empty character array : COPYFILE executed successfully. message
%                    : an error or warning message, as applicable.
%       MESSAGEID:   Character vector defining the error or warning identifier.
%                    empty character array : COPYFILE executed successfully. message
%                    id: the MATLAB error or warning message identifier
%                    (see ERROR, MException, WARNING, LASTWARN).
%
%   NOTE 1: Except where otherwise stated, the rules of
%           the underlying system on the preservation of attributes are
%           followed when copying files and directories.
%   NOTE 2: The * wildcard is supported in the filename or extension.
%
%   See also CD, DELETE, DIR, FILEATTRIB, MKDIR, MOVEFILE, RMDIR.

%   Copyright 1984-2017 The MathWorks, Inc.

%   Package: libmwbuiltins
%   Built-in function.
