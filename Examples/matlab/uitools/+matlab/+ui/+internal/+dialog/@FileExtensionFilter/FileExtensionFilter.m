classdef FileExtensionFilter < handle
    % This function is undocumented and will change in a future release.
    
% Copyright 2006-2011 The MathWorks, Inc.
    properties (SetAccess='private', GetAccess='private')
        peer = {};
    end
    
    properties
        extension = '*.*';
        description = getString(message('MATLAB:uistring:filedialogs:AllFilesDescription'));
    end
    
    properties (Constant = true)
        ACCEPT_ALL_DESCRIPTION = getString(message('MATLAB:uistring:filedialogs:AllFilesDescription'));
        ACCEPT_ALL_EXTENSION = '*.*';
    end
    
    methods
        
        function obj = FileExtensionFilter(varargin)
        if (nargin > 1)
            %We have property value pairs that we need to use to
            %populate the fields of this class.
            if rem(length(varargin), 2) ~= 0
                error(message('MATLAB:FileExtensionFilter:UnpairedParamsValues'));
            end
            for i = 1:2:length(varargin)
                if ~ischar(varargin{i})
                    error (message('MATLAB:FileExtensionFilter:IllegalParameterType', i));
                end
                fieldname = varargin{i};
                switch fieldname
                    case {'extension','description'}
                        obj.(fieldname) = varargin{i+1};
                    otherwise
                        error(message('MATLAB:FileExtensionFilter:IllegalParameter', varargin{ i }));
                end
            end
            %Peer has a description and an extension and so we
            %would like to suppress showing the extension with the
            %description.
            obj.peer{1} = com.mathworks.mwswing.FileExtensionFilter(obj.description, obj.extension , false, true);
        elseif ((nargin == 1) & ~strcmp(varargin{1},''))
            %We are here because user did not specify property
            %value pairs. The user is trying to construct the
            %object using a filter(cell array of filters or a
            %string). uigetfile/uiputfile will get channelised
            %through this.
            filterlist = varargin{1};
            if ischar(varargin{1})
                %A simple string filter extension like '*.abc'
                % '*.abc' --->convertTo---> cell array {'*.abc'}
                filterlist = varargin(1);
            end
            if (size(filterlist,2)==2)
                %We have a set of filters with descriptions and
                %extensions. No 'All files' filter addition here
                for i=1:size(filterlist,1)
                    filterext = returnFilterExtension(obj,filterlist{i,1});
                    filterdesc = filterlist{i,2};
                    obj.peer{i} = com.mathworks.mwswing.FileExtensionFilter(filterdesc,filterext,false,true);
                end
            elseif (size(filterlist,2)==1)
                %We have a set of filters with only extensions and
                %no description. We add an 'All files' filter. We
                %also check if the extension is one of our MATLAB
                %related extensions and provide descriptions for
                %those filters alone
                for i=1:size(filterlist,1)
                    filterext = returnFilterExtension(obj,filterlist{i,1});
                    filterdesc = getDescIfMATLABFilters(obj,filterlist{i,1}) ;
                    obj.peer{i} = com.mathworks.mwswing.FileExtensionFilter(filterdesc,filterext,false,true);
                end
            else
                %We have an incorrect filter specification
                error(message('MATLAB:FileExtensionFilter:IllegalFilterSpecification'));
            end
            
        else
            % Get a List of the available FileExtensionFilters.
            % FileExtensionFilterUtils.getFileExtensionFilters returns
            % a java List based on which products are installed.
            filters = com.mathworks.mwswing.FileExtensionFilterUtils.getFileExtensionFilters();
            
            %Peer is the set of all static default filters that we get
            %from the java class
            %com.mathworks.mwswing.FileExtensionFilter
            for i = 1:filters.size()
                obj.peer{i} =  filters.get(i-1);
            end
            %We have to explicitly add 'All Files' filter
            obj.peer{i+1} = com.mathworks.mwswing.FileExtensionFilter(obj.ACCEPT_ALL_DESCRIPTION,obj.ACCEPT_ALL_EXTENSION, false, true);
        end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % The updated set of java peers is returned by
        % the following method to add to a file dialog
        % java peer(com.mathworks.mwswing.MJFCPP)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function fileextensionfilters = getPeer(obj)
        fileextensionfilters = obj.peer;
        end
        
    end
    
    
    methods(Access = 'private')
        
        function filterext = returnFilterExtension(obj,v)
        %Given a matlab compound filter, '*.abc;*.exe' ---> convertTo----> {'*.abc';'*.exe'}
        %using semicolon as a delimiter.
        %Given a simple filter, '*.abc' --->convertTo--->{'*.abc'}
        compoundCell = textscan(v,'%s', length(strfind(v,';'))+1, 'delimiter', ';');
        filterext = compoundCell{1};
        end
        
        
        function filterdesc = getDescIfMATLABFilters(obj,v)
        %If filter description is not provided for the MATLAB
        %associated filters like '*.m','*.all','*.mat','*.fig' etc..
        %we try to give the description.
        
        persistent filterList;
        if isempty (filterList)
            % Get a List of the availble FileExtensionFilters.
            % FileExtensionFilterUtils.getFileExtensionFilters returns
            % a java List based on which products are installed.
            filters = com.mathworks.mwswing.FileExtensionFilterUtils.getFileExtensionFilters();
            for j = 1:filters.size()
                filterList{j} =  filters.get(j-1);
            end
        end
        
        % Handle *.all special case.
        % The sorted list returned by FileExtensionFilter should have the first
        % entry for "All MATLAB Files"
        if(strcmp(v,'*.all'))
            filterdesc = char(filterList{1}.getDescription());
            return
        end
        
        
        % Handle '*.*' extension
        if strcmp(v,'*.*')
            filterdesc = char(com.mathworks.mwswing.FileExtensionFilter(obj.ACCEPT_ALL_DESCRIPTION,obj.ACCEPT_ALL_EXTENSION, false,true).getDescription());
            return
        end
        
        
        % Handle all other available extensions
        for j = 2:length(filterList)
            pat = filterList{j}.getPatterns();
            if (length(pat) == 1) && strcmp(v, char(pat(1)))
                filterdesc = char(filterList{j}.getDescription());
                return
            end
        end
        
        % otherwise just get a description for whatever extension is given       
        filterdesc = char(com.mathworks.mwswing.FileExtensionFilter('', returnFilterExtension(obj,v), true, true).getDescription());
        end
        
    end
end







