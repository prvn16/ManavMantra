function preloadWhichCache(pcm_navigator)
% Preload the WHICH cache from the given database.
% 
%  DATABASE: Full path to the database file. DependencyDepot will create
%  the database if necessary.
%
%  PTH: A cell-array of path items; order matters, as this list controls
%  the precedence of builtins with the same name and the availability of
%  builtins with assigned toolbox locations.
    
    % Empty the cache
    matlab.depfun.internal.cacheWhich();
    
    % Load all the builtins from the database, normalizing their
    % paths to the MATLAB root.
    tbl = pcm_navigator.builtinRegistry;
    
    % Wrap the values in 'built-in ( ... )' so the cache will return the same
    % string returned by MATLAB.
    fs = filesep;
    function whichResult = wrapPath(sym,type,loc)
        import matlab.depfun.internal.requirementsConstants;
        import matlab.depfun.internal.MatlabType;

        whichResult = sprintf('%s (undocumented)', ...
                              requirementsConstants.BuiltInStr);
        switch(type)
            case MatlabType.BuiltinClass
                whichResult = ...
                    [sym requirementsConstants.IsABuiltInMethodStr];
            case MatlabType.BuiltinMethod
                whichResult = [sym requirementsConstants.IsABuiltInMethodStr];                    
            case MatlabType.BuiltinFunction
                if ~isempty(loc)
                    whichResult = [ ...
                        requirementsConstants.BuiltInStrAndATrailingSpace ...
                        '(' loc fs sym ')'];
               end
        end 
    end

    v = tbl.values;
    values = [v{:}]; % MATLAB! Why can't I concatentate indexing operations?
    builtinSym = tbl.keys;
    
    % G1228159
    % WHICH returns nothing for built-in packages, so they should not
    % shadow things. They are useless in the built-in cache.
    if ~isempty(values)
        builtinPkgIdx = [values.type] == matlab.depfun.internal.MatlabType.BuiltinPackage;
        values(builtinPkgIdx) = [];
        builtinSym(builtinPkgIdx) = [];
    end    
    
    if ~isempty(values)
        type = { values.type };
        loc = { values.loc };
        
        builtinStr = cellfun(@(sym,type,loc)wrapPath(sym,type,loc), ...
                             builtinSym, type, loc, ...
                             'UniformOutput', false); 

        % Preload the cache
        matlab.depfun.internal.cacheWhich(builtinSym, builtinStr);    
    end
end
