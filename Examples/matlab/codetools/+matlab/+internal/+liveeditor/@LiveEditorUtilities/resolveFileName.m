function fileName = resolveFileName(fileName)
% RESOLVEFILENAME - resolves the file name

validateattributes(fileName, {'char'}, {'nonempty'}, mfilename, 'fileName', 1)

% If only the filename is provided, then assume the file in the current
% working directory
if isempty(fileparts(fileName)) 
    fileName = fullfile(pwd, fileName);
end    

end

