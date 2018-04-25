function lic = writeactxlicense(progid, lickey)
% Copyright 1984-2008 The MathWorks, Inc.

actFile = exist('actxlicense.m', 'file');

if(~actFile)
    %create new actxlicense.m file
    fid = fopen('actxlicense.m','w');
    %set the function name
    fprintf(fid, 'function lic = actxlicense(progid)');
    fprintf(fid, '\n');
    %add the entry
    addnewEntry(fid, progid, lickey);
    fclose(fid);
    
else
    %open actxlicense,m for reading
    fid = fopen('actxlicense.m','r');
    
    if(fid ~= -1)
        s = char(fread(fid));
        ret = strfind(s', progid);
        if isempty(ret)
            %entry does not exist, write a new one.
            fclose(fid);
            fid = fopen('actxlicense.m','a');
            addnewEntry(fid, progid, lickey);
            fclose(fid);
        else
            %entry exists, close the file and return
            fclose(fid);
        end
        
    end
end

function addnewEntry(fid, progid, lickey)
fprintf(fid, '\n');
fprintf(fid, 'if strcmpi(progid, ''%s'')', progid);
fprintf(fid, '\n');
fprintf(fid, 'lic = ''%s'';', lickey); 
fprintf(fid, '\n');
fprintf(fid,'return;');
fprintf(fid, '\n');
fwrite(fid, 'end');
fprintf(fid, '\n');
