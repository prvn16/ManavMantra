function [params, options] = parseInputs(fcnName, inputs)
%parseInputs Parse inputs for web functions
%
%   Syntax
%   ------
%   [PARAMS, OPTIONS] = parseInputs(fcnName, INPUTS)
%
%   Description
%   -----------
%   [PARAMS, OPTIONS] = parseInputs(fcnName, INPUTS) parses the inputs
%   from the INPUTS cell array and returns PARAMS as a cell array and
%   OPTIONS as a scalar WEBOPTIONS object. fcnName is the name of the
%   calling function.
%
%   See also WEBREAD, WEBSAVE, WEBWRITE

% Copyright 2014 The MathWorks, Inc.

% Obtain options input, if present.
optionsIndex = cellfun(@(x)isa(x, 'weboptions'), inputs);
options = inputs(optionsIndex);
if isempty(options)
    options = weboptions;
elseif isscalar(options) && isscalar(options{1})
    options = options{1};
else 
    % More than one options or a non-scalar options has been specified.  
    % Use validateattributes to issue the error.
    options = [options{:}];
    validateattributes(options, {'weboptions'}, {'scalar'}, fcnName, 'OPTIONS')
end

% Set params as the inputs that are not weboptions.
params = inputs(~optionsIndex);
