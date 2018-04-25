function result = extractFileSymbolReferencedAsStr(file)
% Prototype for auto-detection of files referenced as strings in m-code.

    result = struct([]);
    
    % A list of frequently used file reading functions and their default file extension.
    fcn_list = mostFrequentlyUsedFileReadingTools();
    
    mt = matlab.depfun.internal.cacheMtree(file);
    
    for k = keys(fcn_list)
        fcn_name = k{1};
        fcn_nodes = mtfind(mt, 'Kind', 'ID', 'String', fcn_name);
        if ~isempty(fcn_nodes)
            fcn_node_ids = indices(fcn_nodes);
            for n = 1:numel(fcn_node_ids)
                node = Right(trueparent(select(mt, fcn_node_ids(n))));
                if ~isempty(node)
                    if strcmp(kind(node),'ID')
                        % Find indirectly referenced files
                        nid = indices(mtfind(mt,'Kind','EQUALS', ...
                            'Left.Kind','ID','Left.String',string(node)));
                        if ~isempty(nid)
                            temp_node = Right(select(mt,nid(end)));
                            if ~isempty(temp_node)
                                node = temp_node;
                            end
                        end
                    end
                    
                    sym = '';
                    if any(strcmp(kind(node),{'CHARVECTOR','STRING'}))
                        [sym,w] = resolveFileSymbol(string(node), ...
                            fcn_list(fcn_name));
                    end
                    
                    if ~isempty(sym)
                        result(end+1).file = file; %#ok<AGROW>
                        result(end).lineno = lineno(node); 
                        result(end).symbol = sym;
                        result(end).path = w;                    
                        result(end).exp = tree2str(trueparent(select(mt, fcn_node_ids(n))),0,true);
                    end
                end
            end
        end
    end
    
    % Sort result based on the line number
    if ~isempty(result)
        [~,idx] = sort([result.lineno]);
        result = result(idx);
    end
end

function tf = existAsFile(f)
% G1418631: work-around for G1261803.
% EXIST('foo','file') does not differentiate file foo., foo.m, and folder foo.
% Who wants the implicity/ambiguity in EXIST?!
    exist_result = matlab.depfun.internal.cacheExist(f,'file');
    tf =  (exist_result > 0) && (exist_result ~= 7);
end

function [sym, w] = resolveFileSymbol(str, default_ext)
    sym = '';
    w = '';
    
    if ~isempty(str)
        % Remove artifacts added by MTREE
        if (str(1) == str(end)) && ((str(1) == '''') || (str(1) == '"'))
            str = str(2:end-1);
        end
        
        [~,~,ext] = fileparts(str);
        if isempty(default_ext)
            % No ambiguity if the function does not automatically append
            % default extension(s).
            if isempty(ext)
                % G1429446 - The extra dot matters because EXIST is too ambiguous.
                if existAsFile([str '.'])
                    sym = [str '.'];
                end
            else
                if existAsFile(str)
                    sym = str;
                end
            end
        else
            if isempty(ext)
                % Default extensions win precedence in file reading functions.
                sym = checkDefaultExtension(str, default_ext);
                
                % Didn't find a match? Try a last thing.
                % Does the file exist as a file with no extension? 
                % G1429446 - The extra dot matters because EXIST is too ambiguous. 
                if isempty(sym) && existAsFile([str '.'])
                    sym = [str '.'];
                end
            else
                % Experiments show that if there is a dot in str (foo.$EXT),
                % file reading functions like LOAD do not append default 
                % extension, no matter whether foo.$EXT.mat exists. 
                % For example, $EXT could be mat. If foo.mat does not exist but
                % foo.mat.mat exists, load('foo.mat') does not
                % automatically become load('foo.mat.mat').
                if existAsFile(str)
                    sym = str;
                end
            end
        end
        
        % Convert symbol to file full path.
        if ~isempty(sym)
            % The extra dot at the end can help WHICH find the file with no 
            % extension and also avoid to find the m-file with the same
            % name on the path.
            if ~contains(sym, '.')
                sym = [sym '.'];
            end
            w = matlab.depfun.internal.cacheWhich(sym);
        end
    end
end

function sym = checkDefaultExtension(str, default_ext)
    sym = '';
    for t = 1:numel(default_ext)
        str_with_default_ext = [str default_ext{t}];
        if existAsFile(str_with_default_ext)
            sym = str_with_default_ext;
            break;
        end
    end
end
