clc; clear all; close all;

PATH = 'D:\Back_up\산학과제\삼성_종기원\DB\19_DB\ToHanyang\';
FILE_LIST = dir(fullfile(PATH,'*.mat'));
LIST_L_DATA = length(FILE_LIST(:, 1));

DIM = 1 + 28 ;

load('filter_option.mat');
% # Code 1: FIR 필터 초기화
% 힘,토크 필터
SP.force_filter.order = 3;
SP.force_filter.fc = .2/(THIS.FS_FORCE/2);
SP.force_filter.type = 'low';

% PPG DC 필터
SP.ppg_dc_filter.order = 3;
SP.ppg_dc_filter.fc = .2/(THIS.FS_PPG/2);
SP.ppg_dc_filter.type = 'low';

% PPG AC 필터
SP.ppg_ac_filter.order = 3;
SP.ppg_ac_filter.fc = [.8 8]/(THIS.FS_PPG/2);
SP.ppg_ac_filter.type = 'bandpass';

% [b, a] = fir1(440, 0.5/33, 'high');
[b, a] = butter(SP.ppg_ac_filter.order, SP.ppg_ac_filter.fc, SP.ppg_ac_filter.type);
% # Code 1: FIR 필터 초기화

MANUAL_SBP = []; MANUAL_DBP = []; err_mat = []; ppg_sum = []; outlier = [];
FEATURE_MATRIX = zeros(LIST_L_DATA, DIM + 2);
feat_taejun = zeros(LIST_L_DATA,  10);
err_mat = []; outler = [];
ind_cnt = 1;
len_t = [];
subj = [];
for ch = 5:5
    for file = 1:LIST_L_DATA
%     for file = 1:10
        file
        FILE_FULLNAME = FILE_LIST(file).name;
        load([PATH FILE_FULLNAME]);

        % # Code 2: 필터 적용
        ppg_filt = filtfilt(b, a, THIS.PPG1_RAW(:, ch));
        % # Code 2: 필터 적용

        ID = THIS.SUBJECT;
        NUM = THIS.CASE;
        SBP = THIS.BP_REF(1);
        DBP = THIS.BP_REF(2);
        ID_INFO = [THIS.AGE THIS.SEX THIS.HEIGHT THIS.WEIGHT];
        subj = [subj; ID];
        
        time_ppg = THIS.TIME_PPG;
        time_force = THIS.TIME_FORCE;

        % # Code 3: PPG-FORCE 싱크 맞춤
        ind_force_time = zeros(length(time_ppg), 1);
        time_force = floor(time_force*10000)/10000;
        for i = 1:length(time_ppg)
            current_ppg_time = floor(time_ppg(i)*10000)/10000;
            [val, ind] = min(abs(time_force - current_ppg_time));
            ind_force_time(i) = ind;
        end
        
        ppg_filt = ppg_filt(25*ceil(THIS.FS_PPG) + 1:65*ceil(THIS.FS_PPG));
        ind_force_time = ind_force_time(25*ceil(THIS.FS_PPG) + 1:65*ceil(THIS.FS_PPG));
%         force = abs(THIS.FORCE(ind_force_time, 3));
        % # Code 3: PPG-FORCE 싱크 맞춤
        
        force = THIS.FORCE(ind_force_time, :);
%         feat_FPCR = sf_featFPCR_HIE2_SAIT_v001(ppg_filt, abs(force(:, 3)));
%         FORCE=abs(force(:, 3));
        [feat_base, err, ppg_dif] = f_feat_base(ppg_filt, abs(force(:, 3)));
        [feat_force, len] = f_feat_force(ppg_filt, abs(force(:, 3)));
%         feat_bbb = f_feat_bbb(ppg_filt, force, THIS.FS_PPG);
        
        err_mat = [err_mat;err];
        outlier = [outlier;ppg_dif];
        
%         feat = [feat_base feat_force feat_FPCR ID_INFO];
%         feat = [feat_base feat_force ID_INFO];
        feat = [feat_base(1:end-10) feat_force ID_INFO];
        
        
        FEATURE_MATRIX(ind_cnt, :) = [ind_cnt NUM ID feat];
        
        feat_taejun(ind_cnt, :)=feat_base(end-9:end);
        
        MANUAL_SBP = [MANUAL_SBP;SBP];
        MANUAL_DBP = [MANUAL_DBP;DBP];
        ind_cnt = ind_cnt + 1;
    end
