function [fstData,secData] = processData(opts)

[trainImg ,labelImg] = loadData(opts);
pdsz = opts.padSize;
if(opts.fstSize~=1)
    fstImg=imresize(trainImg,opts.fstSize);
    fstLab=imresize(labelImg,opts.fstSize);
    fstImg = padarray(fstImg,[pdsz,pdsz,pdsz],'symmetric');
    fstLab = padarray(fstLab,[pdsz,pdsz,pdsz],'symmetric');
else
    fstImg=trainImg;
    fstLab=labelImg;
    fstImg = padarray(fstImg,[pdsz,pdsz,pdsz],'symmetric');
    fstLab = padarray(fstLab,[pdsz,pdsz,pdsz],'symmetric');
end

trainImg = padarray(trainImg,[pdsz,pdsz,pdsz],'symmetric');
labelImg = padarray(labelImg,[pdsz,pdsz,pdsz],'symmetric');
 
% let two stage lab img become 3 classes
% fstLab= threeClass(2,fstLab);
% labelImg = threeClass(3,labelImg);
% % smooth img
% hs = opts.hs;
% for tt = 1:size(fstImg,3)
%     fstImg(:,:,tt) = imfilter(imfilter(fstImg(:,:,tt),hs),hs');
% end 
% for tt = 1:size(trainImg,3)
%     trainImg(:,:,tt) = imfilter(imfilter(trainImg(:,:,tt),hs),hs');
% end 

fstData.img = fstImg;
fstData.lab = fstLab;
secData.img = trainImg;
secData.lab = labelImg;


end

function finalLab = threeClass(diskSize,label)

se=strel('disk',diskSize);
tempLab=imerode(label,se);
finalLab = single(tempLab);
finalLab(finalLab==1) = 2;
memb = logical(label - tempLab);
finalLab(memb) = 1;
%labelImg = finalLab;
end

