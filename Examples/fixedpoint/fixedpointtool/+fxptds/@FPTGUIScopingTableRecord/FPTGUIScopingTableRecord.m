
%   Copyright 2016 The MathWorks, Inc.

classdef FPTGUIScopingTableRecord < handle
%% FPTGUISCOPINGTABLERECORD class defines the table row for ScopingTable in FPTRepository
% 
% This class is a adapter that is using struct today to add rows to Table
% Object (ScopingTable) in fpxtds.FPTGUIScopingEngine
% In future, this adapter will be an interface to define schema for table
% to be added into SqlLite DB (ScopingTable) in fxptds.FPTGUIScopingEngine
%
    properties
        SubsystemId
        ResultId
        RunName
        DatasetSourceName
        ResultName
        ID
    end
    methods
        function set.SubsystemId(this, val)
            validateattributes(val, {'cell'}, {'nonempty'});
            this.SubsystemId = val;
        end
        function set.ResultId(this, val)
            validateattributes(val, {'cell'}, {'nonempty'});
            this.ResultId = val;
        end
        function set.RunName(this, val)
            validateattributes(val, {'cell'}, {'nonempty'});
            this.RunName = val;
        end
        function set.DatasetSourceName(this, val)
            validateattributes(val, {'cell'}, {'nonempty'});
            this.DatasetSourceName = val;
        end
        function set.ResultName(this, val)
            validateattributes(val, {'cell'}, {'nonempty'});
            this.ResultName = val;
        end
        function set.ID(this, val)
            validateattributes(val, {'cell'}, {'nonempty'});
            this.ID = val;
        end
        function isEmptyFlag = isempty(this)
            isEmptyFlag = true;
            memberProperties = properties(this);
            for idx=1:numel(memberProperties)
                isEmptyFlag = isEmptyFlag && isempty(this.(memberProperties{idx}));
            end
        end
    end
end