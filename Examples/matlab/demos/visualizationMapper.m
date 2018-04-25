function visualizationMapper(data, ~, intermKVStore, edges)
%
% Count how many flights have have arrival delay that in each interval 
% specified by the EDGES vector, and add these counts to INTERMKVSTORE.
% 

counts = histc( data.ArrDelay, edges );

add( intermKVStore, 'Null', counts );
