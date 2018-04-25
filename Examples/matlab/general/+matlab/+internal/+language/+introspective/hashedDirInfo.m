function dirInfo = hashedDirInfo(dirPath, isCaseSensitive)

    if nargin < 2
        isCaseSensitive = false;
    end

    persistent seenDirs;
    persistent usingHash;
    
    if islogical(dirPath)
        seenDirs = [];
        usingHash = dirPath;
        return;
    end
    
    if usingHash
        
        if isCaseSensitive
            caseCharacter = 'T';
        else
            caseCharacter = 'F';
        end
        
        dirPathAsField = [caseCharacter regexprep(fliplr(dirPath), {'@','+','\W'}, {'AT','PLUS',''})];
        if length(dirPathAsField) > namelengthmax
            dirPathAsField = dirPathAsField(1:namelengthmax);
        end
        if isfield(seenDirs, dirPathAsField)
            dirInfo = seenDirs.(dirPathAsField);
        else 
            dirInfo = casedWhat(dirPath, isCaseSensitive);
            
            try
                seenDirs.(dirPathAsField) = dirInfo;
            catch  %#ok<CTCH>
                usingHash = false;
            end
        end
    else
        dirInfo = casedWhat(dirPath, isCaseSensitive);
    end
end   

function result = casedWhat(dirPath, isCaseSensitive)

    if isCaseSensitive
        result = what('-casesensitive',dirPath);
    else                      
        result = what('-caseinsensitive', dirPath);
    end
end
    
%   Copyright 2007 The MathWorks, Inc.
