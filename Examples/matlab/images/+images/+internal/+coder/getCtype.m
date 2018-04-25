function  ctype = getCtype(A) %#codegen
%GETCTYPE Get the C data type string
%
if(isa(A,'logical'))
    ctype = 'boolean';
elseif(isa(A,'single'))
    ctype = 'real32';
elseif(isa(A,'double'))
    ctype = 'real64';    
else
    % default
    ctype = class(A);
end

