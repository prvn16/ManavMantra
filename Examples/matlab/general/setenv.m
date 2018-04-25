%SETENV Set environment variable.
%  SETENV(NAME, VALUE) sets the value of an environment variable 
%  belonging to the underlying operating system. Inputs NAME and
%  VALUE are both character vecotrs. If NAME already exists as an 
%  environment variable, then SETENV replaces its current value with
%  the character vector given in VALUE. If NAME does not exist, SETENV 
%  creates a new environment variable called NAME and assigns VALUE to it.
%
%  SETENV(NAME) is equivalent to SETENV(NAME, '') and assigns a 
%  null value to the variable NAME. Under the Windows operating 
%  system, this is equivalent to undefining the variable.  On most
%  UNIX-like platforms, it is possible to have an environment 
%  variable defined as empty.
%  
%  The maximum number of characters in NAME is 2^15 - 2 (or 32766).
%  If NAME contains the character '=', SETENV throws an error. 
%  The behavior of environment variables with '=' in the name is 
%  not well-defined.
%
%  On all platforms, SETENV passes the NAME and VALUE character vectors 
%  to the operating system unchanged. Special characters such as ';', '/', 
%  ':', '$', '%', etc. are left unexpanded and intact in the variable 
%  value.
%  
%  Values assigned to variables using SETENV are picked up by any
%  process that is spawned using the MATLAB SYSTEM, UNIX, DOS or '!' 
%  functions. You can retrieve any value set with SETENV by using
%  GETENV(NAME).
%
%  Examples :
%    % Set a new value for the environment variable TEMP:
%    setenv('TEMP', 'C:\TEMP');
%    getenv('TEMP')
%
%    % Append the Perl\bin directory to your system PATH variable:
%    setenv('PATH', [getenv('PATH') ';D:\Perl\bin']);
%
%  See also : getenv, system, unix, dos, !

%   Copyright 2005-2015 The MathWorks, Inc.
%   Built-in function.


