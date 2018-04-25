function currFormat = variableEditorMetadata(this)
    % This function is for internal use only and will change in a
    % future release.  Do not use this function.
    
    % Retrieves the format for any datetime columns in the table, which
    % is needed for the variable editor.
    
    % Copyright 2014-2016 The MathWorks, Inc.
    
    % Get the Format for any datetime columns
    [~, varIndices, colClasses] = variableEditorColumnNames(this);
    if isdatetime(this.rowDim.labels) || isduration(this.rowDim.labels)
        % varIndices and colClasses include the rownames, if they are
        % datetimes or duration.  These aren't needed for the metadata
        % function.
        colClasses(1) = [];
        varIndices(end) = [];
    end
    idx = strcmp(colClasses, 'datetime');
    currFormat = '';
    if any(idx)
        for col=varIndices(idx)
            % For table we currently don't provide a mechanism to
            % display/choose multiple formats, so we will just return the
            % first one found.
            d = this.data{col};
            if ~strcmp(d.TimeZone, 'UTCLeapSeconds')
                currFormat = d.Format;
                break;
            end
        end
    elseif isdatetime(this.rowDim.labels)
        % Use the format for the row labels if they are datetimes
        if ~strcmp(this.rowDim.labels.TimeZone, 'UTCLeapSeconds')
            currFormat = this.rowDim.labels.Format;
        end
    end
end