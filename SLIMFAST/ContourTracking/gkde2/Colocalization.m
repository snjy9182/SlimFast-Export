%% Load Mask

[FileName3,PathName3] = uigetfile('*.tif', 'Select nuclear Mask');
fh3 = fullfile(PathName3, FileName3);
mask = imread(fh3);
mask = (mask > 200);

%% calculate Heterochromatin Density

[FileName,PathName] = uigetfile('*.tif', 'Select the HP1 for mapping HC');
fh = fullfile(PathName, FileName);
hp = imread(fh);
hp = double(hp);
ori = hp;
background = imopen(hp,strel('disk',10));
hp = imsubtract(hp, background);
hp = hp.*mask;
hp = hp/max(max(hp)');
figure, surf(flipdim(hp,1));
[m n] = size(hp);


%% calculate SF2 Density

[FileName2,PathName2] = uigetfile('*.tif', 'Select the SF2 for mapping Splicing factory');
fh2 = fullfile(PathName2, FileName2);
sf = imread(fh2);
sf = double(sf);
ori2 = sf;
background2 = imopen(sf,strel('disk',10));
sf = imsubtract(sf, background2);
sf = sf.*mask;
sf = sf/max(max(sf)');
figure, surf(flipdim(sf,1));


%% load Data From Tracked file from SPTeval
Pixel = 0.16; %um
[FileName,PathName] = uigetfile('*.txt', 'Select the track file for mapping clustering (500ms)');
fh = fullfile(PathName, FileName);
Data = load(fh);
Data = Data(:,1:2);

% %Select xy data
% xy=figure;
% scatter(Data(:,1), Data(:,2));
% 
% hxy = impoly();
% nodesxy = getPosition(hxy);
% close(xy);
% idx1 = inpoly([Data(:,1), Data(:,2)], nodesxy);
% Data=Data(idx1, :);

figure;
plot(Data(:,1), fliplr(Data(:,2)), 'xb');
set(gca,'YDir','reverse');
title('Input Data');

%% Density Kernel Estimation
p.N=100;
p.h=[2, 2];

density = gkde2(Data, p);
pdf = imresize(density.pdf, [m n]);
pdf = pdf/max(max(pdf)');
pdf = pdf.*mask;
figure, surf(flipdim(pdf,1));
title('Kernel Density Estimation');
C = imfuse(hp, pdf, 'ColorChannels', [2 1 2]);
C2 = imfuse(sf, pdf, 'ColorChannels', [2 1 2]);
C3 = imfuse(hp, sf, 'ColorChannels', [2 1 0]);

%% plotting
h=figure;
a=subplot(1,6,1), imagesc(hp);
set(gca,'xtick',[],'ytick',[]);
b=subplot(1,6,2), imagesc(sf);
set(gca,'xtick',[],'ytick',[]);
c=subplot(1,6,3), imagesc(pdf);
set(gca,'xtick',[],'ytick',[]);
d=subplot(1,6,4), imagesc(C3);
set(gca,'xtick',[],'ytick',[]);
e=subplot(1,6,5), imagesc(C);
set(gca,'xtick',[],'ytick',[]);
f=subplot(1,6,6), imagesc(C2);
set(gca,'xtick',[],'ytick',[]);

title(a,'GFP-HP1');title(b,'tRFP-SF2');title(c,'Sox2 EnC');title(d,'HP1 and SF2');title(e,'HP1 and EnC');title(f, 'SF2 and EnC');

save('Alldata', 'hp', 'sf', 'pdf');
cutoff = 0.3;
Density_HP1 = sum(sum((hp>cutoff).*mask.*pdf)')/bwarea((hp>cutoff).*mask)
Density_SF2 = sum(sum((sf>cutoff).*mask.*pdf)')/bwarea((sf>cutoff).*mask)






