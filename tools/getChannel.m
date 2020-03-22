function channel = getChannel(img)


k= 1;channel{k} = img; k = k + 1;
[Ix,Iy] = gradient(img);
channel{k} = Ix; k = k + 1;
channel{k} = Iy; k = k + 1;
Ix_y_sqrt_train = sqrt(Ix.^2 + Iy.^2);
channel{k} = Ix_y_sqrt_train;% k = k + 1;
%channel{k} = single(getLbpImg(img)); %k = k + 1;
channel=cat(4,channel{1:k});
end


function lbpImg = getLbpImg(oriImg)
[M,N] = size(oriImg);
neighbourNum = 2;
labMatrix = zeros(M + neighbourNum,N + neighbourNum);
labMatrix(2:end-1,2:end-1) = oriImg;
SP = [-1 -1;-1 0;-1 1;0 -1;0 1; 1 -1; 1 0; 1 1];
lbpImg = lbp(labMatrix,SP,0,'i');
end