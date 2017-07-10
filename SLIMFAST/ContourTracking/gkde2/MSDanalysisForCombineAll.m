clear;clc;
folder_name = uigetdir;
data_files = dir(fullfile(folder_name, ...
               '/*.mat'));

disp(strcat('Total_file number_', num2str(length(data_files))));

AllTracks = [];
AllInMask = [];

for k=1:length(data_files)
load(fullfile(folder_name, data_files(k).name));
AllTracks = vertcat(AllTracks, All);
AllInMask = vertcat(AllInMask, In_Mask);
end


%%  Analyzing Diffusion Coefficent by Bowian 
ConfinedRcutoff = 0.4;
SPACE_UNITS = 'µm';
TIME_UNITS = 's';

% analyse all data
ma_all = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
ma_all = ma_all.addAll(AllTracks);
figure, ma_all.plotTracks;
xlabel('X(um)');
ylabel('Y(um)');

ma_all.labelPlotTracks;
ma_all = ma_all.computeMSD;
%figure,ma_in.plot(MSD);
ma_all = ma_all.fitMSD(0.8);
ma_all = ma_all.fitLogLogMSD(0.9);

figure, hist(log10(ma_all.lfit.a(ma_all.lfit.a>0)), 30);
title('Diffusion Coefficent for all population');
xlabel('Log10(D(um2/s)');
ylabel('Counts');

% ma_all = ma_all.fitLogLogMSD(0.9);
% figure, hist(ma_all.loglogfit.alpha(ma_all.loglogfit.alpha>0 & ma_all.loglogfit.r2fit > ConfinedRcutoff), 10);
% title('Confined Diffusion Analysis for All population');
% xlabel('Alpha');
% ylabel('Counts');
% xlim([0 1.5]);

% analyse in mask data
% ma_in = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
% ma_in = ma_in.addAll(AllInMask);
% figure, ma_in.plotTracks;
% ma_in.labelPlotTracks;
% ma_in = ma_in.computeMSD;
% %figure,ma_in.plot(MSD);
% ma_in = ma_in.fitMSD(0.8);
% ma_in = ma_in.fitLogLogMSD(0.9);
% 
% figure, hist(log10(ma_in.lfit.a(ma_in.lfit.a>0)), 10);
% title('Diffusion Coefficent for InMask population');
% xlabel('Log10(D(um2/s)');
% ylabel('Counts');

% ma_in = ma_in.fitLogLogMSD(0.9);
% figure, hist(ma_in.loglogfit.alpha(ma_in.loglogfit.alpha>0 & ma_in.loglogfit.r2fit > ConfinedRcutoff), 10);
% title('Confined Diffusion Analysis for InMask population');
% xlabel('Alpha');
% ylabel('Counts');
% xlim([0 1.5]);


