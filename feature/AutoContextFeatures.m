function F = AutoContextFeatures(P,offsets)

% ----------------------------------------------------------------------
% P 分割结果的概率图 offsets 选取如[2 4 8] 或其他的  参见autocontext 的原始文章
% ----------------------------------------------------------------------
F = [];
for r = offsets%[5 9 13]
    for a = 0:pi/4:2*pi-pi/4
        v = r*[cos(a) sin(a)];
        T = imtranslate(P,v,'OutputView','same');
        F = cat(3,F,T);
    end
end

end