function proMit_inter = processVolume(volumeRes,pdsz,imgSz,gtRidus)
% pl: pad  layer number
% nl: number of layer.
%ind: maskind

[r,c,numPic] = size(volumeRes);

rInd=unique([pdsz+1:2:r-pdsz,r-pdsz]);cInd=unique([pdsz+1:2:c-pdsz,c-pdsz]);
z = unique([pdsz+1:2:numPic-pdsz,numPic-pdsz]);

volume=volumeRes(rInd,cInd,z);

r1=imgSz.r; c1=imgSz.c;numPic1 = imgSz.numPic1;

[x1,y1,z1] = meshgrid(cInd-pdsz,rInd-pdsz,z-pdsz);
[x2,y2,z2] = meshgrid(1:c1,1:r1,1:numPic1);
proMit_inter = interp3(x1,y1,z1,volume,x2,y2,z2);

    
    