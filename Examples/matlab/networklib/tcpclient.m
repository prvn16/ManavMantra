classdef (Sealed) tcpclient < matlab.mixin.SetGet
%TCPCLIENT Create TCP/IP client object
%
%   OBJ = TCPCLIENT('ADDRESS', PORT) constructs a TCP/IP object, OBJ,
%   associated with remote host, ADDRESS, and remote port value, PORT.
%
%   If an invalid argument is specified or the connection to the server
%   cannot be established, then the object will not be created.
%    
%   OBJ = TCPCLIENT('ADDRESS', PORT, 'P1',V1,'P2',V2,...) construct a
%   TCPCLIENT object with the specified property values. If an invalid property
%   name or property value is specified the object will not be created.
%   
%   A property value pair of 'ConnectTimeout', TIMEOUT, will cause the
%   object to wait for a maximum of TIMEOUT seconds for a response to the
%   connection request sent to the remote host. If the connection 
%   does not succeed or fail within the specified time a timeout error will
%   occur and the object will not be created. If 'ConnectTimeout' is not  
%   specified the object will wait for the connection to either succeed or 
%   fail before returning.
%
%    TCPCLIENT methods:
%
%    read - Reads data from the remote host.
%    write - Writes data to the remote host.
%
%    TCPCLIENT properties:    
%
%    Address - Specifies the remote host name or IP address.
%    Port - Specifies the remote host port for connection.
%    Timeout - Specifies the waiting time to complete read and write operations.
%    BytesAvailable - Specifies the number of bytes available in the input buffer.
%    ConnectTimeout - Specifies the maximum time (in seconds) to wait for
%                     a connection request to the specified remote host to succeed
%                     or fail. Value must be greater than or equal to 1. If
%                     not specified, default value of ConnectionTimeout is
%                     inf.
%
%   Example:
%       % Assume there is an echo server at port 4012.
%       % Construct a TCPClient object.
%       t = tcpclient('localhost', 4012);
%
%       % Write double data to the host.
%       write(t, 1:10);
%
%       % Read data from the host.
%       data = read(t, 10, 'double');

