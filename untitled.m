labp  = dir('./*.png');
for i=1:165
t(:,:,i) =  imread(labp(i).name);
end


ttt = imrotate(t,-90);ttt = flipud(ttt);
labnii = make_nii(ttt);
save_nii(labnii,'diff_color_cvlab.nii');


conObj = bwconncomp(t); % lab 为三维二值图像

multi_lab = zeros(size(t));

for i = 1:length(conObj.PixelIdxList)
 multi_lab(conObj.PixelIdxList{i}) = i;
end

%保存为NII形式
multi_lab = imrotate(multi_lab,-90);multi_lab = flipud(multi_lab);
t = make_nii(multi_lab);
save_nii(t,'diff_color_cvlab.nii');

tttb = uint8(zeros(size(multi_lab)));
labnii = make_nii(tttb);
save_nii(labnii,'black.nii');