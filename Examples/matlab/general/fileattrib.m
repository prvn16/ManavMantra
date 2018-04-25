%FILEATTRIB    Set or get attributes of file or folder.
%   [STATUS,MESSAGE,MESSAGEID] = FILEATTRIB(FILE,ATTRIBS,USERS,'s') sets the
%   attributes of FILE. Several attributes, delimited by spaces, may be 
%   specified at once. FILE may point to a file or folder and may contain 
%   an absolute pathname or a pathname relative to the current folder. 
%
%   [STATUS,VALUES] = FILEATTRIB(FILE) gets the status and the last 
%   successfully set attribute values for FILE. 
%
%   INPUT PARAMETERS:
%       FILE:      Character vector or string scalar, 
%                  defining the file or folder. UNC paths 
%                  are supported. The * wildcard, as a suffix to the last
%                  name or the extension to the last name in a path 
%                  description, is supported.
%       ATTRIBS:   Space-delimited character vector or string scalar, defining the attributes
%                  of the file or folder. Specifying invalid attributes for
%                  an operating system results in an error message.
%                  'a' : archive (Windows/DOS only).
%                  'h' : hidden file (Windows/DOS only).
%                  's' : system file (Windows/DOS only).
%                  'w' : write access.
%                  'x' : executable (UNIX only).
%                  Either '+' or '-' must be added in front of each file 
%                  attribute to set or clear it. 
%       USERS:     Space-delimited character vector or string scalar, 
%                  defining which users are affected by the attribute setting. (UNIX only)
%                  'a' : all users. 
%                  'g' : group of users.
%                  'o' : other users.
%                  'u' : current user.
%                  Default attribute is dependent upon the UNIX umask.
%       's':       A character, or a string containing one character, 
%                  modifying the behavior of FILEATTRIB. 
%                  Operate recursively on files and folders in the
%                  folder subtree. On Windows 2000 and later, this is 
%                  equivalent to ATTRIB switches /s /d.
%                  Default - 's' is absent or an empty text array.
%
%   RETURN PARAMETERS:
%       STATUS:    Logical scalar, defining the outcome of FILEATTRIB.
%                  1 : FILEATTRIB executed successfully.
%                  0 : an error occurred. 
%       MESSAGE:   Character vector, defining the error or warning message.
%                  empty character array : FILEATTRIB executed successfully.
%                  message : error or warning message, as applicable.
%       MESSAGEID: Character vector, defining the error or warning identifier.
%                  empty character array : FILEATTRIB executed successfully.
%                  message id: error or warning message identifier.
%                  (see ERROR, Mexception, WARNING, LASTWARN).
%       VALUES:    Structure array defining file attributes in terms of 
%                  these fields:
%
%            Name: character vector containing name of file or folder
%         archive: 0 or 1 or NaN 
%          system: 0 or 1 or NaN 
%          hidden: 0 or 1 or NaN 
%       directory: 0 or 1 or NaN 
%        UserRead: 0 or 1 or NaN 
%       UserWrite: 0 or 1 or NaN 
%     UserExecute: 0 or 1 or NaN 
%       GroupRead: 0 or 1 or NaN 
%      GroupWrite: 0 or 1 or NaN 
%    GroupExecute: 0 or 1 or NaN 
%       OtherRead: 0 or 1 or NaN 
%      OtherWrite: 0 or 1 or NaN 
%    OtherExecute: 0 or 1 or NaN 
%
%           Attribute field values are type logical. NaN indicates that an
%           attribute is not defined for a particular operating system.
%
%   EXAMPLES:
%
%   fileattrib mydir\*  recursively displays the attributes of 'mydir'
%   and its contents. 
%
%   fileattrib myfile -w -s  sets the 'read-only' attribute and revokes
%   the 'system file' attribute of 'myfile'. 
%
%   fileattrib 'mydir' -x  revokes the 'executable' attribute of 'mydir'.
%
%   fileattrib mydir '-w -h'  sets read-only and revokes hidden attributes
%   of 'mydir'. 
%
%   fileattrib mydir -w a s  revokes, for all users, the 'writable'
%   attribute from 'mydir' as well as its subfolder tree.
%
%   fileattrib mydir +w '' s  sets 'mydir', as well as its subfolder tree,
%   writable. 
%
%   fileattrib myfile '+w +x' 'o g'  sets the 'writable' and 'executable'
%   attributes of 'myfile' for other users as well as group.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = fileattrib('mydir\*'); if successful,
%   returns the success status 1 in SUCCESS, the attributes of 'mydir' and its
%   subfolder tree in the structure array MESSAGE. If a warning was issued,
%   MESSAGE contains the warning, while MESSAGEID contains the warning message
%   identifier. In case of failure, SUCCESS contains success status 0, MESSAGE
%   contains the error message, and MESSAGEID contains the error message
%   identifier. 
%
%   [SUCCESS,MESSAGE,MESSAGEID] = fileattrib('myfile','+w +x','o g') sets the
%   'writable' and 'executable' attributes of 'myfile' for other users as well
%   as group. 
%
%
%   NOTE: When FILEATTRIB is called without return arguments and an error
%           has occurred while executing FILEATTRIB, the error message is
%           displayed.
%
%   See also CD, COPYFILE, DELETE, DIR, MKDIR, MOVEFILE, RMDIR.

%   Copyright 1984-2017 The MathWorks, Inc.

%   Package: libmwbuiltins
%   Built-in function.
