function doLog(str,folderPath)
    disp(str);
    fid = fopen(fullfile(folderPath, 'checkInfo.txt'),'at+');
    fprintf(fid,'%s\n',str);
    fclose(fid);  
end