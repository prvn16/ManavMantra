function [esf_norm, ch_aberration] = calculateChAberration(ROI,esf)
limit = round(0.05*size(esf,1));
esf_norm = zeros(size(esf));

for i = 1:size(esf,2)
    esf_data = esf(:,i);
    esf_data_begin_mean = mean(esf_data(1:limit));
    esf_data_end_mean = mean(esf_data(end-limit:end));
    
    esf_data_norm = (esf_data-min([esf_data_begin_mean esf_data_end_mean]))/abs(esf_data_begin_mean-esf_data_end_mean);
    esf_norm(:,i) = esf_data_norm;
end
color_edges = esf_norm(:,1:3);
maxcol = max(color_edges,[],2);
mincol = min(color_edges,[],2);

% Scale chromatic aberration for a signal length equal to the width of the
% ROI, instead of 4 times the width due to super sampling of the data during
% sharpness measurement by sfrmat3
ch_aberration = sum(maxcol-mincol)*min([ROI(3) ROI(4)])/size(esf,1);
