classdef MatFileInspector < matlab.depfun.internal.MwFileInspector
% MatFileInspector Determine what files and classes a MAT file requires.
% Copyright 2016 The MathWorks, Inc.

    methods
        
        function obj = MatFileInspector(r, t, fsCache, useDB, fcns)
            % Pass on the input arguments to the superclass constructor
            obj@matlab.depfun.internal.MwFileInspector(r, t, fsCache, useDB, fcns);
        end
        
        function [identified_symbol, unknown_symbol] = determineType(obj, name) %#ok
            unknown_symbol = [];
            
            fullpath = '';
            if isfullpath(name)
                % WHICH cannot find .mat file even if the file full path is
                % given, when the file is not on the search path.
                if matlab.depfun.internal.cacheExist(name, 'file') == 2
                    fullpath = name;
                end
            else
                if matlab.depfun.internal.cacheExist(fullfile(pwd, name), 'file') == 2
                    fullpath = fullfile(pwd, name);
                else
                    fullpath = matlab.depfun.internal.cacheWhich(name);
                end
            end
                
            if isempty(fullpath)
                error(message('MATLAB:depfun:req:NameNotFound',name));
            end
                
            [~, filename, ext] = fileparts(fullpath);
            identified_symbol = matlab.depfun.internal.MatlabSymbol( ...
                    [filename ext], matlab.depfun.internal.MatlabType.Data, fullpath);
        end
        
    end % Public methods

    methods (Access = protected)
        
        function S = getSymbols(obj, file) %#ok
        % getSymbolNames returns symbols used in a .mat file.
            S = {};
            % Known limitations:
            % WHOS only knows the class/type of top level variables stored
            % in the mat file. It does not traverse through cell or struct
            % recursively to find stored class objects. 
            % WHOS does not know what function is referred by a
            % function handle either. 
            % There is no API supporting the above functionality in 16b.
            % 
            % .mat often don't get used repeatedly in the code, so there
            % would not be much performance gain by caching the WHOS result.
            WhosResult = whos('-file', file);
            if ~isempty(WhosResult)
                type = {WhosResult.class};
                tS = unique(type);
                
                S = tS';
            end
        end
        
    end % Protected methods
end


