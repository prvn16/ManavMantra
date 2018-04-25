%NoCellIndexingMixin mixin for array types that disallow cell-style brace
% indexing
%
%   This class provides implementations of subsrefBraces and subsasgnBraces that
%   simply throw the MATLAB error.

% Copyright 2016 The MathWorks, Inc.

classdef NoCellIndexingMixin
    methods
        function varargout = subsrefBraces(~, ~, ~, ~) %#ok<STOUT>
            error(message('MATLAB:cellRefFromNonCell'));
        end
        
        function obj = subsasgnBraces(~, ~, ~, ~, ~) %#ok<STOUT>
            error(message('MATLAB:cellAssToNonCell'));
        end
    end
end
