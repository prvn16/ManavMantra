% Copyright 2014-2017 The MathWorks, Inc.

% brush class: This class provides access to properties of the
% datalink state in MATLAB

classdef LinkData < matlab.mixin.SetGet
    properties(SetAccess = private)
        Enable
    end

    methods
        function h = LinkData(state)
            if nargin>=1
                h.Enable = state;
            end
        end
    end
end

