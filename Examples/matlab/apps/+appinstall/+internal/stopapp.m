function stopapp(~, ~, obj) 
    prop = properties(obj);
    if(any(cell2mat(strfind(prop, 'Version'))))
        cleanup13a(obj);
    else
        cleanup12b(obj);
    end
end

function cleanup12b(obj)
    exitfcn = strcmp(obj.ExistCloseFcn, 'closereq');	 
    if(~exitfcn)	 
        if(isa(obj.ExistCloseFcn,'function_handle'))	 
            feval(obj.ExistCloseFcn);	 
        else	 
            eval(obj.ExistCloseFcn);	 
        end	 
    end	 
    closereq;
    cleanup(obj);
end

function cleanup13a(obj)
    AppRefCount = obj.refcount(obj.Decrement);	
    if(AppRefCount == 0)
        munlock(obj.AppClass);	
        cleanup(obj);
    end

end
     
function cleanup(obj)
%     closereq;
    apppath = java.io.File(obj.AppPath{:});
    canonicalpath = char(apppath.getCanonicalPath());
    allpaths = genpath(canonicalpath);    
    fullpath = strrep(allpaths, [canonicalpath filesep 'metadata;'], '');
    rmpath(fullpath);
end
