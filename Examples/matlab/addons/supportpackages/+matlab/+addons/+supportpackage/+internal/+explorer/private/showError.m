% Copyright 2016 The MathWorks, Inc.
function showError( exception )
    if(isa(exception, 'matlab.exception.JavaException'))
        javaException = exception.ExceptionObject;
        errorMessage = char(javaException.getMessage);
        addOnsInvalidArgumentException = MException('AddOns:InvalidArgument', errorMessage);
        throw(addOnsInvalidArgumentException);
    else
        throw(exception);
    end
end

