clear; clc;
cutoff = 0.2;
load('Alldata.mat');
Mask = (hp > cutoff) | (pdf > cutoff);
Mask1 = (hp > cutoff);
Mask2 = (pdf > cutoff);

%hp = hp.*double(Mask);
%pdf = pdf.*double(Mask);

[n m] = size(hp);
rand1 = rand(n, m);
rand2 = rand(n, m);
%pdf = hp;

i = 1;
for x = 1:n
    for y = 1:m
        i = i + 1;
        hpV(i) = hp(x, y);
        pdfV(i) = pdf(x, y);
        rand1V(i) = rand1(x, y);
        rand2V(i) = rand2(x, y);
    end
end

idx = (hpV<cutoff & pdfV<cutoff);
bg = horzcat(hpV(idx)', pdfV(idx)');
sig = horzcat(hpV(~idx)', pdfV(~idx)');
siz = length(sig);

ixR = randperm(siz);
ixR2 = randperm(siz);
Rx = sig(ixR, 1);
Ry = sig(ixR2, 2);

[RHO,PVAL] = corr(sig(:, 1), sig(:, 2),'Type','Spearman');
[RHOR,PVALR] = corr(Rx, Ry,'Type','Spearman');

figure;
hold on;
plot(bg(:,1), bg(:,2), 'xk', 'MarkerSize', 4);
plot(sig(:,1), sig(:,2), 'xg', 'MarkerSize', 4);
hold off;
xlim([0 1]);
ylim([0 1]);
xlabel('HP1 Intensity');
ylabel('Sox2 EC Intensity')

figure;
hold on;
plot(Rx, Ry, 'xg', 'MarkerSize', 4);
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