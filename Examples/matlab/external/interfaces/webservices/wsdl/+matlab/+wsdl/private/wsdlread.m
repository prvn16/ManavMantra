function [rpath, istemp] = wsdlread(url,webOptions)
%wsdlread Read a WSDL document into a file
%
%   [RPATH, ISTEMP] = WSDLREAD(URL,WEBOPTIONS) reads the WSDL from URL.  
%
%   URL may be a file path or web address.  Currently file:// protocol not supported.
%
%   WEBOPTIONS is either empty or a weboptions structure to be passed into webread.
%   Ignored if URL is a local file.
%
%   RPATH full path of a local file containing the contents of the URL.  If url is a
%   local file, this may be the full path of that file; otherwise it is a temporary
%   file.
%
%   ISTEMP is true if RPATH is a temporary file.  Caller should delete RPATH when
%   no longer needed.

protocols = {'http://', 'https://'};
index = find(url == ':', 1);
protocol = url(1:index + min(length(url)-index, 2));

if any(strcmp(protocol, protocols))
    if isempty(webOptions)
        rpath = websave(tempname,url);
    else
        rpath = websave(tempname,url,webOptions);
    end
    istemp = true;
else
    if strcmp(protocol, 'file://')
        error(message('MATLAB:webservices:FileProtocolNotAccepted'));
    end
    % URL points to a local file.
    %{
    % Make it into a plain pathame with forward slashes
    url(url == '\') = '/'; 
    fileProtocol = 'file://';
    if strcmp(fileProtocol, protocol) && length(url) > length(fileProtocol)
        fpath = url(length(fileProtocol)+1:end); % strip 'file://'
        if ispc
            % on Windows, convert file:///C:/foo/bar to C:/foob/bar and
            % file://host/foo/bar to //host/foo/bar
            if fpath(1) == '/'  % if another '/', assume it's a local file path
                fpath = fpath(2:end);
            else                % otherwise make it a UNC path
                fpath = ['//' fpath]; 
            end
        else
            if fpath(1) ~= '/' 
                fpath = ['//' fpath];
            end
        end
    else
        % not file or http protocol, so leave unchanged
        fpath = url;
    end
    %}
    if ispc && (strcmp(url(1:2),'//') || strcmp(url(1:2), '\\'))
        % if UNC path, copy to temp file because wsdl2java won't accept UNC path
        rpath = tempname;
        copyfile(url,rpath);
        istemp = true;
    else
        % If local non-UNC path, just return absolute path
        if java.io.File(url).isAbsolute
            rpath = url;
        else
            rpath = fullfile(pwd,url);
        end
        istemp = false;
    end
end
    
        
    