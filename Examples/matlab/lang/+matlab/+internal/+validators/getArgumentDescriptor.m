function argDes = getArgumentDescriptor( msgId, argname, argpos )

% for performance sake, only call when it has already been determined to
% throw an exception

switch msgId
    case 'NoNameNoNumber'
        argDes = getString(message( [ 'MATLAB:validateattributes:' msgId] ) );
    case 'NameNoNumber'
        argDes = getString(message( [ 'MATLAB:validateattributes:' msgId], argname ) );
    case 'NoNameNumber'
        argDes = getString(message( [ 'MATLAB:validateattributes:' msgId], argpos ) );
    case 'NameNumber'
        argDes = getString(message( [ 'MATLAB:validateattributes:' msgId], argpos, argname ) );
end

end
