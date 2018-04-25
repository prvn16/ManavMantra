% LOCALFUNCTIONS - function handles to all local functions in a MATLAB file
% 
%   FCNS = localfunctions() returns in FCN a cell array containing function
%   handles to all local functions defined in the file in which it was
%   called. By definition, no local functions are defined in the context of
%   the command line, scripts, or anonymous functions, so when called from
%   such contexts an empty cell array is returned. The order of the
%   function handles returned in the cell array is not defined.
%
%   Example
%       % In "fileWithLocalFunctions.m"
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       function fileWithLocalFunctions
%
%       fcns = localfunctions;
%       display(fcns);
%
%       function alocalfunction
%
%       function anotherlocalfunction
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       % End "fileWithLocalFunctions.m"
%
%       >> fileWithLocalFunctions
%
%       fcns = 
%
%           @alocalfunction      
%           @anotherlocalfunction
%       



%   Copyright 2013 The MathWorks, Inc.
%   Built-in function.
