%PROJDUMPMAT Helper function to get the variable names and short values from a MAT file.
%   Copyright 2008-2014 The MathWorks, Inc. 

function result = projdumpmat(filename)
    result = [];    
    if strcmp(filename, 'global')
        variables = evalin('base', 'whos');
    else
        variables = whos('-file', filename);
    end
	
    for i = 1:length(variables)
        result(i).name = variables(i).name;    
		
        if strcmp(filename, 'global')
            result(i).shortValue = evalin('base', ['workspacefunc(''getshortvalue'',' variables(i).name ')']);
        else
            data = load(filename, variables(i).name);
            result(i).shortValue = eval(['workspacefunc(''getshortvalue'', data.' variables(i).name ')']);
        end 
        result(i).class = variables(i).class;
    end
end