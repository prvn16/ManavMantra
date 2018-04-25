function setupMainFile(metadata, workDir)
mainFile = [metadata.main '.' metadata.extension];
src = fullfile(metadata.componentDir, 'main', mainFile);
target = fullfile(workDir, mainFile);
exampleUtils.copyIfMissing(src,target);
end