function [haarCtRd , allHaarLbp, haarRand ,hmv] = getHaarFt(imgPa,haar)

[Ny,Nx,Nz,zz] = size(imgPa); imgPa = single(imgPa);
haarCtRd=[] ;haarRand=[];hmv=[];
allHaarLbp=[];
fN = {'h3d.mat','h5d.mat'};%,'h5.mat'
for numH =1:size(fN,2)
    options.rect_param = importdata(fN{numH});
    options.F = haar_featlist(Ny,Nx,Nz,options.rect_param);
    options.usesingle = 1;
    numIter = ceil(zz / 1000);
    allHaar = zeros([zz,size(options.F,2)],'single');
    for  j = 1:numIter
        if(j~=numIter)
            allHaar((j-1) * 1000 + 1:j*1000,:) = haar_3D(imgPa(:,:,:,(j-1) * 1000 + 1 : j*1000) , options)';
        else
            allHaar((j-1)*1000 + 1:end,:) = haar_3D(imgPa(:,:,:,(j-1) * 1000 + 1:end),options)';
        end
    end
    hwidth = options.rect_param(11);
    allHaar = allHaar / hwidth/hwidth/hwidth;
    
    %haar1 = allHaar(:, ind1) ;
    % teacher's haar 3
    haart1 = allHaar(:, haar.ind1{numH});
    haart2 = allHaar(:, haar.ind2{numH});
    haarRand1 = (haart2 - haart1);
    haarRand =  [haarRand,haarRand1];
    
    % teacher's haar 1
    haarCenter = allHaar(:, haar.center{numH});
    haarLbpPix = allHaar(:, haar.LbpInd{numH});
    haarLbpRlt = haarCenter > haarLbpPix;
    allHaarLbp1 = zeros([size(haarLbpRlt,1),1],'single');
    for row = 1:size(haarLbpRlt,1)
        temp = 0;
        for j = 1:size(haarLbpRlt,2)
            temp = temp + haarLbpRlt(row,j)* 2^(j-1);
        end
        allHaarLbp1(row,1) = temp;
    end
    allHaarLbp = [allHaarLbp,allHaarLbp1];
    % teacher's haar 2 center- random points
    haarCtRd1 = haarCenter - allHaar(:, haar.randPoints{numH});
    haarCtRd = [haarCtRd,haarCtRd1];
    %haar mean value of sub-region  hmv: haar mean value
    hmv1 =  allHaar(:, haar.randPoints{numH});%allHaar(:,haar.ind1{numH});
    hmv=[hmv,hmv1];
end


