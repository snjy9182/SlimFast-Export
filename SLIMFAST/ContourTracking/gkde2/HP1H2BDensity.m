clear;clc;
judge = 0; % 0 mask with matlab, 1 mask with PS

%% calculate Heterochromatin Density

[FileName,PathName] = uigetfile('*.tif', 'Select the HP1 for mapping HC');
fh = fullfile(PathName, FileName);
hp = imread(fh);
hp = double(hp);
ori = hp;
background = imopen(hp,strel('disk',10));
hp = imsubtract(hp, background);
hp = hp/max(max(hp)');
figure, surf(flipdim(hp,1));
[m n] = size(hp);
HP1Mask = (hp > 0.3);

%% load Data From QuickPALM
[FileName,PathName] = uigetfile('*.txt', 'Select the track file for mapping clustering (500ms)');
fh = fullfile(PathName, FileName);

filename = fullfile(PathName, FileName);
delimiter = '\t';
startRow = 2;

formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

fileID = fopen(filename,'r');


dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);

fclose(fileID);

Particles = [dataArray{1:end-1}];
clearvars filename delimiter startRow formatSpec fileID dataArray ans;


%% load nucleus mask
if judge == 0
    load('mask.mat');
end
if judge ==1
    [FileName,PathName] = uigetfile('*.tif', 'Select the Mask file');
    fh = fullfile(PathName, FileName);
    mask = imread(fh);
    mask = mask > 2000;
end

NHP1mMask = mask .* (~HP1Mask);
[idxHP1 HP1N] = inmask(HP1Mask, Particles);
[idx Total] = inmask(mask, Particles);
[idxout outN] = inmask(NHP1mMask, Particles);

clc;
AvergD = Total/bwarea(mask)
HP1D = HP1N/bwarea(HP1Mask)
outD = outN/bwarea(NHP1mMask)

[L, num] = bwlabel(HP1Mask, 8);
for i = 1:num
    M = (L == i);
    [idxM TM] = inmask(M, Particles);
    Enrichment = TM/bwarea(M)/AvergD
end

figure, scatter(Particles(idx, 3), Particles(idx, 4), 'xb');
hold on
scatter(Particles(idxHP1, 3), Particles(idxHP1, 4), 'xr');
%scatter(Particles(~idx, 3), Particles(~idx, 4), 'xg');
hold off





