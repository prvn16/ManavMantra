classdef Query < handle
    % QUERY Object containing parameters specified by client on what data to fetch
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = private)
        SortColumn = 'Name';
        SortDir = 'ascend';
        StartIndex = 1;
        Count = 25;
        HiddenRuns = {};
        TreeSelection = '';
    end
    
    methods
        function this = Query(clientMessage)
            if nargin > 0
                if clientMessage.sort.descending
                    this.SortDir = 'descend';
                end
                this.SortColumn = clientMessage.sort.attribute;
                this.StartIndex = clientMessage.start + 1;
                this.Count = clientMessage.count;
                this.HiddenRuns = clientMessage.hiddenRuns;
                this.TreeSelection = clientMessage.treeSelection;
            end
        end
    end
end