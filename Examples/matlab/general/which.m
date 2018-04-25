%WHICH  Locate functions and files.
%   WHICH ITEM displays the full path for ITEM. ITEM can include a partial
%   path, complete path, relative path, or no path. If ITEM includes a
%   partial path or no path, it must be on the search path or in the
%   current folder.
% 
%   If ITEM is a Simulink model, a MATLAB app file, or a MATLAB function or 
%   script in a MATLAB code file, then WHICH displays the full path for the 
%   corresponding file.
% 
%   If ITEM is a method in a loaded Java class, then WHICH displays the
%   package, class, and method name for that method.
% 
%   If ITEM is a workspace variable, then WHICH displays a message
%   identifying ITEM as a variable.
%   
%   If ITEM is a file name with a specified extension, then WHICH displays 
%   the full path of ITEM.
%
%   If ITEM is an overloaded function or method, then WHICH ITEM returns
%   only the path of the first function or method found.
% 
%   WHICH FUN1 in FUN2 displays the path to function FUN1 that is called by
%   file FUN2. Use this syntax to determine whether a local function is
%   being called instead of a function on the path. This syntax does not
%   locate nested functions.
% 
%   WHICH ___ -ALL displays the paths to all items on the MATLAB path with
%   the requested name. Such items include methods of instantiated classes.
%   You can use -ALL with the input arguments of any of the previous
%   syntaxes.
% 
%   S = WHICH(ITEM) returns the full path for ITEM in the character vector, S.
% 
%   S = WHICH(FUN1,'IN',FUN2) returns the path to function FUN1 that is
%   called by file FUN2. Use this syntax to determine whether a local
%   function is being called instead of a function on the path. This syntax
%   does not locate nested functions.
% 
%   S = WHICH(___,'-ALL') returns the results of WHICH in the character vector or
%   cell array of character vectors, S. You can use this syntax with any of the input
%   arguments in the previous syntax group. Each row of cell array S
%   identifies a function. The functions are in order of precedence, unless
%   they are shadowed. Among shadowed functions, you should not rely on the
%   order of the functions in S.
%  
%   For more information about function precedence order, see the MATLAB
%   documentation.
% 
%   See also DIR, HELP, WHO, WHAT, EXIST, LOOKFOR, FILEPARTS, MFILENAME,
%   PATH, TYPE
%
%   Copyright 1984-2015 The MathWorks, Inc. Built-in function.
