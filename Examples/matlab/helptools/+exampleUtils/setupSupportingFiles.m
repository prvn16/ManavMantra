function setupSupportingFiles(metadata, workDir) 
    for iFiles = 1:numel(metadata.files)
        f = metadata.files{iFiles};
        src = fullfile(f.componentDir, f.filename);
        [~,~,ext] = fileparts(f.filename);
        if strcmp(ext,".m") || strcmp(ext,".mlx")
          src = fullfile(f.componentDir,'main',f.filename);
        end
        target = fullfile(workDir, f.filename);
        exampleUtils.copyIfMissing(src,target)
    end
end