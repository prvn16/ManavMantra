function data = ...
    readContentFromFile(filename, charset, simpleType, subtype)
%readContentFromFile Read content from file
%
%   data = readContentFromFile(FILENAME, charset, simpleType, subtype) reads the
%   content from FILENAME, using a reader selected by the values from simpleType,
%   possibly supplying subtype as an additional parameter.
%
%   charSet is applied when simpleType is 'text' or 'table' with subtype 'csv'.  It may be ''.
%
%   The data return argument may be a cell array of values if the content reader
%   returns more than one output argument (e.g., imread).  The cell array trims empty
%   trailing cells.
%
%   May throw any possible MATLAB exception on a conversion error.

% Copyright 2015-2016 The MathWorks, Inc.

    % Determine reader from content type.
    reader = contentTypeReader(charset, simpleType, subtype);

    try
        % Read data from file.  The reader may have more than one output argument, so
        % fetch them all.  If it accepts more than one input argument, give it the
        % subtype as the 2nd one.  
        if nargout(reader) > 1
            if nargin(reader) ~= 1
                % 2 inputs, multiple outputs
                [res{1:nargout(reader)}] = reader(filename, char(subtype));
            else
                % 1 input, multiple outputs
                [res{1:nargout(reader)}] = reader(filename);
            end
            % find last nonempty argument returned by reader
            lastFilled = length(res) - find(cellfun(@(x)~isempty(x), fliplr(res)), 1) + 1;
            if isempty(lastFilled) 
                data = [];
            elseif lastFilled == 1
                % if just one return value, return it directly
                data = res{1};
            else
                % if multiple return values, return cell array
                data = res(1:lastFilled);
            end
        elseif nargin(reader) ~= 1
            % 2 inputs, 1 output
            data = reader(filename, char(subtype));
        else
            % 1 input, 1 output
            data = reader(filename);
        end
    catch e
        % In case the reader fails to close filename on error, go through open files
        % to find filename and close it, as this is a temp file which our caller will
        % want to delete.
        fids = fopen('all');
        fid = fids(strcmp(filename, arrayfun(@fopen, fids, 'UniformOutput', false)));
        if ~isempty(fid) 
            try
                fclose(fid(end));
            catch
            end
        end
        rethrow(e);
    end
end
       
%--------------------------------------------------------------------------

function reader = contentTypeReader(charset, simpleType, ~)
% Determine the reader function handle based on the simpleType. 
% If the reader function takes more than 1 input argument, the 2nd argument
% must be the subtype.

    % Determine reader based on simpleType
    switch simpleType
        case 'image'
            reader = @imread;
        case 'table'
            reader = @tablereader;
        case 'audio'
            reader = @audioreader;
        case 'xmldom'
            % Redefine so we only take 1 argument.  xmlread has an undocumented second
            % argument which is not the subtype.
            reader = @xmlreader;
        case 'text'
            reader = @(x) fileread(x, '*char', charset);
        otherwise
            % This line should never be reached, but read as binary in any case.
            charset = '';
            reader = @(x) fileread(x, 'uint8=>uint8', charset);
    end
    
    % define audioreader function that calls audioread without a 2nd argument
    function [y, Fs] = audioreader(file)
        % Ignore the subtype, because the subtype was used to generate the suffix of
        % the file name that tells audioread what file type it is.
        [y, Fs] = audioread(file);
    end

    % define tablereader to take 2 arguments, file and subtype
    function tbl = tablereader(file, subtype)
        % The simpleType of 'table' as computed by
        % readContentFromWebService.getSimpleType() happens only for text/csv,
        % text/comma-separated-values and application/*spreadsheet*; otherwise we
        % wouldn't try table conversion.
        switch subtype
            case {'csv', 'comma-separated-values'}
                type = 'text';
                if isempty(charset)
                    charset = 'US-ASCII';
                end
            otherwise
                type = 'spreadsheet';
        end
        if ~isempty(charset)
            tbl = tableread(file, 'FileType', type, 'FileEncoding', char(charset));
        else
            tbl = tableread(file, 'FileType', type);
        end
    end

    function data = xmlreader(file) %#ok<STOUT,INUSD> buried in evalc
        % xmlread writes to console on an error, which we don't want to see (since it
        % also throws an exception that we are prepared to handle), so to suppress
        % this output, gobble it up in evalc.
        evalc('data = xmlread(file);');
    end
end

%--------------------------------------------------------------------------

function data = fileread(filename, precision, charset)
% Read the file with a given precision and charset. Return a row vector.

    if isempty(charset)
        fid = fopen(filename, 'r');
    else
        fid = fopen(filename, 'r', 'native', charset);
    end

    data = fread(fid, precision)';
    fclose(fid);
end

%--------------------------------------------------------------------------

function data = tableread(filename, varargin)
% Read a spreadsheet or CSV file using readtable. 

    % Some files do not have valid entries for the variable names. For example,
    % a name may contain a space (' ') character. For that case,
    % ReadVariableNames needs to be false. For others, the entries are correct
    % and the variable names should be read.

    % Turn off the ModifiedAndSavedVarnames warning.
    wstate = warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
    wobj = onCleanup(@() warning(wstate));

    try
        data = readtable(filename, varargin{:});
    catch 
        % An error occured. Try setting ReadVariableNames to false.
        data = readtable(filename, 'ReadVariableNames', false, varargin{:});
    end
end
