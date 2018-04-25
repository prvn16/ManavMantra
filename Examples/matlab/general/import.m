%   IMPORT Adds to the current packages and classes import list.
%   IMPORT PACKAGE_NAME.CLASS_NAME adds the fully qualified class name to 
%   the import list.
%
%   IMPORT PACKAGE_NAME.FUNCTION adds the specified package-based function
%   to the current import list.
%
%   IMPORT PACKAGE_NAME.* adds the specified package name to the current
%   import list.
%
%   IMPORT PACKAGE1.CLASS_NAME1 PACKAGE2.CLASS_NAME2 ... adds multiple 
%   fully qualified class names.
%
%   IMPORT PACKAGE1.* PACKAGE2.* ... adds multiple package names.
%
%   Use the functional form of IMPORT, such as IMPORT(S), when the package
%   or class name is stored in a string.
%
%   L = IMPORT(...) returns as a cell array of char vectors the contents
%   of the current import list as it exists when IMPORT completes.
%   L = IMPORT, with no inputs, returns the current import list without
%   adding to it.
%
%   IMPORT allows your code to refer to an imported class or function using
%   fewer or no package prefixes.
%
%   IMPORT affects only the import list of the function or script within 
%   which it is used.  There is also a base import list that is used at the 
%   command prompt. When an IMPORT is used at the command prompt it affects  
%   the base import list.
%
%
%   CLEAR IMPORT clears the base import list.  The import lists of
%   functions may not be cleared.
%
%   Examples:
%   %Example 1: add the containers.Map class to the current import list
%       import containers.Map
%       myMap = Map('KeyType', 'char', 'ValueType', 'double');
%
%   %Example 2: import two Java packages 
%       import java.util.Enumeration java.lang.String
%       s = String('hello');     % Create a java.lang.String object
%       methods Enumeration      % List the java.util.Enumeration methods
%
%   %Example 3: add the java.awt.* package to the current import list
%       import java.awt.*
%       f = Frame;               % Create a java.awt.Frame object
%
%IMPORTING DATA
%   You can also import various types of data into MATLAB.  This includes
%   importing from MAT-files, text files, binary files, and HDF files.  To 
%   import data from MAT-files, use the LOAD function.  To use the
%   graphical user interface to MATLAB's import functions, type UIIMPORT.
%
%   For further information on importing data, see Import and Export Data
%   in the MATLAB Help Browser under the following headings:
%
%       MATLAB -> Programming Fundamentals
%       MATLAB -> External Interfaces -> Programming Interfaces
%
%   See also CLEAR, LOAD.

%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.
