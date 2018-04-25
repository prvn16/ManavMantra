classdef ftp < handle
%FTP Create an FTP object.
%   FTP(host,username,password) returns an FTP object.  If only a host is
%   specified, it defaults to "anonymous" login.
%
%   An alternate port can be specified by separating it from the host name
%   with a colon.  For example: ftp('ftp.mathworks.com:34')
%   Our FTP implementation uses code from the Apache Jakarta Project.

%   Copyright (c) 1984-2017 The MathWorks, Inc.

    properties(GetAccess='protected', SetAccess='private')
        jobject
        host char
        port double
        username char
        password char
        remotePwd
        type
    end

    properties(Hidden, GetAccess='protected', SetAccess='private')
        % property to close FTP server connection when object is destroyed
        cleaner
    end

    methods
        function h = ftp(host,username,password,varargin)
            if ~usejava('jvm')
                error(message('MATLAB:ftp:Java'))
            end

            % Short-circuit cases.
            if isa(host,'ftp')
                % If given an FTP object, give it back.
                h = host;
                return
            end

            % Argument parsing
            if (nargin < 1)
                error(message('MATLAB:ftp:IncorrectArgumentCount'))
            end
            if (nargin < 2)
                username = 'anonymous';
            end
            if (nargin < 3)
                password = 'anonymous@example.com';
            end
            options = parseInputs(varargin);

            % Immutable fields.
            h.jobject = org.apache.commons.net.ftp.FTPClient;
            host = ensureChar(host);
            colon = find(host==':');
            if isempty(colon)
                h.host = host;
                h.port = 21;
            else
                h.host = host(1:colon-1);
                h.port = str2double(host(colon+1:end));
            end
            h.username = username;
            h.password = password;

            % close the connection when the FTP object is destroyed
            h.cleaner = onCleanup(@()close(h));

            % Mutable fields. Use StringBuffers so these will act as references.
            h.remotePwd = java.lang.StringBuffer('');
            h.type = java.lang.StringBuffer('binary');

            configureFtpClient(h.jobject,options);

            % Connect.
            connect(h);
        end

        % Delete function for FTP
        delete(h, filename);
    end
end

function options = parseInputs(args)
% Argument parsing
p = inputParser;
validationFcn = @(x) ischar(x) || isstring(x);
p.addParameter('System','',validationFcn)
p.addParameter('LenientFutureDates',[],@islogical)
p.addParameter('DefaultDateFormatStr','',validationFcn)
p.addParameter('RecentDateFormatStr','',validationFcn)
p.addParameter('ServerLanguageCode','',validationFcn)
p.addParameter('ServerTimeZoneId','',validationFcn)
p.addParameter('ShortMonthNames','',validationFcn)
p.parse(args{:})
options = p.Results;
end

function configureFtpClient(jobject,options)
import org.apache.commons.net.ftp.FTPClientConfig
if any(structfun(@(x)~isempty(x),options))
    % check whether the System property was specified via the call to FTP.
    if isempty(options.System)
        % use the default value
        system = 'UNIX';
    else
        system = upper(options.System);
    end
    conf = FTPClientConfig(strcat('SYST_', system));

    % set other properties that were specified
    options = rmfield(options,'System');
    fields = fieldnames(options);
    for iFields = 1:numel(fields)
        field = fields{iFields};
        if ~isempty(options.(field))
            javaMethod(['set' field],conf,options.(field))
        end
    end
else
    % calling the default constructor which uses SYST_UNIX
    conf = FTPClientConfig();
end
jobject.configure(conf);
end