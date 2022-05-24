function [feat, len] = featforce(ppg_filt, FORCE)
ppg_filt_pks = f_findpeaks_JY_PPG(ppg_filt);
            
ppg_OMWE = ppg_filt(ppg_filt_pks);
len = length(ppg_filt_pks);

% plot(ppg_filt); hold on;
% scatter(ppg_filt_pks, ppg_filt(ppg_filt_pks));

ppg_filt_pks = [ppg_filt_pks;length(ppg_filt)];
vq1 = interp1(ppg_filt_pks, ppg_filt(ppg_filt_pks), [ppg_filt_pks(1):length(ppg_filt)]);

x = 1:length(vq1);
y = vq1;
h = 80;

for i = 1:length(x)
    xs(i) = i;
    ys(i) = f_func_gkr(xs(i), x, y, h);
end
OMW = ys;
OMWE = OMW;

% figure(1);
% plot(OMWE); hold on;


% figure(2);
% spectrogram(OMWE, hamming(54), 27, 32, 'yaxis'); hold on;
% 
% figure(3);
% spectrogram(ppg_filt, hamming(54), 27, 32, 'yaxis'); hold on;

% # Code 4: PPG-FORCE OMW envelope (OMWE) 생성
% PPG 피크 검출
ppg_filt_pks = f_findpeaks_JY_PPG(ppg_filt);
ppg_OMWE = ppg_filt(ppg_filt_pks); 

% FORCE 
[B, I] = sort(FORCE(ppg_filt_pks));
ppg_filt_pks_sort = ppg_filt_pks(I);

OMW_base = ppg_filt(ppg_filt_pks_sort);

if(OMW_base(2) < OMW_base(1))
    OMW_base(1) = [];
end
if(OMW_base(2) < OMW_base(1))
    OMW_base(1) = [];
end

% OMWE 스무딩
OMW = sgolayfilt(OMW_base, 3, 11);
% # Code 4: PPG-FORCE OMWE 생성

% Pulse의 사다리꼴 면적으로 OMW의 Y값을 대체
% OMW_pulse(1)=OMW(1);
% for k=2:size(OMW,1)
% 	OMW_pulse(k) = 0.5*(OMW(k)+OMW(k-1));
% end
% OMW=OMW_pulse;

% OMWE 피크 검출
OMW_pks = f_findpeaks_JY_PPG_OMW(OMW);
if(isempty(OMW_pks) == 1)
    OMW_pks = 1;
end

[OMW_max, OMW_ind] = max(OMW(OMW_pks));
OMW_pks = OMW_pks(OMW_ind);

% 특징 벡터 추출
OMW = OMWE;
point = [1; 2; 3; 4; 5; 6];
focus = zeros(6, 1);
for i = 1:6
    diff = FORCE - point(i);
    [min_val, min_ind] = min(abs(diff));
    focus(i) = min_ind;

    if(focus(i) > length(OMW))
        focus(i) = length(OMW);
    end
end

partial_focus = zeros(5, 1);
partial_p = zeros(5, 1);
for i = 1:5
    partial_focus(i) = OMW(focus(i + 1)) - OMW(focus(i));
end

focus_mat = partial_focus';
focus_ind = focus';
focus_val = OMW(focus);

focus_val(find(focus_val < 0)) = 0;

feat = [log(focus_val + eps) focus_mat];
end



