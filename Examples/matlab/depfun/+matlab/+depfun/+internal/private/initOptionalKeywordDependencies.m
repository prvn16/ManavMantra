function Keyword2OptDep = initOptionalKeywordDependencies()
% This function returns a map that contains MATLAB keywords and their
% optional dependencies.
    Keyword2OptDep = containers.Map('KeyType', 'char', 'ValueType', 'any');
    
    if isPCTInstalledAndLicensed
        % The real entry points for PARFOR and SPMD are, respectively, 
        % parallel_function.m and spmd_feval.m. However, they are currently
        % owned by component matlab_toolbox_lang, which is shipped with
        % mcr_core. We need a hook in toolbox PCT so that dependencies in
        % PCT can be pulled in. (g1413545)
        %
        % Use capitalized keywords as keys because that is the way that
        % MTREE stores them.
        Keyword2OptDep('PARFOR') = {'parfeval'};
        Keyword2OptDep('SPMD')   = {'spmdlang.spmd_feval_impl'};
    end
end

function tf = isPCTInstalledAndLicensed()
    tf = false;
    installed = logical(exist('com.mathworks.toolbox.distcomp.pmode.SessionFactory', 'class')) && ...
                exist('distcompserialize', 'file') == 3; % 3 == MEX
    if installed
        tf = license('test', 'Distrib_Computing_Toolbox');
    end
end