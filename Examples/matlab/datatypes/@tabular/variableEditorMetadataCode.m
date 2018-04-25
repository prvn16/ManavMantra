function [metadataCode,warnmsg] = variableEditorMetadataCode(this,varName,index,propertyName,propertyString)
    % This function is for internal use only and will change in a
    % future release.  Do not use this function.
    
    % Generate MATLAB command to modify table metadata at positions defined
    % by index input.
    
    %   Copyright 2011-2016 The MathWorks, Inc.
    
    warnmsg = '';
    if strcmpi('VariableNames',propertyName)
        % Validation
        if ~isvarname(propertyString)
            error(message('MATLAB:codetools:InvalidVariableName',propertyString));
        end
        
        % Check for duplicates (exclude the current column)
        currLabels = this.varDim.labels;
        if strcmp(currLabels{index}, propertyString)
            metadataCode = '';
        else
            currLabels(index) = [];
            if any(strcmp(currLabels,propertyString))
                error(message('MATLAB:table:DuplicateVarNames',propertyString));
            end
            metadataCode = [varName '.Properties.VariableNames{' num2str(index) '} = ''' fixquote(propertyString) ''';'];
        end
    elseif strcmpi('VariableUnits',propertyName) || strcmpi('VariableDescriptions',propertyName)
        metadataCode = [varName '.Properties.' propertyName '{' num2str(index) '} = ''' fixquote(propertyString) ''';'];
    elseif strcmpi('Format', propertyName)
        % Set the Format for any datetime columns
        [colNames, varIndices, colClasses] = variableEditorColumnNames(this);
        if isdatetime(this.rowDim.labels) || isduration(this.rowDim.labels)
            % colNames, varIndices and colClasses include the rownames, if
            % they are datetimes or duration.  These aren't needed for the
            % metadata function.
            colNames(1) = [];
            colClasses(1) = [];
            varIndices(end) = [];
        end

        idx = strcmp(colClasses, 'datetime');
        metadataCode = '';
        if any(idx)
            for col=varIndices(idx)
                d = this.data{col};
                if ~strcmp(d.TimeZone, 'UTCLeapSeconds')
                    metadataCode =  [metadataCode varName '.' colNames{col} '.Format = ''' propertyString '''; ']; %#ok<AGROW>
                end
            end
        end
        % Use the format for the row labels as well, if they are times.
        if isdatetime(this.rowDim.labels)
            % Only one specific form is currently allowed for UTCLeapSeconds
            if ~strcmp(this.rowDim.labels.TimeZone, 'UTCLeapSeconds')
                metadataCode =  [metadataCode '; ' varName '.Properties.RowTimes.Format = ''' propertyString '''; '];
            end
        elseif isduration(this.rowDim.labels)
            metadataCode =  [metadataCode '; ' varName '.Properties.RowTimes.Format = ''' propertyString '''; '];
        end
    end
end