%   Copyright 2014-2016 The MathWorks, Inc

    properties (GetAccess = public, SetAccess = private, Dependent)
        % Address - Specifies the remote host name or IP address.
        Address

        % Port - Specifies the remote host port for connection.
        Port
    end

    properties (Access = public, Dependent)
        % Timeout - Specifies the waiting time (in seconds) to complete
        %   read and write operations.
        Timeout        
    end

    properties (GetAccess = public, SetAccess = private, Dependent)
        % BytesAvailable - Specifies the number of bytes available in the
        %   input buffer.
        BytesAvailable
        
        % ConnectTimeout - Specifies the maximum time (in seconds) to 
        %   wait for a connection request to the specified remote host to succeed
        %   or fail. Value must be greater than or equal to 1. If not
        %   specified, default value of ConnectionTimeout is inf.
        ConnectTimeout
    end

    properties (Hidden, Access = private)
        TCPClientObj
    end

    % Getters/Setters
    methods
        function value = get.Address(obj)
            value = obj.TCPClientObj.RemoteHost;
        end

        function value = get.Port(obj)
            value = obj.TCPClientObj.RemotePort;
        end

        function value = get.BytesAvailable(obj)
            value = obj.TCPClientObj.BytesAvailable;
        end

        function value = get.Timeout(obj)
            value = obj.TCPClientObj.Timeout;
        end

        function set.Timeout(obj, value)
            try
                obj.TCPClientObj.Timeout = value;
            catch ex
                throwAsCaller(ex);
            end
        end
        
        function value = get.ConnectTimeout(obj)
            value = obj.TCPClientObj.ConnectTimeout;
        end

        function set.ConnectTimeout(obj, value)
            try
                obj.TCPClientObj.ConnectTimeout = value;
            catch ex
                throwAsCaller(ex);
            end
        end        
    end

    methods (Access = public)
        function obj = tcpclient(address, port, varargin)
        %TCPCLIENT Constructs TCP/IP client object.
        %
        %   OBJ = TCPCLIENT('ADDRESS',  PORT) constructs a
        %   TCPClient object, OBJ, associated with remote host, ADDRESS,
        %   and remote port value, PORT.
        %
        % Inputs:
        %   ADDRESS specifies the remote host name or IP dotted decimal
        %   address. An example of dotted decimal address is
        %   144.212.100.10.
        %
        %   PORT specifies the remote host port for connection. Port
        %   number should be between 1 and 65535.
        
        % convert to char in order to accept string datatype
        address = instrument.internal.stringConversionHelpers.str2char(address);
        varargin = instrument.internal.stringConversionHelpers.str2char(varargin);
        
            try
                validateattributes(address, {'char'}, {'nonempty'}, 'tcpclient', 'ADDRESS', 1);

                validateattributes(port, {'numeric'}, {'>=', 1, '<=', 65535, 'scalar'}, 'tcpclient', 'PORT', 2);

                obj.TCPClientObj = matlabshared.network.internal.TCPClient(address, port);
                
                % Validate the N-V pairs
                if mod(numel(varargin), 2)
                    error(message('MATLAB:networklib:tcpclient:unmatchedPVPairs'));
                end

                % Set name-value pairs if provided.
                if (~isempty(varargin))
                    
                    % Parse the n-v pairs
                    p = inputParser;
                    p.PartialMatching = true;
                    
                    % Detailed parameter validation will be done by TCPClient when
                    % assigned below.
                    addParameter(p, 'Timeout',obj.TCPClientObj.DefaultTimeout,@isnumeric);
                    addParameter(p, 'ConnectTimeout',obj.TCPClientObj.DefaultConnectTimeout, @isnumeric);

                    parse(p, varargin{:});
                    output = p.Results;
                       
                    obj.Timeout = output.Timeout;
                    obj.ConnectTimeout = output.ConnectTimeout;
                end
               
                connect(obj.TCPClientObj);
                
            catch creationException
                % Replace '\' with '\\' if the error message contains anys
                % path information.
                formattedMessage = strrep(creationException.message, '\', '\\');
                throwAsCaller(MException('MATLAB:networklib:tcpclient:cannotCreateObject', ...
                    formattedMessage));
            end
        end
        
        function data = read(obj, varargin)
        %READ Reads data from the remote host.
        %
        %   DATA = READ(OBJ) reads values from the tcpclient object
        %   connected to the remote host, OBJ, and returns to DATA. The
        %   number of values read is given by the BytesAvailable property.
        %
        %   DATA = READ(OBJ, SIZE) reads the specified number of values,
        %   SIZE, from the tcpclient object connected to the remote host,
        %   OBJ, and returns to DATA.
        %
        %   DATA = READ(OBJ, SIZE, DATATYPE) reads the specified
        %   number of values, SIZE, with the specified precision,
        %   DATATYPE, from the tcpclient object connected to the
        %   remote host, OBJ, and returns to DATA.
        %
        % Inputs:
        %   SIZE indicates the number of items to read. SIZE cannot be
        %   set to INF. If SIZE is greater than the OBJ's
        %   BytesAvailable property, then this function will wait until
        %   the specified amount of data is read.
        %
        %   DATATYPE indicates the number of bits read for each value
        %   and the interpretation of those bits as a MATLAB data type.
        %   DATATYPE must be one of 'UINT8', 'INT8', 'UINT16',
        %   'INT16', 'UINT32', 'INT32', 'UINT64', 'INT64', 'SINGLE',
        %   or 'DOUBLE'.
        %
        % Outputs:
        %   DATA is a 1xN matrix of numeric data. If no data was returned
        %   this will be an empty array.
        %
        % Notes:
        %   READ will wait until the requested number of values are
        %   read from the remote host.

            numValuesToRead = obj.BytesAvailable;
            dataType = 'uint8';

            % convert to char in order to accept string datatype
            varargin = instrument.internal.stringConversionHelpers.str2char(varargin);
        
            switch nargin
              case 2
                numValuesToRead = varargin{1};
              case 3
                numValuesToRead = varargin{1};
                dataType = varargin{2};
            end

            try
                data = receive(obj.TCPClientObj, numValuesToRead, dataType);
            catch receiveException
                if (strcmpi(receiveException.identifier, 'network:tcpclient:invalidConnectionState'))
                    delete(obj);
                    throwAsCaller(MException('MATLAB:networklib:tcpclient:connectTerminated', ...
                        message('MATLAB:networklib:tcpclient:connectTerminated').getString()));
                else
                    throwAsCaller(MException('MATLAB:networklib:tcpclient:readFailed', ...
                        receiveException.message));
                end
            end
        end

        function write(obj, data)
        %WRITE Writes data to the remote host.
        %
        %   WRITE(OBJ, DATA) sends the N dimensional matrix of data to
        %   the remote host.
        %
        % Inputs:
        %   DATA an 1xN matrix of numeric data.
        %
        % Notes:
        %   WRITE will wait until the requested number of values are
        %   written to the remote host.

        
            try
                validateattributes(data, {'numeric'}, {'nonempty'}, 'write', 'DATA', 2);
                
                send(obj.TCPClientObj, data);
            catch sendException
                if (strcmpi(sendException.identifier, 'network:tcpclient:invalidConnectionState'))
                    delete(obj);
                    throwAsCaller(MException('MATLAB:networklib:tcpclient:connectTerminated', ...
                        message('MATLAB:networklib:tcpclient:connectTerminated').getString()));
                else                    
                    throwAsCaller(MException('MATLAB:networklib:tcpclient:writeFailed', ...
                        sendException.message));
                end
            end
        end
    end

    methods (Static = true, Hidden = true)
        function out = loadobj(s)
            %LOADOBJ Creates and returns a new TCPClient using the deserialized
            % data passed in. 

            % Initialize return value to empty
            out = [];
            if isstruct(s)
                if isfield(s, 'ConnectTimeout')
                    out = tcpclient(s.RemoteHost, s.RemotePort, 'ConnectTimeout', s.ConnectTimeout);
                else
                    out = tcpclient(s.RemoteHost, s.RemotePort);
                end
                out.Timeout = s.Timeout;
            end
        end
    end    
    
    % Hidden methods from the hgsetget super class.
    methods (Hidden)
        
        function s = saveobj(obj)
        %SAVEOBJ Returns values to serialize for this object
            s.RemoteHost = obj.Address;
            s.RemotePort = obj.Port;
            s.Timeout    = obj.Timeout;
            s.ConnectTimeout = obj.ConnectTimeout;
        end        
        
        function setdisp(obj, varargin)
            setdisp@matlab.mixin.SetGet(obj, varargin{:});
        end

        function getdisp(obj, varargin)
            getdisp@matlab.mixin.SetGet(obj, varargin{:});
        end
    end
end
