%%Density Map Mask from 500ms condition
clear; clc;
AquT = 0.01; %ms
Pixel = 0.16; %um
ConfinedRcutoff = 0.4;


%% calculate Heterochromatin Density
[FileName,PathName] = uigetfile('*.tif', 'Select the HP1 for mapping HC');
fh = fullfile(PathName, FileName);
hp = imread(fh);
hp2 = imadjust(hp);
%Select boundries data
xy=figure;
[BW, xi, yi] = roipoly(hp2);
nodesxy = [xi, yi];
close(xy);

hp = double(hp);
ori = hp;
background = imopen(hp,strel('disk',10));
hp = imsubtract(hp, background);
hp = hp/max(max(hp)');
figure, surf(hp);
[m n] = size(hp);

%% Threshoulding the Data
pcutoffIn = 0.3;
pcutoffOut = 0.3;
MaskIn = (hp > max(max(hp)')*pcutoffIn);
MaskOut = (hp < max(max(hp)')*pcutoffOut);
MaskOut = MaskOut.*BW;
figure;
subplot(1,3,1), imshow(hp2);
subplot(1,3,2), imshow(MaskIn);
subplot(1,3,3), imshow(MaskOut);



%% Track Divider
[FileName2,PathName2] = uigetfile('*.txt', 'Select the track file for Diffusion Analysis (10ms)');
fh2 = fullfile(PathName2, FileName2);
Tracks = load(fh2);
idx2 = inpoly([Tracks(:,1), Tracks(:,2)], nodesxy);
Tracks = Tracks(idx2, :);
idxIn = [];
idxOut = [];
len = length(Tracks);

%% Calculating idxIn for InMask
for i = 1:len
    TF = 0;
    point = Tracks(i,:);
    X = round(point(1));
    Y = round(point(2));
    TF = MaskIn(Y, X);
    idxIn = [idxIn TF];
end

for i = 1:len
    TF = 0;
    point = Tracks(i,:);
    X = round(point(1));
    Y = round(point(2));
    TF = MaskOut(Y, X);
    idxOut = [idxOut TF];
end

Inmask = Tracks(logical(idxIn),:);
Outmask = Tracks(logical(idxOut),:);


Inmask = Tracks(logical(idxIn),:);

Inmask_NofLoc = length(Inmask);
Out_NofLoc = length(Outmask);

Density_Inmask = Inmask_NofLoc/bwarea(MaskIn);
Density_out = Out_NofLoc/bwarea(MaskOut);

Relative_Ratio_of_Nofloc = Density_Inmask/Density_out

