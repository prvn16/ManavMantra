classdef FPTPartInformation < handle
% FPTPartInformation Class to get the address of the Fixed-Point part
% within a SLX file
    
% Copyright 2014 The MathWorks, Inc.
    
    properties(SetAccess = private, GetAccess = private)
        PartID = 'workflowdata';
        PartName = '/fixedpointtool/workflowdata.xml';
        RelationshipType = 'http://schemas.mathworks.com/2015/relationships/fixedpointtool/workflowdata';
        ContentType = 'application/vnd.mathworks.simulink.workflowdata+xml';
        PartParent = '';
    end
    
    methods
        function p = getPartInformation(this)
            % get the part information for fixed-point data
            persistent part_info
            if isempty(part_info)
                % false = not a binary file
                part_info = Simulink.SLXPart(this.PartName, this.PartParent, this.PartID, this.RelationshipType,this.ContentType,false);
            end
            p = part_info;
        end
        
        function partName = getPartName(this)
            partName = this.PartName;
        end
        
        function partID = getPartID(this)
            partID = this.PartID;
        end
    end
end
