clc;clear;
[FileName,PathName] = uigetfile('*.tif', 'Select the HP1 for mapping HC');
[FileName2,PathName2] = uigetfile('*.tif', 'Select the Mask tiff');
[FileName3,PathName3] = uigetfile('*.tif', 'Select the Diffusion Map tiff');
fh = fullfile(PathName, FileName);
Mk = fullfile(PathName2, FileName2);
Dm = fullfile(PathName3, FileName3);


hp = imread(fh);
Mask = imread(Mk);

Diffmap = imread(Dm);
Mask = (Mask > 200);

%% Second Mask
[FileName4,PathName4] = uigetfile('*.tif', 'Select the Mask 2 tiff');
Mk2 = fullfile(PathName4, FileName4);
Mask2 = imread(Mk2);
Mask2 = (Mask2 > 200);

%% contiune
figure, imshow(Mask);
Mask = Mask .* Mask2;
figure, imshow(Mask);

hp = hp.*uint8(Mask);
Diffmap = Diffmap.*uint8(Mask);

%% Select boundries data

background = imopen(hp,strel('disk',30));
hp = imsubtract(hp, background);
figure, imshow(hp, []);

hp = double(hp)/max(max(double(hp))');
figure, imshow(hp);
[m n] = size(hp);

%% Threshoulding the Data
pcutoffIn = 0.2;
pcutoffOut = 0.2;
MaskIn = (hp > max(max(hp)')*pcutoffIn);
MaskOut = (hp < max(max(hp)')*pcutoffOut).*Mask;

figure, imshow(MaskIn);
figure, imshow(MaskOut);

InmaskDiffusion = sum(sum(Diffmap.*uint8(MaskIn))')/bwarea(MaskIn);
OutmaskDiffusion = sum(sum(Diffmap.*uint8(MaskOut))')/bwarea(MaskOut);

High = 255;
HighD = 3.727;
Low = 2;
LowD = 0.015;

Slope = (HighD - LowD)/(High-Low);

OutDiff = LowD + (OutmaskDiffusion - LowD) * Slope;
InDiff = LowD + (InmaskDiffusion - LowD) * Slope;

disp(['In HP1 Mask Diffusion coeffient is ' num2str(InDiff)]);
disp(['Out HP1 Mask Diffusion coeffient is ' num2str(OutDiff)]);




