[file,path] = uigetfile('*.mat');
Fullname = fullfile(path, file);
load(Fullname);

w = res.opts.sz(1); %movie width
h = res.opts.sz(2); %movie height
n = size(res.ftsFilter.loc.x2D, 2); %No. of events
Max_Projection = zeros(w, h); %Prepare the canvas
sz = [w h];

for i = 1:n
    [row, col] = ind2sub(sz, res.ftsFilter.loc.x2D{1,i});
    
    L = size(row, 1); %subscript length
  
    for j = 1: L
        Max_Projection(row(j), col(j)) = Max_Projection(row(j), col(j)) + 1;
    end
end

f = res.opts.sz(3); %the number of frames
t = (f-1)/120; %total time
Max_Projectionf = Max_Projection/t; %event frequency

figure;
colormap(jet);
clims = [0 3];
imagesc(Max_Projectionf, clims);
yticks ([]);
xticks ([]);

