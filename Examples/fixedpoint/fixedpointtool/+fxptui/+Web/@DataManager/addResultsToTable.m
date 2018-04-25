function addResultsToTable(this, results)
    % ADDRESULTSTOTABLE Convert the result array to table rows and add to database
    
    % Copyright 2017 The MathWorks, Inc.
    
    
    
    % Run map to avoid using unique() which can be very expensive for large arrays.
    runMap = containers.Map('KeyType','char','ValueType','double');
    
    initStruct = struct();
    for i = 1:numel(this.TableProperties)
        initStruct.(this.TableProperties{i}) = [];
    end
    resultsStruct(numel(results)) = initStruct;
    
    for resultCount = 1 : numel(results)
        result = results(resultCount);
        icon = result.getDisplayIcon;
        [~, filename] = fileparts(icon);
        runName = result.getRunName;
        runMap(runName) = 0;
        
        resultsStruct(resultCount).id = result.ScopingId;
        resultsStruct(resultCount).Class = filename;
        resultsStruct(resultCount).Name = fxptui.removeLineBreaksFromName(result.UniqueIdentifier.getDisplayName);
        resultsStruct(resultCount).Run = runName;
        resultsStruct(resultCount).objectClass = fxptds.Utils.getObjectClass(result);
        resultsStruct(resultCount).CompiledDT = fxptds.Utils.getCompiledDTStringForResultCell(result);
        resultsStruct(resultCount).SpecifiedDT = result.SpecifiedDT;
        resultsStruct(resultCount).ProposedDT = result.getPropertyValue('ProposedDT');
        resultsStruct(resultCount).DTGroup = result.DTGroup;
        if (result.hasProposedDT)
            resultsStruct(resultCount).Accept = result.Accept;
        else
            resultsStruct(resultCount).Accept = NaN;
        end
        resultsStruct(resultCount).SimMin_S = fxptui.convertNumberToString(result.SimMin);
        resultsStruct(resultCount).SimMax_S = fxptui.convertNumberToString(result.SimMax) ;
        resultsStruct(resultCount).SimMin = fxptui.convertEmptyToNaN(result.SimMin);
        resultsStruct(resultCount).SimMax = fxptui.convertEmptyToNaN(result.SimMax);
        resultsStruct(resultCount).DerivedMin_S = fxptui.convertNumberToString(result.DerivedMin) ;
        resultsStruct(resultCount).DerivedMax_S = fxptui.convertNumberToString(result.DerivedMax) ;
        resultsStruct(resultCount).DerivedMin = fxptui.convertEmptyToNaN(result.DerivedMin);
        resultsStruct(resultCount).DerivedMax = fxptui.convertEmptyToNaN(result.DerivedMax);
        resultsStruct(resultCount).DesignMin_S = fxptui.convertNumberToString(result.DesignMin) ;
        resultsStruct(resultCount).DesignMax_S = fxptui.convertNumberToString(result.DesignMax) ;
        resultsStruct(resultCount).DesignMin = fxptui.convertEmptyToNaN(result.DesignMin);
        resultsStruct(resultCount).DesignMax = fxptui.convertEmptyToNaN(result.DesignMax);
        resultsStruct(resultCount).ProposedMin_S = fxptui.convertNumberToString(result.RepresentableMin) ;
        resultsStruct(resultCount).ProposedMax_S = fxptui.convertNumberToString(result.RepresentableMax) ;
        resultsStruct(resultCount).ProposedMin = fxptui.convertEmptyToNaN(result.RepresentableMin);
        resultsStruct(resultCount).ProposedMax = fxptui.convertEmptyToNaN(result.RepresentableMax);
        resultsStruct(resultCount).OverflowSaturation =  fxptui.convertEmptyToNaN(result.getPropertyValue('OverflowSaturation')) ;
        resultsStruct(resultCount).OverflowWrap =  fxptui.convertEmptyToNaN(result.getPropertyValue('OverflowWrap')) ;
        resultsStruct(resultCount).hasProposedDT = result.hasProposedDT ;
        resultsStruct(resultCount).hasDTGroup = result.hasDTGroup ;
        resultsStruct(resultCount).runHasSimRange = false ;
        resultsStruct(resultCount).runHasDeriveRange = false ;
        resultsStruct(resultCount).runHasProposals = false;
        resultsStruct(resultCount).hasOverflows = result.hasOverflows ;
        resultsStruct(resultCount).hiliteRowsWithIssues = result.hasIssuesWithDerivedRanges;
        resultsStruct(resultCount).IsReadOnly = result.isReadOnly;
        resultsStruct(resultCount).hasInterestingInformation = result.hasInterestingInformation;
        resultsStruct(resultCount).HistogramVisualizationInfo = fxptds.HistogramUtil.getHistogramVisualizationInfo(result);
    end
    
    % Convert array of structs to cell array of cells
    resultsStruct = resultsStruct(:);
    
    % To convert a 1x1 structure when there is only one result, convert to
    % table using the 'AsArray' flag.
    toAddRows = struct2table(resultsStruct, 'AsArray',true);
    toAddRows.Properties.VariableNames = this.TableProperties;
    
    % Make the id as the row name. This will help improve performance when
    % searching for certain results in the table.
    toAddRows.Properties.RowNames = toAddRows.id;
    
    % update the columns for hasSimRange, hasDerivedRange & hasProposals based on values in the run.
    runNames = runMap.keys;
    for i = 1:numel(runNames)
        idx = strcmp(toAddRows.Run, runNames(i));
        tmpTable = toAddRows(idx, :);
        % Emptys are converted to NaNs
        toAddRows(idx, 'runHasSimRange') = {any(~isnan(tmpTable.SimMin)) ||  any(~isnan(tmpTable.SimMax))};
        toAddRows(idx, 'runHasDeriveRange') = {any(~isnan(tmpTable.DerivedMin)) ||  any(~isnan(tmpTable.DerivedMax))};
        % Check for 'n/a' and 'locked' proposals.
        toAddRows(idx, 'runHasProposals') =  {any(~strcmp(tmpTable.ProposedDT, ''))};
    end
    
    % detect existing data in the table
    commonIDs = '';
    if ~isempty(this.ResultDatabase)
        commonIDs = intersect(this.ResultDatabase.id, toAddRows.id);
    end
    % Delete the old entries
    if ~isempty(commonIDs)
        this.ResultDatabase(commonIDs, :) = [];
    end
    % Append rows to table
    if isempty(this.ResultDatabase)
        this.ResultDatabase = toAddRows;
    else
        % Otherwise, append rows to existing table
        this.ResultDatabase = [this.ResultDatabase; toAddRows];
    end
end
