function strm = createStream(pth, mode, encoding)
%createStream Create a stream for reading from a path or IRI
%   stream = createStream(PATH) creates a stream that can be
%   used for reading. The stream returned is in binary mode.
%
%   PATH must be a fully qualified path or full path for local files, like
%   the output of pathLookupLocal, pathLookupIRI.
%
%   stream = createStream(PATH, MODE) creates a stream in the
%   specified mode. Allowed values are:
%       * 'r'/'rb'   : Binary read mode
%       * 'w'/'wb'   : Binary write mode
%       * 'rw'/'rwb' : Binary read/write mode.
%       * 'rt'       : Text read mode
%       * 'wt'       : Text write mode
%       * 'rwt'      : Text read/write mode
%
%   stream = createStream(PATH, MODE, ENCODING) creates a stream in the
%   specified mode, and encoding. The mode argument must contain the 't'
%   suffix as encoding only applies to text mode streams.
%

%   Copyright 2015-2016, The MathWorks, Inc.
    
    import matlab.io.internal.validators.isString;
    narginchk(1,3);
    
    if ~isString(pth)
        error(message('MATLAB:datastoreio:stream:inputMustBeString', 'path'));
    end
    
    if nargin == 2 && ~isString(mode)
        error(message('MATLAB:datastoreio:stream:inputMustBeString', 'mode'));
    end
    
    if nargin == 3 && ~isString(encoding)
        error(message('MATLAB:datastoreio:stream:inputMustBeString', 'encoding'));
    end
    
    isTextMode = false;
    if nargin < 2
        mode = 'r';
    end
    
    switch mode
        case {'r','rb'}
            mode = 'r';
        case {'w','wb'}
            mode = 'w';
        case {'rw','rwb'}
            mode = 'rw';
        case 'rt'
            mode = 'r';
            isTextMode = true;
        case 'wt'
            mode = 'w';
            isTextMode = true;
        case 'rwt'
            mode = 'rw';
            isTextMode = true;
        otherwise
            error(message('MATLAB:datastoreio:stream:invalidStreamMode',mode));
    end
    
    if ~isTextMode && (nargin == 3)
        error(message('MATLAB:datastoreio:stream:encodingWithBinary'));
    end
    
    if isTextMode && (nargin == 2)
        encoding = 'UTF-8';
    end

    if isTextMode
        strm = matlab.io.datastore.internal.filesys.TextStream(pth, mode, encoding);
    else
        strm = matlab.io.datastore.internal.filesys.BinaryStream(pth, mode);
    end
end
