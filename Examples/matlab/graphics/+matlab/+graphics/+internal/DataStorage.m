% Copyright 2014-2017 The MathWorks, Inc.

% This simple object is used to get a pass by 
% reference effect in MATLAB code. 

classdef DataStorage < handle & JavaVisible
    properties
        % Property for storing handles
        Data
    end
end
