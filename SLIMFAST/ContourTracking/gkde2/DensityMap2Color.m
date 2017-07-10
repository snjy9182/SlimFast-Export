%%Density Map Mask from 500ms condition
clear; clc;
track_length = 8; %cutoff
AquT = 0.01; %ms
Pixel = 0.16; %um
ConfinedRcutoff = 0.4;


%% load Data From Tracked file from SPTeval

[FileName,PathName] = uigetfile('*.txt', 'Select the track file for Sox2 mapping clustering (500ms)');
fh = fullfile(PathName, FileName);
Data = load(fh);
Data = Data(:,1:2);

[FileName2,PathName2] = uigetfile('*.txt', 'Select the track file for Oct4 mapping clustering (500ms)');
fh2 = fullfile(PathName2, FileName2);
Data2 = load(fh2);
Data2 = Data2(:,1:2);

%Select xy data
xy=figure;
scatter(Data(:,1), Data(:,2));

hxy = impoly();
nodesxy = getPosition(hxy);
close(xy);
idx1 = inpoly([Data(:,1), Data(:,2)], nodesxy);
Data=Data(idx1, :);

figure, plot(Data(:,1)*Pixel, Data(:,2)*Pixel, 'xb');
title('Sox2 Input Data');


%% load Data From Tracked file from SPTeval
idx12 = inpoly([Data2(:,1), Data2(:,2)], nodesxy);
Data2=Data2(idx12, :);

figure, plot(Data2(:,1)*Pixel, Data2(:,2)*Pixel, 'xb');
title('Oct4 Input Data');

%% Normalize the data
minx = min([Data(:,1); Data2(:,1)]);
maxx = max([Data(:,1); Data2(:,1)]);
miny = min([Data(:,2); Data2(:,2)]);
maxy = max([Data(:,2); Data2(:,2)]);

Data = [Data; [minx, miny]];
Data = [Data; [maxx, maxy]];

Data2 = [Data2; [minx, miny]];
Data2 = [Data2; [maxx, maxy]];

%% Density Kernel Estimation
p.N=100;
p.h=[2, 2];

density = gkde2(Data, p);
figure, surf(density.pdf);
title('Kernel Density EStimation for Sox2');

density2 = gkde2(Data2, p);
figure, surf(density2.pdf);
title('Kernel Density EStimation for Oct4');

