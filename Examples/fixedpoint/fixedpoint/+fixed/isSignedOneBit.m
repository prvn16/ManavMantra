function success = isSignedOneBit(dataType)
    %ISSIGNEDONEBIT checks if dataType is a signed 1-bit type
    %
    % dataTypes must be numerictype or fixdt

    %   Copyright 2016 The MathWorks, Inc.
    
    success = dataType.WordLength == 1;
    if success
        if isequal(dataType.SignednessBool, true) || strcmp(dataType.Signedness,'Auto')
            %Ex: numerictype(1,x,y) or numerictype([],x,y)
            success = true;
        else
            success = false;
        end
    end
end