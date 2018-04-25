function tf = isprivate(files)

persistent privatePat

if isempty(privatePat)
    privatePat = [ '.+\' filesep 'private\' filesep '.*' ];
end

if ischar(files)
    files = { files };
end

tf = ~cellfun('isempty', regexp(files, privatePat, 'ONCE'));

end