%LOAD Load data from MAT-file into workspace.
%   S = LOAD(FILENAME) loads the variables from a MAT-file into a structure
%   array, or data from an ASCII file into a double-precision array. 
%   Specify FILENAME as a character vector or a string scalar. For example,
%   specify FILENAME as 'myFile.mat' or "myFile.mat". 
%
%   S = LOAD(FILENAME, VARIABLES) loads only the specified variables from a
%   MAT-file. Specify FILENAME and VARIABLES as character vectors or string
%   scalars. When specifying VARIABLES, use one of the following forms:
%
%       VAR1, VAR2, ...          Load the listed variables.  Use the '*'
%                                wildcard to match patterns.  For
%                                example, load('A*') loads all variables
%                                that start with A.
%       '-regexp', EXPRESSIONS   Load only the variables that match the
%                                specified regular expressions.  For more
%                                information on regular expressions, type
%                                "doc regexp" at the command prompt.
%
%   S = LOAD(FILENAME, '-mat', VARIABLES) forces LOAD to treat the file as
%   a MAT-file, regardless of the extension.  Specifying VARIABLES is
%   optional.
%
%   S = LOAD(FILENAME, '-ascii') forces LOAD to treat the file as an ASCII
%   file, regardless of the extension.
%
%   LOAD(...) loads without combining MAT-file variables into a structure
%   array.
%
%   LOAD ... is the command form of the syntax, for convenient loading from
%   the command line. With command syntax, you do not need to enclose 
%   inputs in single or double quotation marks. Separate inputs with spaces
%   instead of commas. Do not use command syntax if FILENAME is a variable.
%   
%   Notes:
%
%   If you do not specify FILENAME, the LOAD function searches for a file
%   named matlab.mat.
%
%   ASCII files must contain a rectangular table of numbers, with an equal
%   number of elements in each row.  The file delimiter (character between
%   each element in a row) can be a blank, comma, semicolon, or tab.  The
%   file can contain MATLAB comments.
%
%   Examples:
%
%       gongStruct = load('gong.mat')      % All variables
%       load('handel.mat', 'y')            % Only variable y
%       load('accidents.mat', 'hwy*')      % Variables starting with "hwy"
%       load('topo.mat', '-regexp', '\d')  % Variables containing digits
%
%       % Using command form
%       load gong.mat
%       load topo.mat -regexp \d
%       load 'hypothetical file.mat'       % Filename with spaces
%
%   See also SAVE, MATFILE, WHOS, CLEAR, REGEXP, IMPORTDATA, UIIMPORT.

% Copyright 1984-2016 The MathWorks, Inc.
% Built-in function. 

