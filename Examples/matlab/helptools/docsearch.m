function docsearch(varargin)
%DOCSEARCH Help browser search.
%
%   DOCSEARCH opens the Help browser and displays the documentation home
%   page. If the Help browser is already open, but not visible, then
%   docsearch brings it to the foreground.
%
%   DOCSEARCH TEXT searches the documentation for pages with words that match 
%   the specified expression. To search third-party or custom documentation, 
%   you must first run the BUILDDOCSEARCHDB command to build a search database  
%   for the additional help files.
%
%   Examples:
%      docsearch plot
%      docsearch plot tools
%      docsearch('plot tools')
%
%   See also DOC.

%   Copyright 1984-2012 The MathWorks, Inc. 

if ~usejava('mwt')
	error(message('MATLAB:helpbrowser:UnsupportedPlatform'));
end

if nargin > 1
    text = deblank(sprintf('%s ', varargin{:}));    
elseif nargin == 1
    text = char(varargin{1});
else
    text = '';
end

com.mathworks.mlservices.MLHelpServices.docSearch(text);
