function [vertical_dat, horizontal_dat] = calculate_avg_SFRs(dat, ROI_num, SFR_confidence_flg)

v_edges = mod(ROI_num,2)>0;
h_edges = ~v_edges;

% Filter out ROI with inaccurate sharpness measurements
v_edges = (v_edges.*cell2mat(SFR_confidence_flg))>0;
h_edges = (h_edges.*cell2mat(SFR_confidence_flg))>0;

v_dat = dat(v_edges);
h_dat = dat(h_edges);

v_dat_mat = cell2mat(v_dat);
v_dat_mat_reshaped = reshape(v_dat_mat,size(v_dat_mat,1),size(dat{1},2),size(v_dat,2));
vertical_dat = mean(v_dat_mat_reshaped,3);

h_dat_mat = cell2mat(h_dat);
h_dat_mat_reshaped = reshape(h_dat_mat,size(h_dat_mat,1),size(dat{1},2),size(h_dat,2));
horizontal_dat = mean(h_dat_mat_reshaped,3);
