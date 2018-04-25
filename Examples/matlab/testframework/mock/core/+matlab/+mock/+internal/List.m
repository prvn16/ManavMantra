classdef List < handle
    % This class is undocumented and may change in a future release.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties (Access=private)
        Entries = matlab.mock.internal.ListEntry.empty(1,0);
    end
    
    methods
        function prepend(list, value)
            import matlab.mock.internal.ListEntry;
            
            list.Entries = [ListEntry.empty(1,0), value, list.Entries];
        end
        
        function entry = append(list, entry, id)
            import matlab.mock.internal.ListEntry;
            
            if nargin > 2
                entry = ListEntry(entry, id);
            end
            
            list.Entries = [list.Entries, entry];
        end
        
        function entry = findFirst(list, comparisonFcn)
            import matlab.mock.internal.ListEntry;
            
            for entry = list.Entries
                if comparisonFcn(entry.Value)
                    return;
                end
            end
            
            % No entries found
            entry = ListEntry.empty;
        end
        
        function entries = findAll(list, comparisonFcn)
            entries = list.Entries(cellfun(comparisonFcn, {list.Entries.Value}));
        end
    end
end

