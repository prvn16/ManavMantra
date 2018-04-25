function docsearch(varargin)
% Shadowed docsearch for MATLAB online. 
% docsearch in MATLAB currently shows doc page only for one topic, the last topic passed i.e 
% docsearch plot plottools shows doc for only plottools.

for i = 1:length(varargin)
    argName = strtrim(varargin{i});

    if strcmp(argName, '-classic')
         error(message('MATLAB:connector:Platform:FunctionArgumentsNotSupported', mfilename, argName));
    end
end

searchStr = deblank(sprintf('%s ', varargin{:})); 

% Construct url to be sent to client
if ~isempty(searchStr)
	help_url = ['//www.mathworks.com/help/matlab-web/search.html', '?qdoc=', urlencode(searchStr)];
else
	help_url = '//www.mathworks.com/help/matlab-web/index.html';
end
import com.mathworks.messageservice.*;
service = MessageServiceFactory.getMessageService;
service.publish('/web/doc', help_url); %publish the doc help-url%

clear help_url searchStr;

end