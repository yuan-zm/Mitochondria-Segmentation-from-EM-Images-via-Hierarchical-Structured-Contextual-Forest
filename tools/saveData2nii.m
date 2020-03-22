function saveData2nii(testData)

lab = single(testData.lab);
lab(lab == 1) = 5;
re = lab - single(testData.res);
re(re == -1) = 3;re(re == 4) = 2;re(re == 5) = 1;
ttt = imrotate(re,-90);ttt = flipud(ttt);
tttt = make_nii(uint8(ttt));save_nii(tttt,'./niiShow/resLab2.nii');
% ttt = false(size(lab)); 
% tttt = make_nii(uint8(ttt));save_nii(tttt,'./niiShow/background.nii');
% ttt = imrotate(testData.img,-90);ttt = flipud(ttt);
% tttt = make_nii(uint8(ttt));save_nii(tttt,'./niiShow/mit.nii');
% ttt = imrotate(testData.lab,-90);ttt = flipud(ttt);
% tttt = make_nii(uint8(ttt));save_nii(tttt,'./niiShow/mitlab.nii');
% ttt = imrotate(testData.res,-90);ttt = flipud(ttt);
% tttt = make_nii(uint8(ttt));save_nii(tttt,'./niiShow/mitres.nii');
