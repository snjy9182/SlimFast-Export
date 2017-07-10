clear;clc;
%% Load the Chromosome Mask
[FileName,PathName] = uigetfile('*.tif', 'Select the chromosome Mask');
fh = fullfile(PathName, FileName);
CMask = imread(fh);
[FileName,PathName] = uigetfile('*.tif', 'Select the Cell Mask');
fh = fullfile(PathName, FileName);
MaskCell = imread(fh);
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

%% Calculating Densities
[idx Total] = inmask(MaskCell, Particles);
[idxChr Nchro] = inmask(CMask, Particles);
outN = Total - Nchro;

Particles2 = Particles(idx, :);
Particles3 = Particles(idxChr, :);

figure, scatter(Particles2(1:20000, 3), Particles2(1:20000, 4), 'xb');
hold on
scatter(Particles3(1:20000, 3), Particles3(1:20000, 4), 'xg');
hold off


AvergD = Total/bwarea(MaskCell)
ChrD = Nchro/bwarea(CMask)
outD = outN/(bwarea(MaskCell)-bwarea(CMask))
