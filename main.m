%% be attention of the label , sometimes it is logical
% we can't make it be > 1, so change it to uint8 or single.
% use the parameter of 'Estimating CT Image From MRI Data Using
%               Structured Random Forest and Auto-Context Model'
% change the train label
% permute(t,[3,1,2]);  ���ǽ�volume ����X ��ʱ��ת90
%dataAll.inputImage2=permute(dataAll.inputImage,[3,1,2]);%ʸ״��
% dataAll.inputImage2=flipud(dataAll.inputImage2);%ͼ�����·�ת
% dataAll.inputImage3=permute(dataAll.inputImage,[3,2,1]);%��״��
% dataAll.inputImage3=flipud(dataAll.inputImage3);
%
% median
%% start
clear ;opts = init();
opts.reduceSize = 1; mlct = 1;
opts.fstSize = 0.5;pdsz=opts.padSize;
opts.useMoreContext = 0;opts.useFisherScore = 0;
model=opts.modelName; %offset = opts.offset;ranPoints = opts.ranPoints;

opts.start = 1;opts.useParfor=1;
opts.iter = 1;

opts.dirt{1} = [3,1,2]; opts.dirt{2} = [3,2,1];
opts.reDirt{1} = [2,3,1];opts.reDirt{2} = [3,2,1];
opts.train = 1;[fdata,~]= processData(opts);
opts.saveStagePro = 1;

%% first Iteration use tradition forest
fprintf('---------begin fst iter classic----------- \n');
opts.stage = 1;opts.delFt = 0;
%first stage use half of allImg . cm:classic model
cm = train(fdata,opts);
smn = strcat('./model/',model{mlct},'.mat');mlct=mlct+1;save(smn,'cm');
[fdata.pro,~]= traOriPredict(fdata.img,cm,opts);
opts.iter = opts.iter+1;
subNum = 3;show_saveImg(fdata,1,25,subNum,1,opts);subNum=subNum+1;

[m,n,o] = size(fdata.pro);protemp = zeros([3,m*n*o],'single');
proNum = 1;protemp(proNum,:) = fdata.pro(:);proNum=proNum+1;

%% first Iteration ac
fprintf('-----------begin tradition autocontext--------- \n');
fdata.dirtPro=[];
for i =1 :2
    if(i==2),fdata.pro  = reshape(max(protemp,[],1),[m,n,o]);end
    errorIds=chooseFaultSample(fdata,opts.padSize);
    opts.start=opts.start+1;
    
    [acM,opts]=exeTraAc_img(fdata,opts,errorIds);
    smn = ['./model/',model{mlct},'.mat'];mlct=mlct+1;save(smn,'acM');
    
    [fdata.pro,fdata.res]=exeTraAcPre_img(fdata.img,fdata.pro,acM,opts);
    opts.iter = opts.iter+1;
    clear acM
       
    protemp(proNum,:) = fdata.pro(:);proNum=proNum+1;
    
    show_saveImg(fdata,1,25,subNum,0,opts);subNum=subNum+1;
    fprintf('--------------------------------------------------\n');
end

%% median ac
opts.start = 1;
for i =1:4
    if(mod(i,2)==1),midPro=median(protemp,1);
    else ,midPro=median(protemp,1); end
    
    midPro=reshape(midPro,[m,n,o]);fdata.pro=midPro;
    errorIds = chooseFaultSample(fdata,opts.padSize);
    [acM,opts] = exeSTAC_img(fdata,opts,errorIds);
    smn=strcat('./model/',model{mlct},'.mat');mlct=mlct+1;save(smn,'acM');
    [fdata.pro,fdata.res]=exeSACpre_img(fdata.img,fdata.pro,acM,opts);
    opts.iter = opts.iter+1;

    proNum = 1;protemp(proNum,:) = fdata.pro(:);proNum=proNum+1;
    
    show_saveImg(fdata,1,25,subNum,0,opts);subNum=subNum+1;
    opts.start = opts.start+1;
    fprintf('-----------struct median img done. ------------- \n');
end

save('./result/opts.mat','opts');
%% test stage
opts.train  = 0;
testData  = test(opts) ;
saveData2nii(testData);

% lab = testData.res; lab = imfill(lab,'holes');
% se = strel('disk',10);% closeBW = imclose(lab,se);

GT = testData.lab(:);PRE= testData.pro(:)>0.5;
eval = evalute_segment_performance(GT, PRE)
fprintf('mean zongti voc is %f \n',eval.voc);
save('./result/evalAll.mat','eval');
evalAll =[];
for i = 1: size(testData.img,3)
    GT = testData.lab(:,:,i);
    PRE= testData.pro(:,:,i)>0.5;
    eval = evalute_segment_performance(GT(:), PRE(:));
    evalAll = cat(2,evalAll,eval);
    
    % figure(12),imshow(testData.img(:,:,i),[]);
    %title([num2str(i),'th pic']);
    % hold on ,contour(testData.lab(:,:,i)>0.5,'r');
    % hold on, contour(testData.pro(:,:,i)>0.5,'g');
    % %  allTestLabel(:,:,i) = imread(test_labelname);
    %    name = ['./result/finalResult/final_' num2str(i) '.jpg'];
    %  % imwrite(finalResult2(:,:,i),name);
    %         saveas(figure(12),name);
end
fprintf('this code is no fanzhaun');
printTestResult(evalAll);
save('./result/evalEach.mat','evalAll');
gt = testData.lab;res=testData.pro>0.5;
fprintf('mean boss qianjing voc is %f \n', ...
    sum(sum(sum(gt.*res)))/sum(sum(sum(or(gt,res)))));
fprintf('mean boss beijing voc is %f \n', ...
    sum(sum(sum(~gt.*~res)))/sum(sum(sum(or(~gt,~res)))));
% fprintf('mean boss qianjing voc is %f \n', ...
%     sum(sum(sum(gt.*res3)))/sum(sum(sum(or(gt,res3)))));
%disp('zhu shi le min shishi  shifou you xiao');