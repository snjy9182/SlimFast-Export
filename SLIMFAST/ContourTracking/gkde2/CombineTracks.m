clc;clear;
[fileNames,PathName] = uigetfile('*.mat',  'Select files', 'MultiSelect', 'on');
if ischar(fileNames); fileNames = {fileNames}; end
NumFiles = length(fileNames);
Inmaskall = {};
Allall = {};
for i = 1:NumFiles
    file = fullfile(PathName, fileNames{i});
    load(file);
    Inmaskall = [Inmaskall In_Mask']; 
    Allall = [Allall All'];
end
Inmaskall = Inmaskall';
Allall = Allall';

%%  Analyzing Diffusion Coefficent by Bowian 

SPACE_UNITS = 'µm';
TIME_UNITS = 's';

% analyse all data
ma_all = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
ma_all = ma_all.addAll(Allall);
figure, ma_all.plotTracks;
xlabel('X(um)');
ylabel('Y(um)');

ma_all.labelPlotTracks;
ma_all = ma_all.computeMSD;
ma_all = ma_all.fitMSD(0.8);
ma_all = ma_all.fitLogLogMSD(0.9);


figure, hist(log10(ma_all.lfit.a(ma_all.lfit.a>0)), 30);
title('Diffusion Coefficent for all population');
xlabel('Log10(D(um2/s)');
ylabel('Counts');


% analyse in mask data
ma_in = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
ma_in = ma_in.addAll(Inmaskall);
figure, ma_in.plotTracks;
ma_in.labelPlotTracks;
ma_in = ma_in.computeMSD;
ma_in = ma_in.fitMSD(0.8);
ma_in = ma_in.fitLogLogMSD(0.9);

All_logD = log10(ma_all.lfit.a(ma_all.lfit.a>0));
In_logD = log10(ma_in.lfit.a(ma_in.lfit.a>0));

figure, hist(log10(ma_in.lfit.a(ma_in.lfit.a>0)), 30);
title('Diffusion Coefficent for InMask population');
xlabel('Log10(D(um2/s)');
ylabel('Counts');


%% Saving Data

save('Combined.mat', 'Allall', 'Inmaskall', 'All_logD', 'In_logD');




