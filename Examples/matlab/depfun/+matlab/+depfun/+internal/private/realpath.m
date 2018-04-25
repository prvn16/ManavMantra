function files = realpath(files)
% REALPATH Correct obvious mistakes in file paths. Eliminate confusion and
% ambiguity.

    if ~iscell(files)
        files = { files };
    end
    
    % Collapse consequtive file-separators into a single file separator,
    % unless they occur at the beginning of the path.
    
    sepPat = '([/\\][/\\]+)';  % At least two, of either direction.
    repSep = regexp(files,sepPat,'tokenExtents');
    if ~isempty(repSep)
        
        % Remove matches at the beginning of the path; we won't correct
        % those, since consequtive separators are valid there.
        for k = 1:numel(repSep)
            extents = repSep{k};
            if ~isempty(extents)
                atStart = cellfun(@(extent)extent(1) == 1, extents);
                extents = extents(~atStart);
                repSep{k} = extents;
            end
        end
        
        % Any non-empty entry in repSep indicates a string of file
        % separators that needs correcting.
        fixups = ~cellfun('isempty', repSep);
        if any(fixups)
            correctableFiles = files(fixups);
            correctableExtents = repSep(fixups);
            for k=1:numel(correctableFiles)
                extentOffset = 0;
                for n=1:numel(correctableExtents{k})
                    e = correctableExtents{k}{n};
                    % Remove all the repeated file separators except the 
                    % first one. As we shrink the file string, the extents
                    % shift by the number of removed characters. Tricky.
                    rStart = e(1) + 1 - extentOffset;
                    rEnd = e(2) - extentOffset;
                    correctableFiles{k}(rStart:rEnd) = [];
                    % Remember how many characters we removed.
                    extentOffset = extentOffset + e(2) - e(1) + 1;
                    
                end
            end
            files(fixups) = correctableFiles;
        end
    end
end
