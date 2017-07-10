clear; clc;
cutoff = 0.01;
load('Alldata.mat');
% hp = hp.*double(Mask);
% pdf = pdf.*double(Mask);

Mask = imread('Mask.tif');

pdf = imadjust(pdf.*(Mask).*(pdf > cutoff));
hp = imadjust(hp.*(Mask).*(hp > cutoff));

[n m] = size(hp);
rand1 = rand(n, m);
rand2 = rand(n, m);

xx = reshape(Mask, [numel(Mask) 1]);
idx = (xx == 1);
hpselect = hp(idx);
hpRselect = hpselect(randperm(numel(hpselect)));
hpR=hp;
hpR(idx) = hpRselect;
CR = imfuse(hpR, pdf);
C = imfuse(hp, pdf);

%%
h2=figure;
a=subplot(1,6,1), imagesc(hp);
set(gca,'xtick',[],'ytick',[]);
b=subplot(1,6,2), imagesc(hpR);
set(gca,'xtick',[],'ytick',[]);
c=subplot(1,6,3), imagesc(pdf);
set(gca,'xtick',[],'ytick',[]);
d=subplot(1,6,4), imagesc(C);
set(gca,'xtick',[],'ytick',[]);
e=subplot(1,6,5), imagesc(CR);
set(gca,'xtick',[],'ytick',[]);
f=subplot(1,6,6), imagesc(Mask);
set(gca,'xtick',[],'ytick',[]);
title(a,'GFP-HP1');title(b,'HP1 Permutated');title(c, 'Sox2 EnC'); titlMask = (hp > cutoff) | (pdf > cutoff);
% e(d, 'Merged HP1 Vs Sox2EnC'); title(e, 'Merged HP1 P vs Sox EnC')

Sx = reshape(hp(idx), [numel(hp(idx)) 1]);
Sy = reshape(pdf(idx), [numel(pdf(idx)) 1]);
Rx = reshape(hpR(idx), [numel(hpR(idx)) 1]);

[RHO,PVAL] = corr(Sx, Sy,'Type','Spearman');
[RHOR,PVALR] = corr(Rx, Sy,'Type','Spearman');

figure;
hold on;
plot(Sx, Sy, 'xg', 'MarkerSize', 4);
hold off;
xlim([0 1]);
ylim([0 1]);
xlabel('HP1 Intensity');
ylabel('Sox2 EC Intensity')

figure;
hold on;
plot(Rx, Sy, 'xg', 'MarkerSize', 4);
hold off;
xlim([0 1]);
ylim([0 1]);
xlabel('HP1 Intensity Permutated');
ylabel('Sox2 EC Intensity Permutated')

% figure;
% plot(Rx, Ry, 'xk', 'MarkerSize', 4);
% xlim([0 1]);
% ylim([0 1]);

disp(horzcat('Spearman correlation Rho for sig is ',  num2str(RHO)));
disp(horzcat('The P value for Spearman correlation for sig is ',  num2str(PVAL)));
disp(horzcat('Spearman correlation Rho for permutated sig is ',  num2str(RHOR)));
disp(horzcat('The P value for Spearman correlation for permutated sig is ',  num2str(PVALR)));