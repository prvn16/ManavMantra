function ed = getExamplesDir
% 

% Unsupported and for internal use only.
publishTempPwd = getappdata(0,'demo_publishing_temp_directory');
if publishTempPwd
    ed = publishTempPwd;
else
    ed = fullfile(userDir,'Examples');
end

end


function userWorkFolder = userDir
userPathString = userpath;
userPathFolders = strsplit(userPathString, {pathsep,';'});
firstFolder = userPathFolders{1};
if (isdir(firstFolder))
    userWorkFolder = firstFolder;
else
    userWorkFolder = system_dependent('getuserworkfolder', 'default');
end
end