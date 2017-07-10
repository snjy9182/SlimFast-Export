[FileName,PathName] = uigetfile('*.mat', 'Select the processed file');
fh = fullfile(PathName, FileName);
load(fh);

common = (density.pdf) .* (density2.pdf);
common = common / max(max(common)');

All = (density.pdf) + (density2.pdf);
All = uint8(All / max(max(All)')*255);

diff = imfuse(density.pdf, density2.pdf, 'diff');

dS = (density.pdf).*(ones(size(common))-common);
dS = dS / max(max(dS)');

dO = density2.pdf.*(ones(size(common))-common);
dO = dO / max(max(dO)');


TotalS = imfuse(common,dS/1.5, 'falsecolor', 'Scaling','joint', 'ColorChannels', [2 1 2]);
TotalO = imfuse(common,dO/1.5, 'falsecolor', 'Scaling','joint', 'ColorChannels', [2 1 2]);

%% plotting
h=figure;
a=subplot(1,5,1), imagesc(density.pdf);
set(gca,'xtick',[],'ytick',[]);
b=subplot(1,5,2), imagesc(density2.pdf);
set(gca,'xtick',[],'ytick',[]);
c=subplot(1,5,3), imagesc(common);
set(gca,'xtick',[],'ytick',[]);
d=subplot(1,5,4), imagesc(TotalS);
set(gca,'xtick',[],'ytick',[]);
e=subplot(1,5,5), imagesc(TotalO);
set(gca,'xtick',[],'ytick',[]);

title(a,'Sox2 EnCs');title(b,'Oct4 EnCs');title(c,'Sox2*Oct4 (Common)');title(d,'Common vs Sox2');title(e,'Common vs Oct4');
tiff_f= [PathName 'Tiffformask.tif'];
imwrite(All,tiff_f);