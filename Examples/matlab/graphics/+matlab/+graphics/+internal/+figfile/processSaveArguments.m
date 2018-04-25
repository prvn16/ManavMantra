function [hArg, filenameArg,saveCompactArg] = processSaveArguments(Input1, Input2,Input3)
%processSaveArguments Split and check handle/filename argument pair
%
%  [Handle, Filename] = processSaveArguments(input) checks its input
%  argument for being either a valid handle to save or a valid filename to
%  save to.
%
%  [Handle, Filename] = processSaveArguments(input1, input2) checks that
%  input1 is a valid handle and input2 is a valid filename.
%
%  Each of the outputs is a structure containing three fields: Value,
%  Specified and Valid. Inputs that are correct are returned in the Value
%  field of the appropriate output.  Any output that does not have a
%  specified input will contain the default value to use for that input.
%  The Specified field is a logical that is set to true if the Value was an
%  input and false if the Value contains a default value.  The Valid field
%  is a logical that is true if the Value field contains a valid value, and
%  false otherwise.

%  Copyright 2012-2017 The MathWorks, Inc.

import matlab.graphics.internal.isCharOrString;

hArg = struct('Value', [], 'Specified', false, 'Valid', true);
filenameArg = struct('Value', 'Untitled.fig', 'Specified', false, 'Valid', true);
saveCompactArg = struct('Value',false,'Specified',false,'Valid', true);

if nargin == 3 
   % Assume (H,FILENAME,COMPACT) 
    hArg.Value = Input1;
    hArg.Specified = true;
    filenameArg.Value = Input2;
    filenameArg.Specified = true;    
    saveCompactArg.Value = Input3;
    saveCompactArg.Specified = true ;
elseif nargin==2
    % Assume (H, FILENAME)
    hArg.Value = Input1;
    hArg.Specified = true;
    filenameArg.Value = Input2;
    filenameArg.Specified = true;
elseif nargin==1
    % Need to work out whether the single argument is handles or a
    % filename.
    if isCharOrString(Input1)
        filenameArg.Value = Input1;
        filenameArg.Specified = true;
    else
        hArg.Value = Input1;
        hArg.Specified = true;
    end
end
% isempty returns 0 for "", hence typecasting it to char
if filenameArg.Specified
    if isstring(filenameArg.Value) && isscalar(filenameArg.Value)
        filenameArg.Value = char(filenameArg.Value);
    end
    filenameArg.Valid = ( ~isempty(filenameArg.Value) && isCharOrString(filenameArg.Value) );
    if filenameArg.Valid
        % Add an implicit ".fig" to the filename if no extension is specified
        [path, file, ext] = fileparts(filenameArg.Value);
        
        % fileparts returns everything from the last . to the end of the
        % string as the extension so the following test will catch
        % an extension with 0, 1, or infinity dots.
        % for example, all these filenames will have .fig added to the end:
        %  foo.
        %  foo..
        %  foo.bar.
        %  foo.bar...
        if isempty(ext) || strcmp(ext, '.')
            filenameArg.Value = fullfile(path, [file , ext, '.fig']);
        end
    end
end

if saveCompactArg.Specified
    saveCompactArg.Valid = ( ~isempty(saveCompactArg.Value) && isCharOrString(saveCompactArg.Value) );
    if saveCompactArg.Valid
        % only accepts all lower case compace
           switch saveCompactArg.Value
              case 'compact'
               saveCompactArg.Value = true ;
              otherwise
               saveCompactArg.Valid = false ;
            end
    end
end



if hArg.Specified
    hArg.Valid = localIsValidHGArray(hArg.Value(:));
elseif filenameArg.Valid
    % Get the default value for the figure to use.  We only do this if the
    % filename is valid so that we don't create a figure unnecessarily.
    hArg.Value = gcf;
end



function isHG = localIsValidHGArray(hndls)

% Initial test to check that the value contains a datatype that could
% possibly be an HG handle
isHG = isa(hndls, 'double') || isobject(hndls) || isa(hndls, 'handle.handle');
if ~isHG
    return
end

% Check whether a matrix contains HG handles
try %#ok<TRYNC>
    % Convert doubles to objects
    hndls = handle(hndls);
end

if isobject(hndls)
    isHG = isa(hndls, 'matlab.graphics.Graphics') && all(isvalid(hndls));
else
    isHG = all(ishghandle(hndls));
end
