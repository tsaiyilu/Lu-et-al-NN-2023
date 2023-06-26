close all;
clear;
[file,path] = uigetfile('*.mat');
Fullname = fullfile(path, file);
load(Fullname);

%Create a 3D matrix to store onset maps%
w = res.opts.sz(1);
h = res.opts.sz(2);
OnsetFrames = res.ftsFilter.loc.t0;   %Extract the onset frame# for each event
N = size(OnsetFrames, 2);   %Count the total # of events
A = zeros(w, h, N);     %A will be the 3D matrix that stores the shape of onset events.

%Clean out index number that's not on the onset frame%
for i = 1:N
    B = w*h*OnsetFrames(i); %B = the first index number that's on the next frame
    OnsetInd = res.ftsFilter.loc.x3D{1,i}; %res.ftsFilter.loc.x3D = linear index of each event
    OnsetInd = OnsetInd(res.ftsFilter.loc.x3D{1,i} < B); %Index numbers that are larger than B will be excluded
    IndL = size(OnsetInd, 1);   %Count the number of index numbers
    OnsetInd2 = ceil(OnsetInd - w*h*(OnsetFrames(i)-1));    %Extract the location of each postitive pixels
    sz = [w h];
    [row, col] = ind2sub(sz, OnsetInd2);    %Transform index into a 2D matrix that represents the spatial location of the postitive pixels

    %Transfrom index into 3D matrix%
    for j = 1:IndL
        %jj = h + 1 - row(j); if using HeatMap function
        A(row(j), col(j), i) = 1;   %A will be the 3D matrix that stores all the shape of onset events.
    end
end

%Overlap all the onset events one to one matrix and count frequencies
C = zeros(w,h);
f = res.opts.sz(3); %the number of frames
t = (f-1)/120;   %total time (minute)

for k = 1:N
    
    C = C + A(:,:,k);
    
end

M = C/t; %frequency per minute

%Making figure%
figure;
clims = [0 3];
colormap(jet);
imagesc(M, clims);
yticks ([]);
xticks ([]);
colorbar;
colorbar('LineWidth', 1.5,'FontWeight','bold','FontName','Arial');

%Looking for event onset hotspots where z >2
OnsetMap = M;

OnsetMap(OnsetMap == 0 ) = NaN;
z = nanmean(OnsetMap(:)) + nanstd(OnsetMap(:))*2;
BW_3 = islocalmax(OnsetMap, 'FlatSelection', 'all', 'MinProminence', z);

figure;
clims = [0 1];
colormap(jet);
imagesc(BW_3, clims);
yticks ([]);
xticks ([]);
colorbar;
colorbar('LineWidth', 1,'FontWeight','bold','FontName','Arial');