common = (density.pdf) .* (density2.pdf);
common = common / max(max(common)');
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

title(a,'Sox2 EnCs');title(b,'Oct4 EnCs');title(c,'Sox2*Oct4');title(d,'Common vs Sox2');title(e,'Common vs Oct4');


FileS = [PathName 'Alldata'];
save(FileS, 'Data', 'Data2', 'density', 'density2');


% %% Threshoulding the Data
% pcutoffIn = 0.2;
% pcutoffOut = 0.2;
% MaskIn = (density.pdf > max(max(density.pdf)')*pcutoffIn);
% MaskOut = (density.pdf < max(max(density.pdf)')*pcutoffOut);
% 
% figure, imshow(flipdim(MaskIn,1));
% figure, imshow(flipdim(MaskOut,1));
% minx = min(density.x(1,:)');
% maxx = max(density.x(1,:)');
% miny = min(density.y(:,1));
% maxy = max(density.y(:,1));
% Unitx = (maxx - minx)/p.N;
% Unity = (maxy - miny)/p.N;
% 
% %% Track Divider
% [FileName2,PathName2] = uigetfile('*.txt', 'Select the track file for Diffusion Analysis (10ms)');
% fh2 = fullfile(PathName2, FileName2);
% Tracks = load(fh2);
% idx2 = inpoly([Tracks(:,1), Tracks(:,2)], nodesxy);
% Tracks = Tracks(idx2, :);
% idxIn = [];
% idxOut = [];
% len = length(Tracks);
% 
% %% Calculating idxIn for InMask
% for i = 1:len
%     TF = 0;
%     point = Tracks(i,:);
%     X = point(1);
%     Y = point(2);
%     if (X > minx) & (X < maxx) & (Y > miny) & (Y < maxy)
%         XX = floor((X - minx)/Unitx) + 1;
%         YY = floor((Y - miny)/Unity) + 1;
%         TF = MaskIn(YY, XX);
%     end
%     idxIn = [idxIn TF];
% end
% 
% 
% %% Calculating idxOut for OutMask
% for i = 1:len
%     TF = 0;
%     point = Tracks(i,:);
%     X = point(1);
%     Y = point(2);
%     if (X > minx) & (X < maxx) & (Y > miny) & (Y < maxy)
%         XX = floor((X - minx)/Unitx) + 1;
%         YY = floor((Y - miny)/Unity) + 1;
%         TF = MaskOut(YY, XX);
%     end
%     idxOut = [idxOut TF];
% end
% 
% All = {};
% item = [];
% i=1;
% 
% while i < len
%     if isempty(item)
%        item = vertcat(item, Tracks(i,:));
%        if i < len
%         i = i + 1;
%        end
%     end
%     while (Tracks(i-1, 4) == Tracks(i, 4)) & (Tracks(i-1, 3) > Tracks(i, 3) - 4)
%         item = vertcat(item, Tracks(i,:));
%         if i < len
%             i = i + 1;
%         else i == len -1;
%             break;
%         end
%     end
%     [n m] = size(item);
%     if n >= track_length
%         itemM = [item(:,3) * AquT, item(:,1) * Pixel, item(:,2)*Pixel];
%         All = [All, itemM];
%     end
%     item = [];
% end
% All = All';
% 
% 
% Inmask = Tracks(logical(idxIn),:);
% Outmask = Tracks(logical(idxOut),:);
% 
% In_Mask = {};
% lenIn = length(Inmask);
% in = [];
% i=1;
% while i < lenIn
%     if isempty(in)
%        in = vertcat(in, Inmask(i,:));
%        if i < lenIn
%         i = i + 1;
%        end
%     end
%     while (Inmask(i-1, 4) == Inmask(i, 4)) & (Inmask(i-1, 3) > Inmask(i, 3) - 4)
%         in = vertcat(in, Inmask(i,:));
%         if i < lenIn
%             i = i + 1;
%         else i == lenIn -1;
%             break;
%         end
%     end
%     [n m] = size(in);
%     if n >= track_length
%         inM = [in(:,3) * AquT, in(:,1) * Pixel, in(:,2)*Pixel];
%         In_Mask = [In_Mask, inM];
%     end
%     in = [];
% end
% In_Mask = In_Mask';
% 
% Out_Mask = {};
% lenOut = length(Outmask);
% out = [];
% outM = [];
% i=1;
% while i < lenOut
%     if isempty(out)
%        out = vertcat(out, Outmask(i,:));
%        if i < lenOut
%         i = i + 1;
%        end
%     end
%     while (Outmask(i-1, 4) == Outmask(i, 4)) & (Outmask(i-1, 3) > Outmask(i, 3) - 4)
%         out = vertcat(out, Outmask(i,:));
%         if i < lenOut
%             i = i + 1;
%         else i == lenOut - 1;
%             break;
%         end
%     end
%     [n m] = size(out);
%     if n >= track_length
%         outM = [out(:,3) * AquT, out(:,1) * Pixel, out(:,2)*Pixel];
%         Out_Mask = [Out_Mask, outM];
%     end
%     Out_Mask = [Out_Mask, outM];
%     out = [];
% end
% Out_Mask = Out_Mask';
% 
% %%  Analyzing Diffusion Coefficent by Bowian 
% 
% SPACE_UNITS = 'µm';
% TIME_UNITS = 's';
% 
% 
% % analyse all data
% ma_all = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
% ma_all = ma_all.addAll(All);
% figure, ma_all.plotTracks;
% xlabel('X(um)');
% ylabel('Y(um)');
% 
% ma_all.labelPlotTracks;
% ma_all = ma_all.computeMSD;
% %figure,ma_in.plot(MSD);
% ma_all = ma_all.fitMSD(0.8);
% ma_all = ma_all.fitLogLogMSD(0.9);
% 
% figure, hist(log10(ma_all.lfit.a(ma_all.lfit.a>0)), 20);
% title('Diffusion Coefficent for all population');
% xlabel('Log10(D(um2/s)');
% ylabel('Counts');
% 
% % ma_all = ma_all.fitLogLogMSD(0.9);
% % figure, hist(ma_all.loglogfit.alpha(ma_all.loglogfit.alpha>0 & ma_all.loglogfit.r2fit > ConfinedRcutoff), 10);
% % title('Confined Diffusion Analysis for All population');
% % xlabel('Alpha');
% % ylabel('Counts');
% % xlim([0 1.5]);
% 
% % 
% % ma_in = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
% % ma_in = ma_in.addAll(In_Mask);
% % figure, ma_in.plotTracks;
% % ma_in.labelPlotTracks;
% % ma_in = ma_in.computeMSD;
% % %figure,ma_in.plot(MSD);
% % ma_in = ma_in.fitMSD(0.8);
% % ma_in = ma_in.fitLogLogMSD(0.9);
% % 
% % figure, hist(log10(ma_in.lfit.a(ma_in.lfit.a>0)), 20);
% % title('Diffusion Coefficent for InMask population');
% % xlabel('Log10(D(um2/s)');
% % ylabel('Counts');
% % 
% % ma_in = ma_in.fitLogLogMSD(0.9);
% % figure, hist(ma_in.loglogfit.alpha(ma_in.loglogfit.alpha>0 & ma_in.loglogfit.r2fit > ConfinedRcutoff), 10);
% % title('Confined Diffusion Analysis for InMask population');
% % xlabel('Alpha');
% % ylabel('Counts');
% % xlim([0 1.5]);
% % 
% % % analyse our mask data
% % ma_out = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
% % ma_out = ma_out.addAll(Out_Mask);
% % figure, ma_out.plotTracks;
% % ma_out.labelPlotTracks;
% % ma_out = ma_out.computeMSD;
% % %figure,ma_in.plot(MSD);
% % ma_out = ma_out.fitMSD(0.8);
% % ma_out = ma_out.fitLogLogMSD(0.9);
% % 
% % figure, hist(log10(ma_out.lfit.a(ma_out.lfit.a>0)), 20)
% % title('Diffusion Coefficent for OutMask population');
% % xlabel('Log10(D(um2/s)');
% % ylabel('Counts');
% % 
% % figure, hist(ma_out.loglogfit.alpha(ma_out.loglogfit.alpha>0 & ma_out.loglogfit.r2fit > ConfinedRcutoff), 60);
% % title('Confined Diffusion Analysis for OutMask population');
% % xlabel('Alpha');
% % ylabel('Counts');
% % xlim([0 1.5]);
% % 
% % %% Saving data
% % save('DataAnalysed.mat', 'All', 'In_Mask', 'Out_Mask', 'MaskIn', 'MaskOut', 'Pixel');
% % 
% % %% plot overlapping between mask and tracks
% % 
% % xImg = linspace(minx*Pixel, maxx*Pixel, p.N);
% % yImg = linspace(miny*Pixel, maxy*Pixel, p.N);
% % figure;
% % image(xImg, yImg, MaskIn, 'CDataMapping', 'scaled');
% % hold on;
% % ma_in.plotTracks;
% % xlim([minx*Pixel, maxx*Pixel]);
% % ylim([miny*Pixel, maxy*Pixel]);
% % title('Overlapped');
% % xlabel('X(um)');
% % ylabel('Y(um)');
% 
% % [FileName2,PathName2] = uigetfile('*.mat', 'Select the tracked file for saving');
% % fh2 = fullfile(PathName2, FileName2);
% % load(fh2);
% % data = struct('tr',{In_Mask});
% % oh1 = fullfile(PathName2, 'Inmasktrks.mat');
% % save(oh1, 'data', 'par_per_frame', 'settings');
% % 
% % data = struct('tr',{Out_Mask});
% % oh2 = fullfile(PathName2, 'Outmasktrks.mat');
% % save(oh2, 'data', 'par_per_frame', 'settings');
% 
% 


