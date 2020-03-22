function fdata = test(opts)

[fdata,~] =  processData(opts);mlct=1;
pdsz = opts.padSize;model = opts.modelName;
%% first Iteration
opts.stage = 1;[m,n,o] = size(fdata.img);
protemp = zeros([3,m*n*o],'single');

opts.iter = 1;

smn = strcat('./model/',model{mlct},'.mat');mlct=mlct+1;
cm = importdata(smn);
[proMit,~]= traOriPredict(fdata.img,cm,opts);
opts.iter = opts.iter+1;

fdata.pro = proMit;

proNum = 1;protemp(proNum,:) = proMit(:);proNum=proNum+1;

subNum = 3;show_saveImg(fdata,2,25,subNum,1,opts);subNum=subNum+1;


for i =1 :2
    if(i==2),fdata.pro  = reshape(max(protemp,[],1),[m,n,o]);end
    
    smn=['./model/',model{mlct},'.mat'];mlct=mlct+1;acM = importdata(smn);
    
    [fdata.pro,fdata.res]=exeTraAcPre_img(fdata.img,fdata.pro,acM,opts);clear acM
    opts.iter = opts.iter+1;

    
    protemp(proNum,:) = fdata.pro(:);proNum=proNum+1;
    
    
    show_saveImg(fdata,2,25,subNum,0,opts);subNum=subNum+1;
    
    
end

for i =1:4
    if(mod(i,2)==1)
        midPro=median(protemp,1);
    else
        midPro=median(protemp,1);
    end
    
    midPro=reshape(midPro,[m,n,o]);fdata.pro=midPro;
    smn = ['./model/',model{mlct},'.mat'];mlct=mlct+1;
    acM = importdata(smn);
    
    [fdata.pro,fdata.res]=exeSACpre_img(fdata.img,fdata.pro,acM,opts);
    proNum = 1;protemp(proNum,:) = fdata.pro(:);proNum=proNum+1;
    opts.iter = opts.iter+1;

    show_saveImg(fdata,2,25,subNum,0,opts);subNum=subNum+1;
    fprintf('-----------struct median predict done. ------------- \n');
end



fdata.res = fdata.pro>0.5;
fdata.pro = fdata.pro(pdsz+1:end-pdsz,pdsz+1:end-pdsz,pdsz+1:end-pdsz);
fdata.lab = fdata.lab(pdsz+1:end-pdsz,pdsz+1:end-pdsz,pdsz+1:end-pdsz);
fdata.img = fdata.img(pdsz+1:end-pdsz,pdsz+1:end-pdsz,pdsz+1:end-pdsz);
fdata.res = fdata.res(pdsz+1:end-pdsz,pdsz+1:end-pdsz,pdsz+1:end-pdsz);
save('./result/testdataTail.mat','fdata');

