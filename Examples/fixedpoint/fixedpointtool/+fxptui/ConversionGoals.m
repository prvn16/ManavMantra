classdef ConversionGoals < handle
% CONVERSIONGOALS - Class that stores the goals for floa-fixed and
% fixed-fixed conversion. 

% Future enhancement - This object can read the goals stored in the model
% and load the workflow tools with the appropriate information

% Copyright 2014-2017 The MathWorks, Inc.
    
properties(SetAccess = private, GetAccess = private)
    Model
    SystemUnderConversion
end

methods
    function this = ConversionGoals(model)
        if nargin < 1
            [msg, identifier] = fxptui.message('incorrectInputArgsModel');
            e = MException(identifier, msg);
            throwAsCaller(e);
        end
        sys = find_system('type','block_diagram','Name',model);
        if isempty(sys)
            [msg, identifier] = fxptui.message('modelNotLoaded',model);
            e = MException(identifier, msg);
            throwAsCaller(e);
        else
            this.Model = model;
        end
    end
    
    function setSystemForConversion(this, sysObj)
        if isa(sysObj,'DAStudio.Object')
            this.SystemUnderConversion = sysObj;
        end
    end
    
    function sysObj = getSystemForConversion(this)
        sysObj = this.SystemUnderConversion;
        if ~isa(sysObj,'DAStudio.Object') || strncmp(sysObj.getFullName,'built-in/',9) ...
                || strncmp(sysObj.getFullName,'Delete/',6)
            sysObj = [];
        else
            % When subsystems are contained within charts, deleting the top
            % level chart does not make the underlying object invalid (the
            % above checks still pass). Try resolving the object's path to
            % the object again.(see g1561716).
            try
                sysObj = get_param(sysObj.getFullName,'Object');
            catch
                sysObj = [];
            end
        end
    end
    
    function clearSystemForConversion(this)
        this.SystemUnderConversion = [];
    end
end
end
