function [filename,extOut,user_canceled] = imputfile
%IMPUTFILE Save Image dialog box.  
%   [FILENAME, EXT, USER_CANCELED] = IMPUTFILE displays the Save Image
%   dialog box for the user to fill in and returns the full path to the
%   file selected in FILENAME.  Additionally the file extension is returned
%   in EXT.  If the user presses the Cancel button, USER_CANCELED will
%   be TRUE. Otherwise, USER_CANCELED will be FALSE.
%   
%   The Save Image dialog box is modal; it blocks the MATLAB command line
%   until the user responds.
%   
%   See also IMFORMATS, IMTOOL, IMGETFILE, IMSAVE.

%   Copyright 2007-2014 The MathWorks, Inc.

% Get filter spec for image formats
filterSpec = createFilterSpec();

[filename, pathname, filterindex] = uiputfile(filterSpec,...
    getString(message('images:fileGUIUIString:putFileWindowTitle')));

user_canceled = (filterindex == 0);

if ~user_canceled
    
    filename = fullfile(pathname,filename);
    % If there are variants of extension name, return first extenstion in list
    selectedExt = filterSpec{filterindex,1};
    ind = strfind(selectedExt,';');
    if isempty(ind)
        extOut = selectedExt(3:end);
    else
        extOut = selectedExt(3:ind-1);
    end
    
else
    filename = '';
    extOut = '';
end


function filterSpec = createFilterSpec()

[desc, ext , ~, write_fcns] = iptui.parseImageFormats();
nformats = length(desc);

% Grow filter spec dynamically to avoid need to hardcode knowledge of
% number of supported file formats or formats with write_fcns.
filterSpec = {};

% Formats that we want to disable in imputfile
excluded_exts = {'gif','hdf','pcx','pnm','xwd','dcm','rset'};

for i = 1:nformats
    
    format_is_writable = ~isempty(write_fcns{i});
    format_is_excluded = any(ismember(ext{i},excluded_exts));
    
    if format_is_writable && ~format_is_excluded
        thisExtension = ext{i};
        numExtensionVariants = length(thisExtension);
        thisExtensionString = strcat('*.',thisExtension{1});
        for j = 2:numExtensionVariants
            thisExtensionString = strcat(thisExtensionString,';*.',thisExtension{j});
        end
        
        % Populate individual file extension and descriptions
        filterSpec{end+1,1} = thisExtensionString; %#ok<AGROW>
        filterSpec{end,2} = desc{i};
        
    end
    
end