end

%%

% FEATURE_MATRIX(:, 25 + 1:26 + 1) = [];
% FEATURE_MATRIX(:, 20 + 1:21 + 1) = [];

FEATURE_MATRIX(:, 22 + 3:24 + 3) = [];
FEATURE_MATRIX(:, 17 + 3:19 + 3) = [];
FEATURE_MATRIX(:, 11 + 3:13 + 3) = [];
FEATURE_MATRIX(:,  7 + 3: 9 + 3) = [];
FEATURE_MATRIX(:,  4 + 3 ) = [];
FEATURE_MATRIX(:,  1 + 3: 2 + 3) = []; % 1.5538



load('SAIT_FEATURE_20190830.mat');
FEATURE_MATRIX = [FEATURE_MATRIX f1];

load('SAIT_FEATURE_20190903.mat');
FEATURE_MATRIX = [FEATURE_MATRIX f190903];
FEATURE_MATRIX(:, 25) = []; % 종기원 제공 feature 중복된 것 제거
FEATURE_MATRIX(:, 20) = []; % 몸무게 중복 제거

FEATURE_MATRIX = [FEATURE_MATRIX feat_taejun]; % corr 측정, SBP 추정 성능 확인


% load('OUTLIER_SAIT_PHASE2_PIC.mat');
% load('OUTLIER_SAIT_PHASE2_SIG.mat');
load('log_outlier_20190822103225.mat');

% cases = FEATURE_MATRIX(:, 2);
% outpic_len = length(case_idx);
% ind = [];
% for i = 1:outpic_len
%     ind = [ind; find(case_idx(i) == cases)];
% end

% outsig_len = length(outlier_signal_case);
% for i = 1:outsig_len
%     ind = [ind; find(outlier_signal_case(i) == cases)];
% end

% FEATURE_MATRIX(ind, :) = [];
% MANUAL_SBP(ind) = [];
% MANUAL_DBP(ind) = [];
% err_mat(ind) = [];
% outlier(ind) = [];

cases = FEATURE_MATRIX(:, 2);
out_len = length(case_idx);
feat = []; sbp = []; dbp = []; err = []; out = [];
for i = 1:out_len
    ind = find(case_idx(i) == cases);
    feat = [feat; FEATURE_MATRIX(ind, :)];
    sbp = [sbp; MANUAL_SBP(ind)];
    dbp = [dbp; MANUAL_DBP(ind)];
    err = [err; err_mat(ind)];
    out = [out; outlier(ind)];
end

FEATURE_MATRIX = feat;
MANUAL_SBP = sbp;
MANUAL_DBP = dbp;
err_mat = err;
outlier = out;

FEATURE_MEDIAN = FEATURE_MATRIX;
TARGET_SBP = MANUAL_SBP;
TARGET_DBP = MANUAL_DBP;

% err_ind = find(err_mat > 10.0)
% out_ind = find(outlier > 0.30)
save('feat_190904.mat', 'FEATURE_MEDIAN', 'TARGET_SBP', 'TARGET_DBP', 'err_mat', 'outlier');

c1=corr(FEATURE_MATRIX(:,24), TARGET_SBP);
c2=corr(FEATURE_MATRIX(:,25), TARGET_SBP);
c3=corr(FEATURE_MATRIX(:,26), TARGET_SBP);
c4=corr(FEATURE_MATRIX(:,27), TARGET_SBP);
c5=corr(FEATURE_MATRIX(:,28), TARGET_SBP);
c6=corr(FEATURE_MATRIX(:,29), TARGET_SBP);
c7=corr(FEATURE_MATRIX(:,30), TARGET_SBP);
c8=corr(FEATURE_MATRIX(:,31), TARGET_SBP);
c9=corr(FEATURE_MATRIX(:,32), TARGET_SBP);
c10=corr(FEATURE_MATRIX(:,33), TARGET_SBP);
c=[c1 c2 c3 c4 c5 c6 c7 c8 c9 c10];

aa=corr(FEATURE_MATRIX, TARGET_SBP);


