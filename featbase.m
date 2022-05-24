function [feat, err, ppg_dif] = featbase(ppg_filt, FORCE)
% # Code 4: PPG-FORCE OMW envelope (OMWE) 생성
% PPG 피크 검출
ppg_filt_pks = f_findpeaks_JY_PPG(ppg_filt);
ppg_OMWE = ppg_filt(ppg_filt_pks);

%taejun
ppg_filt_foots = f_findpeaks_JY_PPG(-1*ppg_filt);

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

OMW_pks = f_findpeaks_JY_PPG_OMW(OMW);
if(isempty(OMW_pks) == 1)
    OMW_pks = 1;
end

[OMW_max, OMW_ind] = max(OMW(OMW_pks));
OMW_pks = OMW_pks(OMW_ind);

[PPG_max, PPG_ind]=max(ppg_filt(ppg_filt_pks));
idd=ppg_filt_pks(PPG_ind);

% 무게중심점 변화
% mn=2;
% kkk=1;
% tj_feat=[];
% for k=OMW_pks-mn : OMW_pks+mn
%     tj_feat(kkk)=ppg_filt(ppg_filt_pks(k)) ./ ppg_filt(ppg_filt_foots(k));
%     kkk=kkk+1;
% end


% Peak 인근 heart rate
ml=1;
mr=8;

kkk=1;
tj_feat=[];

for k=OMW_pks-ml : OMW_pks+mr
% for k=OMW_pks-ml : 34
%     tj_feat(kkk)=ppg_filt(ppg_filt_pks(k)) ./ ppg_filt(ppg_filt_foots(k));

%     tj_feat(kkk)=( ppg_filt(ppg_filt_foots(k)) - ppg_filt(ppg_filt_foots(k-1)) ) / 65.5556;
    
    tj_feat(kkk)=1 ./ ( ppg_filt_foots(k) - ppg_filt_foots(k-1) );
    kkk=kkk+1;
end
% tj_feat(kkk)=length(ppg_filt_foots) - OMW_pks;

% plot(OMW); hold on;
% scatter(OMW_pks, OMW(OMW_pks));

% # Code 5: OMWE 끝점 검출
[cnts, cntrs] = hist(OMW);
[cnts_max, cnts_ind] = max(cnts);
threshold = cntrs(cnts_ind);
threshold = threshold*2.0;

for i = (OMW_pks + 1):length(OMW)
    if(OMW(i) < threshold)
        saturation_point = i;
        break;
    end
end

% 2019/02/13 1 ch PPG를 위해서 추가함
if(i == length(OMW))
    saturation_point = i;
end
% # Code 5: OMWE 끝점 검출

% plot(OMW); hold on;
% scatter(OMW_pks, OMW(OMW_pks));
% scatter(saturation_point, OMW(saturation_point));

OMW(saturation_point + 1:end) = [];

% # Code 6: 상이한 신호 제거를 위한 루틴 - 신호 에러 계산
FORCE_sg = sgolayfilt(FORCE, 3, 501);
err = sqrt(sum(abs(FORCE_sg(1:1000) - FORCE(1:1000))));
% # Code 6: 상이한 신호 제거를 위한 루틴 - 신호 에러 계산

ppg_dif = median(ppg_filt(ppg_filt_pks(end - 4:end)))/ppg_filt(ppg_filt_pks(OMW_pks));

% # Code 7: 특징 벡터 추출
AE = sum(OMW);

EL = length(OMW);
EL_FORCE = FORCE(ppg_filt_pks_sort(saturation_point)) - FORCE(ppg_filt_pks_sort(1));

MA = OMW(OMW_pks);
MAPL = OMW_pks;
MAPL_FORCE = FORCE(ppg_filt_pks_sort(OMW_pks));

AR = (MAPL)/EL;
AR_FORCE = MAPL_FORCE/EL_FORCE;

[MnA, MnAPL] = min(OMW);
MA = (MA - MnA);

ppg_force_oscillo = OMW;
left_envelope = ppg_force_oscillo(1:MAPL);
right_envelope = ppg_force_oscillo(MAPL:end);

left_std = std(left_envelope);
left_force = FORCE(ppg_filt_pks_sort(MAPL)) - FORCE(ppg_filt_pks_sort(1));

right_std = std(right_envelope);
right_len = length(right_envelope);
right_force = FORCE(ppg_filt_pks_sort(saturation_point)) - FORCE(ppg_filt_pks_sort(MAPL));

% feat = [log(AE + eps) EL EL_FORCE log(MA + eps) MAPL MAPL_FORCE AR AR_FORCE log(left_std + eps) left_force log(right_std + eps) right_len right_force];
feat = [log(AE + eps) EL EL_FORCE log(MA + eps) MAPL MAPL_FORCE AR AR_FORCE log(left_std + eps) left_force log(right_std + eps) right_len right_force tj_feat];
% # Code 7: 특징 벡터 추출
end