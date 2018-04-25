function docContent = retrieveDocCenterPropertiesContent(searchTerms)
% retrieves Doc Center property page content for a given search Term as a
% struct of the search term and the Doc Center property descriptions.

%   Copyright 2016 The MathWorks, Inc.

% searchTerms is a character vertor of a single term to search for. if it
% is a character vector convert it to a cell array
if(~iscell(searchTerms))
    searchTerms = {searchTerms};
end

% create a retriever to extract content
baseRetriever = com.mathworks.mlwidgets.help.DocCenterReferenceRetrievalStrategy.createDataRetriever;
% create a grouped retriever to extract grouped content
groupRetriever = com.mathworks.helpsearch.reference.GroupedReferenceDataRetriever(baseRetriever);

% search for properties page
propertyType = com.mathworks.helpsearch.reference.RefEntityType.PROPERTY;

docContent(length(searchTerms)) = struct('SearchTerm', '', 'Properties', []);

for i = 1:length(searchTerms)
    docContent(i).SearchTerm = searchTerms{i};
    groupsToQuery = queryDocCenterForProperties(searchTerms{i}, groupRetriever, propertyType);
    docContent(i).Properties = getComponentProperties(searchTerms{i}, groupsToQuery);
end
baseRetriever.close()
groupRetriever.close()
end

function groupsToQuery = queryDocCenterForProperties(searchTerm, groupRetriever, propertyType)

% get a request to search Doc Center
request = com.mathworks.helpsearch.reference.ClassEntityListRequest(searchTerm, propertyType);

% handle doc content that is grouped
grouped = groupRetriever.getReferenceData(request);

groupsToQuery = grouped.getEntityGroups.toArray;
if ~grouped.getUngroupedEntities.isEmpty
    groupsToQuery = grouped.getUngroupedEntities.toArray;
end
end

function props = getComponentProperties(searchTerm, groupedProps)
% iterates over groups to get component properties
props =[];
for i = 1:length(groupedProps)
    group = groupedProps(i);
    groupItems = group.getItems();
    % concat properties for each group
    props = [props; getPropertiesCell(searchTerm, char(group.getName()), groupItems.toArray())];
end
end

function propStruct = getPropertiesCell(searchTerm, groupName, items)
% converts Doc Center data into a struct with relevant fields
props = cell(length(items), 5);
for i = 1:length(items)
    refEntityName = char(items(i).getRefEntity.getName);
    props{i, 1} = refEntityName(length(searchTerm) + 2:end); % property name
    props{i, 2} = char(items(i).getPurposeLine());  % purpose
    props{i, 3} = char(items(i).getInputValues()); % inputs
    props{i, 4} = char(items(i).getRelativePath()); % help path
    props{i, 5} = groupName; % group
end
propStruct = struct('property', props(:,1), 'description', props(:,2), 'inputs', props(:,3), 'helpPath', props(:,4), 'group', props(:,5));
end