function newvalue = replacedlg

% Copyright 2007-2012 The MathWorks, Inc.

newvalue = [];
answer = inputdlg({getString(message('MATLAB:datamanager:replacedlg:SpecifyScalarToReplaceBrushedData'))},...
    getString(message('MATLAB:datamanager:replacedlg:ReplaceBrushedData')),1,{'0'}); 
if ~isempty(answer)
    try
        newvalue = eval(answer{1});
    catch %#ok<CTCH>
        newvalue = [];
    end
    if ~isscalar(newvalue)
        errordlg(getString(message('MATLAB:datamanager:replacedlg:ReplacementMustBeANumericScalar')), 'MATLAB', 'modal');
        newvalue = [];
        return
    end
else
    return
end