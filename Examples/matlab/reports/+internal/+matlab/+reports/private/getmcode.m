function textCellArray = getmcode(filename)
%GETMCODE  Returns a cell array of the text in a file
%   textCellArray = getmcode(filename)
% Throws an error if the file is binary (specifically,
% contains bytes with value zero).

% Copyright 1984-2016 The MathWorks, Inc.

fid = fopen(filename,'r');
if fid < 0
    error(message('MATLAB:codetools:fileReadError', filename))
end
% Now check for bytes with value zero.  For performance reasons,
% scan a maximum of 10,000 bytes.  Prevent any "interpretation"
% of data by reading uint8s and keeping them in that form.
data = fread(fid,10000,'uint8=>uint8');
isbinary = any(data==0);
if isbinary
    fclose(fid);
    error(message('MATLAB:codetools:getmcode', filename));
end
% No binary data found.  Reset the file pointer to the beginning of
% the file and scan the text.
fseek(fid,0,'bof');
try
    txt = textscan(fid,'%s','delimiter','\n','whitespace','');
    fclose(fid);
    textCellArray = txt{1};   
catch exception
    fclose(fid);    
    rethrow(exception)
end
