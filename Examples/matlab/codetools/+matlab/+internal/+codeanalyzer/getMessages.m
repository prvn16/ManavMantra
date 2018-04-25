function mlntMsg = getMessages( caInputParser )
%GETMESSAGES takes the input parser object; reads the files, text and options
%   and passes them to mlintmex.

if( isempty( caInputParser.files ) && caInputParser.fileListWasCell )
    mlntMsg = {};
    return;
end

files = caInputParser.files;
if( ~isrow( files ) )
    files = files';
end

args = [caInputParser.options, files];
mlntMsg = mlintmex( args{:} );

end
