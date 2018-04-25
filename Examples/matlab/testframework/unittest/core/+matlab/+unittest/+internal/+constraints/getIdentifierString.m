function str = getIdentifierString(identifier)
if isempty(identifier)
    str = getString(message('MATLAB:unittest:IssuesWarnings:NoID'));
else
    str = ['''' identifier ''''];
end
end