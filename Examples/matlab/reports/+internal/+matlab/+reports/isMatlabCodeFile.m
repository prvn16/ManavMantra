function result = isMatlabCodeFile(fileName)
    % Copyright 2016-2017 The MathWorks, Inc.
    if nargin > 0
        fileName = convertStringsToChars(fileName);
    end
    
    import com.mathworks.jmi.MLFileUtils;
    result = MLFileUtils.isMatlabCodeFile(fileName);
end

