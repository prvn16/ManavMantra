% Returns Preference Data and Search Data 

%Message service does not allow entire Map to be published
%Have to do an feval to allows Map
%So splitting the map into keys and values to transmit to JavaScript
function [preferenceData, searchData] = JavaScriptPreferenceData
%Call Java function
prefData = com.mathworks.mde.desk.PrefsFetcher.buildPreferenceList();
prefMap = struct('keys','','values','');

for i = 0:prefData.size()-1 
    prefMap(i+1).keys =mls.internal.toJSON(cell(prefData.get(i).keySet().toArray()));
    prefMap(i+1).values =mls.internal.toJSON(cell(prefData.get(i).values().toArray()));
end
preferenceData =  prefMap;
searchMap = struct('keys','','values','');
sData = com.mathworks.mde.desk.SearchPreferences.getSearchData();
searchMap.keys = mls.internal.toJSON(cell(sData.keySet.toArray()));
searchMap.values = mls.internal.toJSON(cell(sData.values.toArray()));
searchData =  searchMap;
end


