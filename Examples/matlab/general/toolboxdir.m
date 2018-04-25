function s=toolboxdir(tbxdirname)
% TOOLBOXDIR Root folder for specified toolbox
%    S=TOOLBOXDIR(TBXDIRNAME) returns a character vector that is the absolute
%    path to the specified toolbox folder name, TBXDIRNAME
%
%    TOOLBOXDIR is particularly useful for MATLAB Compiler. The base
%    folder of all toolboxes installed with MATLAB is
%    <matlabroot>/toolbox/<tbxdirname>. However, in deployed mode, the base
%    folders of the toolboxes are different. TOOLBOXDIR returns the
%    correct root folder irrespective of the mode in which the code is
%    running. Note that TOOLBOXDIR lowercases any input path that matches
%    a path in the MCR modulo case. It preserves the case of input paths
%    that do not - i.e. those that lie in the CTF.
%
%    See also MATLABROOT, COMPILER/CTFROOT.

%    Copyright 1984-2017 The MathWorks, Inc.

narginchk(1,1)
tbxdirname = convertStringsToChars(tbxdirname);

if isdeployed
    % In deployed mode, lower cases tbx name if it is in MCR.
    % Check if the tbx directory exists in MCR first.
    s = fullfile(tbxprefix, lower(tbxdirname));
    if (exist(s, 'dir') == 7)
        return;
    end
    
    % In deployed mode, don't lower case tbx name if it is in CTF.
    s = fullfile(ctfroot, 'toolbox', tbxdirname);
    if (exist(s, 'dir') == 7)
        return;
    end
else
    % In desktop mode, case is not changed.
    s = fullfile(tbxprefix, tbxdirname);
    if (exist(s, 'dir') == 7)
        return;
    end
end

% The tbx directory does not exist, if it reaches here.
error(message('MATLAB:toolboxdir:DirectoryNotFound', tbxdirname));
