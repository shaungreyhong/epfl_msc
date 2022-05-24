function peaks = findmaxpoints(signal, LIMIT)

% PPG: LIMIT = 15;
% OMW(E): LIMIT = 5;

cnt = 1;
sign_f = -1;
peaks = zeros(length(signal) - 1, 1);

for i = 1:length(signal) - LIMIT
    f_range = min(i - 1, LIMIT);
    for j = 1:f_range
        sign_f(j) = signal(i) - signal(i - j);
    end
    
    sign_r = zeros(LIMIT, 1);
    for j = 1:LIMIT
        sign_r(j) = signal(i + j) - signal(i);
    end
    
    if all(sign_f >= 0) && all(sign_r <= 0)
        peaks(cnt) = i;
        cnt = cnt + 1;
    end
end
peaks = peaks(1:find(peaks == 0, 1) - 1);
end