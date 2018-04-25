%matlab.io.saveVariablesToScript Save workspace variables to MATLAB script.
%
% Syntax:
%-----------------------------
% matlab.io.saveVariablesToScript('filename')    
% matlab.io.saveVariablesToScript('filename', {'varnames'})
% matlab.io.saveVariablesToScript('filename', 'Name', 'Value')
% [r1, r2] = matlab.io.saveVariablesToScript('filename')
%
% Description:
%-----------------------------
% matlab.io.saveVariablesToScript('filename') saves variables in the current
% workspace to a MATLAB script named filename.m.
%
% Variables for which MATLAB code cannot be generated are saved to a companion
% MAT-file named filename.mat.
%
% If either file already exists, it is overwritten. The filename cannot match
% the name of any variable in the current workspace and can optionally include
% the suffix .m.
%
% matlab.io.saveVariablesToScript('filenames', {'varnames'}) saves only
% workspace variables specified by varnames to a MATLAB script named
% filename.m.
%
% matlab.io.saveVariablesToScript('filename', 'Name', 'Value') uses
% additional options specified by one or more Name, Value pair arguments.
%
% [r1, r2] = matlab.io.saveVariablesToScript('filename') returns two
% cell arrays: r1, containing variables that were saved to a MATLAB script,
% and r2, containing variables that could not be saved to a script, but were
% saved to a MAT-file instead.
%
% Input Arguments:
%----------------------------
% filename - Name of MATLAB script for saving variables
% string
% Name of MATLAB script for saving variables, specified as a string.
% Example: matlab.io.saveVariablesToScript('myVariables.m')
% Data Types: char
% 
% varnames - Name of variables to save
% string | cell array
% Name of variables to save, specified in one of the following ways:
% - The name of a variable ('X')
% - A cell array of variable names ({'X', 'Y', 'Z'})
% Example: matlab.io.saveVariablesToScript('myVariables.m', 'X')
% Data Types: char | cell
%
% Name-Value Pair Arguments
% Specify optional comma-separated pairs of Name, Value arguments.
% Name is the argument name and Value is the corresponding value.
% Name must appear inside single quotes (' '). You can specify
% several name and value pair arguments in any order as
% 'Name1', 'Value1',..., 'NameN', 'ValueN'
%
% 'MATFileVersion' - MATLAB version whose syntax is used to save to MAT-files
% 'v7.3' (default) | string
% MATLAB version whose syntax is used to save to MAT-files, specified as
% the comma-separated pair consisting of 'MATFileVersion' and one of the 
% version numbers: 'v4', 'v6', 'v7', 'v7.3'
% Example: matlab.io.saveVariablesToScript('myVariables.m', 'MATFileVersion', 'v6')
%
% 'MaximumArraySize' - Maximum array elements to save in MATLAB script.
% If the array size exceeds this limit, it will be written in companion MAT file.
% 1000 (default) | integer
% Maximum array elements to save, specified as the comma-separated pair
% consisting of 'MaximumArraySize' and an integer in the range of 1 to 10000.
% Example: matlab.io.saveVariablesToScript('myVariables.m', 'MaximumArraySize', 1050)
%
% 'MaximumNestingLevel' - Maximum number of object levels or array hierarchy to save
% If the object levels exceed this limit, it will be written in companion MAT file.
% 20 (default) | integer
% Maximum number of object levels or array hierarchy to save, specified as the 
% comma-separated pair consisting of 'MaximumNestingLevel' and an integer in
% the range of 1 of 200.
% Example: matlab.io.saveVariablesToScript('myVariables.m', 'MaximumNestingLevel', 67)
% 
% 'MaximumTextWidth' - Text wrap width during save
% If a string exceed this limit, it will wrapped around and will be written in 
% multi-line in MATLAB script.
% 76 (default) | integer
% Text wrap width during save, specified as the comma-separated pair consisting
% of 'MaximumTextWidth' and an integer in the range of 32 to 256.
% Example: matlab.io.saveVariablesToScript('myVariables.m', 'MaximumTextWidth', 82)
%
% 'MultidimensionalFormat' - Dimensions of 2-D slice that represent n-D arrays of 
% char, logic or numeric data.
% 'rowvector' (default) | integer array of dimensions 1 by 2 or word 'rowvector'
% Dimensions of 2-D slices that represent n-D arrays of char, logic or numeric data
% specified as the comma-separated pair consisting of 'MultidimensionalFormat' and
% one of these values:
% 'rowvector' : Save multidimensional variables as a single row vector.
% integer cell array : Save a 2-D slice of multidimensional variables where
% the dimensions satisfy all the following criteria:
% - Dimensions are represented using two positive integers.
% - The two integers are less than or equal to the dimensions of the n-D array.
% - The second integer is greater than the first.
% Example:  matlab.io.saveVariablesToScript('myVariables.m', 'MultidimensionalFormat', [1 3] )
%
% 'RegExp' - Regular expression matching
% string
% Regular expression matching, specified as the comma-separated pair consisting of 'RegExp'
% and one or more expressions. Only input arguments with string values can be matched.
% Example: matlab.io.saveVariablesToScript('myVariables.m', 'RegExp', 'level*')
% 
% 'SaveMode' - Mode in which MATLAB script is saved
% 'create' (default) | 'update' | 'append'
% Mode in which MATLAB script is saved, specified as the comma-separated pair consisting
% of 'SaveMode' and one of these values:
% 'create' - Save variables to a new MATLAB script.
% 'update' - Only update variables that are already present in an existing MATLAB script.
% 'append' - Update variables that are already present in an existing MATLAB script
% and append new variables to the end of the script.
% Example: matlab.io.saveVariablesToScript('myVariables.m', 'SaveMode', 'create')
% 
% Output Arguments
% ---------------------------------------
% r1 - Variables that were saved to a MATLAB script
% cell array
% Variables that were saved to a MATLAB script, returned as a cell array
% of variable names.
% r2 - Variables that were saved to a MAT-file
% cell array
% Variables that were saved to a MAT-file, returned as a cell array of
% variable names.
%
% Examples
% --------------------------------------
% Save Workspace Variables to MATLAB Script
% Save variables from a workspace to a MATLAB script, test.m.
% matlab.io.saveVariablesToScript('test.m')
%
% Save Specific Workspace Variables to MATLAB Script
% Create and save variable myVar from a workspace to a MATLAB script, test.m.
% myVar = 55.3;
% matlab.io.saveVariablesToScript('test.m', 'myVar')
%
% Append Specific Variables to Existing MATLAB Script
% Create and save two variables, a and b, to an existing MATLAB script
% called abfile.m
% a = 72.3;
% b = pi;
% matlab.io.saveVariablesToScript('abfile.m', {'a', 'b'}, 'SaveMode', 'append');
%
% Update Specific Variables in Existing MATLAB Script
% Update and save two variables, y and z, to an existing MATLAB script called
% yzfile.m
% y = 15.7;
% z = 3 * pi;
% matlab.io.saveVariablesToScript('yzfile.m', {'y', 'z'}, 'SaveMode', 'update');
%
% Specify MATLAB Script Configuration for Saving Variable
% Update and save variable 'resistance' to an existing MATLAB script
% called 'designData.m' while specifying configuration of the script file.
% resistance = [10 20.5 11 13.7 15.1 7.7];
% matlab.io.saveVariablesToScript('designData.m', 'resistance', 'SaveMode', 'update', ...
% 'MaximumArraySize', 5)
%
% Specify Save Dimensions for 3-D Array in MATLAB Script
% Specify a 2-D slice for the output of the 3-D array my3Dtable, such that
% the 2-D slice expands along the first and third dimensions. Save the 2-D slice
% in the MATLAB script sliceData.m.
% level1 = [1 2; 3 4];
% level2 = [5 6; 7 8];
% my3Dtable(:, :, 1) = level1;
% my3Dtable(:, :, 2) = level2;
% matlab.io.saveVariablesToScript('sliceData.m', 'MultidimensionalFormat', [1 3] );
% The resulting MATLAB code is similar to following output:
% level1 = [ 1 2; 3 4];
% level2 = [5 6; 7 8]
% my3Dtable = zeros(2, 2, 2);
% my3Dtable(:,1,:) = ...
%  [1 5;
%   3 7];
% my3Dtable(:,2,:) = ...
%  [2 6;
%   4 8];
% 
% Save Variables Matching a Regular Expression in MATLAB Script
% Save variables that match the expression autoL* to a MATLAB script called
% autoVariables.m.
% matlab.io.saveVariablesToScript('autoVariables.m', 'RegExp', 'autoL*');
%
% Save Variables to Version 7 MATLAB Script
% matlab.io.saveVariablesToScript('version7.m', 'MATFileVersion', 'v7');
%
% Return Variables Not Saved to MATLAB Script
% Get variables that were saved to a MATLAB script, r1 and those that
% could only be saved to a MAT-file, r2.
% a = pi;
% b = fi(3, 1, 8);
% [r1, r2] = matlab.io.saveVariablesToScript('myData.m');
% r1 = 
%   'a'
% r2 =
%   'b'
% See also SAVE

%   Copyright 2013 The MathWorks, Inc.
