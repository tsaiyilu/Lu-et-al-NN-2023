close all;
clear;
[file,path] = uigetfile('*.mat');
Fullname = fullfile(path, file);
load(Fullname);
[filepath, name, ext] = fileparts(file)

f = res.opts.sz(3); %the number of frames
t = (f-1)/2; %total time (sec)
N = size(res.ftsFilter.loc.t0, 2); %number of all events
t0 = transpose(res.ftsFilter.loc.t0); %onset FRAMES for all events
t0 = (t0-1)/2; %convert frames to time
tMax = transpose(res.ftsFilter.curve.dffMaxFrame); %Peaked(Maxdff)TIME
dff2 = res.dffMatFilter(:,:,2);%dff2 = dff after removing the contributions from other events%
Time = (0:f-1)*0.5;
TowardScore = res.ftsFilter.region.landmarkDir.chgToward;
AwayScore = res.ftsFilter.region.landmarkDir.chgAway;
%Calculate the Away - Toward score
Direction = AwayScore - TowardScore;

%tMaxdff2= [tMax dff2];
%t0_tMaxdff2 = [t0 tMaxdff2];
t0_tMax_Direction = [t0 tMax Direction];

%Read the distance to landmark of the frist frame of each event. i.e. the distance to landmark when the evnet was initiated. %
OnsetDist = zeros(N, 1);

for i = 1:N
    OnsetDist(i, 1) = res.ftsFilter.region.landmarkDist.distPerFrame{i, 1}(1,1);
end

%Define soma events as onset distance to landmark <= 1 micron
Soma_events = OnsetDist <= 1;
Soma_events_size = sum(Soma_events(:)==1);
Soma_events_idx = find(Soma_events==1);

s_t0_tMax_Direction = [Soma_events t0_tMax_Direction];
sorted_s_t0_tMax_Direction = sortrows(s_t0_tMax_Direction, 3);
sorted_soma_idx = find(sorted_s_t0_tMax_Direction(:,1) == 1);

%Find # of that peaked 10 seconds before and after a soma event
Z = NaN(40, 2, Soma_events_size); % 40 is just an estimate max. # of events occured 10s before and after a soma event
saved_pk_events_s = NaN(100, 100);

for j = 1: Soma_events_size
     if ((sorted_s_t0_tMax_Direction(sorted_soma_idx(j), 2))>10) && ((sorted_s_t0_tMax_Direction(sorted_soma_idx(j), 2))<(t-10)) %only calculate for soma events that happened 10 sec after recroding and 10 sec before recording ends
            pk_events_idx = find((sorted_s_t0_tMax_Direction(:,3))>(sorted_s_t0_tMax_Direction(sorted_soma_idx(j), 2)-10) & (sorted_s_t0_tMax_Direction(:, 3)) < (sorted_s_t0_tMax_Direction(sorted_soma_idx(j), 2)+10));
            for k = 1: size(pk_events_idx)
                Z(k,:,j) = sorted_s_t0_tMax_Direction(pk_events_idx(k), 3:4);
                Z(k,1,j) = Z(k,1,j) - sorted_s_t0_tMax_Direction(sorted_soma_idx(j),2);
            end
     else
         continue;
     end
end

s_filename = ('direction_20s_around_somaevents.xlsx');
Soma_events_idx_str = num2str(Soma_events_idx);

for w = 1: Soma_events_size
    A = Z(:,:,w);
    sheet = num2str(Soma_events_idx(w));
    xlswrite(s_filename, A, sheet);
end



