function id = generateId( fname, mnemonic )
; %#ok<NOSEM> % Undocumented

% Copyright 2011 The MathWorks, Inc.

if isempty( fname )
    id = 'MATLAB';
else
    id = [ 'MATLAB:' fname ] ;
end

id = [ id ':' mnemonic ];
        
% fix up the id as best we can, note we don't handle '+', ie packages
id = strrep( id, '.', ':');
id = strrep( id, '/', ':');
id = strrep( id, '>', ':');

if ~isValidId( id )
    id = [ 'MATLAB:' mnemonic ];
end

end

function tf = isValidId( id )
tf = ~isempty( regexpi( id, '^([a-z]\w*:)+[a-z]\w*$', 'once' ) );
end
