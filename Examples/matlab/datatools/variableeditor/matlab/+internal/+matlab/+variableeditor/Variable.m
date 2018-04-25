classdef Variable < handle & JavaVisible
    % VARIABLE
    % An abstract class defining the methods for a Variable Data Model
    % 

    % Copyright 2013 The MathWorks, Inc.

    % Public Abstract Methods
    methods(Access='public',Abstract=true)
        % getData
        varargout = getData(this,varargin);

        % getSize
        size = getSize(this);
        
        % updateData
        data = updateData(this, varargin);
    end
end %classdef
