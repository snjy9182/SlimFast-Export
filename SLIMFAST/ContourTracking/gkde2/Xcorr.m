clear;clc;
load('Alldata')
Mask = imread('Mask.tif');
MaskBW = im2bw(Mask, 0.5);
%MaskBW = Mask;
R = 40;
%% Normalization
hp(~MaskBW) = 0;
pdf(~MaskBW) = 0;
UnitHP = 1/sum(sum(hp)');
Unitpdf = 1/sum(sum(pdf)');
[n m] = size(MaskBW);

hp = hp * UnitHP;
pdf = pdf * Unitpdf;

BW = double(MaskBW);
UnitWB = 1/sum(sum(BW)');
BW = BW * UnitWB;

Xhp = xcorr2(hp,hp)./xcorr2(BW,BW);
figure, surf(Xhp(n-R:n+R, m-R:m+R));
title('Heterochromatin Autocorrelation');

Xec = xcorr2(pdf,pdf)./xcorr2(BW,BW);
figure, surf(Xec(n-R:n+R, m-R:m+R));
title('Sox2 EC Autocorrelation');

Xhc = xcorr2(pdf,hp)./xcorr2(BW,BW);
figure, surf(Xhc(n-R:n+R, m-R:m+R));
title('HC/EC Cross Correlation');
save('Xcorr.mat', 'Xhp', 'Xec', 'Xhc');



