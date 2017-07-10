%%Density Map Mask from 500ms condition
clear; clc;
track_length = 8; %cutoff
AquT = 0.01; %ms
Pixel = 0.16; %um
ConfinedRcutoff = 0.4;


%% calculate Heterochromatin Density
[FileName,PathName] = uigetfile('*.tif', 'Select the HP1 for mapping HC');
fh = fullfile(PathName, FileName);
hp = imread(fh);

%Select boundries data
xy=figure;
imshow(hp,[]);
hxy = impoly();
nodesxy = getPosition(hxy);
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

figure, imshow(flipdim(MaskIn,1));
figure, imshow(flipdim(MaskOut,1));


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

%% Calculating idxOut for OutMask
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

dlmwrite('Table_Inmask.txt', Inmask, '\t');
dlmwrite('Table_outmask.txt', Outmask, '\t');


All = {};
item = [];
i=1;

while i < len
    if isempty(item)
       item = vertcat(item, Tracks(i,:));
       if i < len
        i = i + 1;
       end
    end
    while (Tracks(i-1, 4) == Tracks(i, 4)) & (Tracks(i-1, 3) > Tracks(i, 3) - 4)
        item = vertcat(item, Tracks(i,:));
        if i < len
            i = i + 1;
        else i == len -1;
            break;
        end
    end
    [n m] = size(item);
    if n >= track_length
        itemM = [item(:,3) * AquT, item(:,1) * Pixel, item(:,2)*Pixel];
        All = [All, itemM];
    end
    item = [];
end
All = All';


In_Mask = {};
lenIn = length(Inmask);
in = [];
i=1;
while i < lenIn
    if isempty(in)
       in = vertcat(in, Inmask(i,:));
       if i < lenIn
        i = i + 1;
       end
    end
    while (Inmask(i-1, 4) == Inmask(i, 4)) & (Inmask(i-1, 3) > Inmask(i, 3) - 4)
        in = vertcat(in, Inmask(i,:));
        if i < lenIn
            i = i + 1;
        else i == lenIn -1;
            break;
        end
    end
    [n m] = size(in);
    if n >= track_length
        inM = [in(:,3) * AquT, in(:,1) * Pixel, in(:,2)*Pixel];
        In_Mask = [In_Mask, inM];
    end
    in = [];
end
In_Mask = In_Mask';

Out_Mask = {};
lenOut = length(Outmask);
out = [];
outM = [];
i=1;
while i < lenOut
    if isempty(out)
       out = vertcat(out, Outmask(i,:));
       if i < lenOut
        i = i + 1;
       end
    end
    while (Outmask(i-1, 4) == Outmask(i, 4)) & (Outmask(i-1, 3) > Outmask(i, 3) - 4)
        out = vertcat(out, Outmask(i,:));
        if i < lenOut
            i = i + 1;
        else i == lenOut - 1;
            break;
        end
    end
    [n m] = size(out);
    if n >= track_length
        outM = [out(:,3) * AquT, out(:,1) * Pixel, out(:,2)*Pixel];
        Out_Mask = [Out_Mask, outM];
    end
    Out_Mask = [Out_Mask, outM];
    out = [];
end
Out_Mask = Out_Mask';

%%  Analyzing Diffusion Coefficent by Bowian 

SPACE_UNITS = 'µm';
TIME_UNITS = 's';


% analyse all data
ma_all = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
ma_all = ma_all.addAll(All);
figure, ma_all.plotTracks;
xlabel('X(um)');
ylabel('Y(um)');

ma_all.labelPlotTracks;
ma_all = ma_all.computeMSD;
%figure,ma_in.plot(MSD);
ma_all = ma_all.fitMSD(0.8);
ma_all = ma_all.fitLogLogMSD(0.9);

figure, hist(log10(ma_all.lfit.a(ma_all.lfit.a>0)), 20);
title('Diffusion Coefficent for all population');
xlabel('Log10(D(um2/s)');
ylabel('Counts');