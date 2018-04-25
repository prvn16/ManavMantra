function tf = useSharedLibrary(varargin)
% For internal testing use only

% This function is used by dual-mode code generation based functions to 
% decide whether or not shared library code or generic code should be 
% generated.
%
% TF = USESHAREDLIBRARY() Returns the previously stored state as a boolean 
% value. The default value is true unless it was reset. This syntax is used
% when codegen target is MATLAB Host. 

% TF = USESHAREDLIBRARY(MODE) Returns the input boolean MODE value and also
%  updates its state. 

%   Copyright 2014 The MathWorks, Inc.

narginchk(0,1);

persistent codegenForHost

if isempty(codegenForHost)
    % Default (shared library)
    codegenForHost = true;
end

% Update state to new mode value
if ~isempty(varargin)
    validateattributes(varargin{1},{'logical'},{},mfilename);
    codegenForHost = varargin{1};
end

tf = codegenForHost;
