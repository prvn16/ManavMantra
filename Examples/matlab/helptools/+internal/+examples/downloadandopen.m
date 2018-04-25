function downloadandopen(id, url, mainfile)

workDir = makeWorkDir(id);
tFile = [tempname '.zip'];
urlwrite(url, tFile);
unzip(tFile, workDir);
delete(tFile)
cd(workDir)

% todo: simulink models won't work with this approach. Need to pass in the command to run, if featured example.
edit(mainfile)
% eval(cmd)



