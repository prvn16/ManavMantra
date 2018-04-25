function obj = getMessageOutputObject( type, wasCell, files, inputWasText, msgIdsWereRequested )

switch( lower( type ) )
    case 'string'
        obj = matlab.internal.codeanalyzer.returnMessageString( wasCell, files, inputWasText, msgIdsWereRequested );
    case 'struct'
        obj = matlab.internal.codeanalyzer.returnMessageStruct( wasCell, files, inputWasText, msgIdsWereRequested );
    case { 'disp', 'display' }
        obj = matlab.internal.codeanalyzer.displayMessages( wasCell, files, inputWasText, msgIdsWereRequested );
end

end