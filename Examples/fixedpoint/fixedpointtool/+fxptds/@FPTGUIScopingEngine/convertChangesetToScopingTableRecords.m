function convertChangesetToScopingTableRecords(this)
%% CONVERTCHANGESETTOSCOPINGTABLERECORDS function converts CurScopingChangeset to ScopingTable records
% If results were added before, they would have a ScopingId added via
% FPTGUIScopingEngine
% If getScopingId method of a result returns empty, then, the results were
% not used prior in ScopingInfrastructure

%   Copyright 2016-2017 The MathWorks, Inc.

    if ~isempty(this.CurScopingChangeset)
        % filter out invalid results 
        validResultIndices = false(1, numel(this.CurScopingChangeset));
        for rIndex = 1:numel(validResultIndices)
           validResultIndices(rIndex) = fxptds.isResultValid(this.CurScopingChangeset{rIndex}); 
        end

        this.CurScopingChangeset = this.CurScopingChangeset(validResultIndices);

        resultsToAdd = this.CurScopingChangeset;

        if ~isempty(resultsToAdd)
            % Convert matching results to fxptds.FPTGUIScopingTableRecord objects
            scopingTableObjs = cell(numel(resultsToAdd),1);
            for sIndex = 1:numel(resultsToAdd)
               scopingTableObjs{sIndex} = fxptds.FPTGUIScopingAdapter.getScopingTableRecord(resultsToAdd{sIndex}, resultsToAdd{sIndex}.RunObject);
            end
            
            % Class to struct throws a MATLAB::StructOnObject warning
            % Suppress the warning during conversion and turn it back on
            warningId = 'MATLAB:structOnObject';
            warning('off', warningId);
            % Convert scopingTableObjs to table records by intermediately converting
            % them to structs
            toAddRows = struct2table(cellfun(@struct, scopingTableObjs));
            warning('on', warningId);

            % Add rows to ScopingTable
            this.ScopingTable = [this.ScopingTable; toAddRows];

            % Update result with scopingId 
            for idx = 1:numel(resultsToAdd)
                resultsToAdd{idx}.addScopingId(scopingTableObjs{idx}.ID);
            end

            % Update current changesetTable to toAddRows to ensure when FPTGUI queries
            % for latest set of changes, the last known changeset can be returned.
            % This table should be emptied when queried by FPT GUI
            this.ChangesetTable = toAddRows;

            % Clear changeset
            this.CurScopingChangeset = {};
        end
    end
end