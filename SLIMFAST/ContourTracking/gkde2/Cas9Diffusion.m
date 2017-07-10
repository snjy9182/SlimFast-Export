clear; clc;
track_length = 5; %cutoff
AquT = 0.01; %ms
Pixel = 0.1; %um
ConfinedRcutoff = 0.4;

%% Loading Tracks
[FileName2,PathName2] = uigetfile('*.txt', 'Select the track file for Diffusion Analysis (10ms)');
fh2 = fullfile(PathName2, FileName2);

Tracks = load(fh2);
len = length(Tracks);

if len < 10000
    Data = Tracks;
else
    Data = Tracks(1:10000,:);
end


%% load Data From Tracked file from SPTeval

%Select xy data
xy=figure;
scatter(Data(:,1), Data(:,2));

hxy = impoly();
nodesxy = getPosition(hxy);
close(xy);
idx1 = inpoly([Tracks(:,1), Tracks(:,2)], nodesxy);
Tracks=Tracks(idx1, :);

dlmwrite('newtable.txt',Tracks, '\t');

len = length(Tracks);

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
filename = strcat(FileName2(1:end-4), '.mat');
save(filename, 'All');
% Analyzing Diffusion Coefficent by Bowian 

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

[Yout, Xout] = hist(log10(ma_all.lfit.a(ma_all.lfit.a>0)), 20);
D=log10(ma_all.lfit.a(ma_all.lfit.a>0));

