
function opts = init()
%opts.negRatio = 5; pos: neg  = 1 : 5 in train
%
addpath('feature');addpath('tools');
addpath('autocontext');addpath(genpath('toolbox'));
addpath('haar');addpath(genpath('NIfTI'));
addpath(genpath('traForest'));addpath(genpath('structForest'));
addpath(genpath('BM3D'));

% save tree tempory, want use parfor,if don't use parfor don't need this 
opts.treeFn = './treeTempFolder/';

opts.acIter = 8;  opts.treeNum = 15;
opts.appRio = 0.5;opts.conRio = 0.5; 

%negRatio: early stage %negRatio2: late stage many neg samples are useless
opts.negRatio = 1.5;opts.negRatio2 =1.5;

opts.nPos = 7e5;opts.nNeg = 7e7;
opts.stride = 3;opts.padSize=20;opts.stride2=4;
opts.boundary = 5;

%for struct forst
opts.nSamples{1} = 256;opts.nSamples{2} = 128;

opts.gtWidth{1} =9;opts.gtWidth{2} = 7;
opts.discretize='pca';
opts.preRidues=5;

opts.secFisherACInd = cell(opts.acIter,1);
opts.hs = fspecial('gaussian',[3,1],0.3);

opts.acPatchS{1} = 11; opts.acPatchS{2} = 3;
opts.patchSize{1} = 11;  opts.patchSize{2} = 15;

% haar init fp(i)hs:fst pro(img) haar size. 1:stage 1
opts.phs{1} = 11;opts.phs{2} = 11;
opts.ihs{1} = 11;opts.ihs{2} = 11;

opts.hrfp = getHaarInd(opts.phs{1});opts.hrsp = getHaarInd(opts.phs{2});
opts.hrfi = getHaarInd(opts.ihs{1});opts.hrsi = getHaarInd(opts.ihs{2});


opts.modelName = {'noACFst','acFst','oriACModel_2','oriACModel_3',...
    'oriACModel_4','oriACModel_5','oriACModel_6','oriACModel_7','oriACModel_8'};
% opts.offset = {[7,5,9,12,15,17,3],[7,4,10,12,16,17,3],...
%     [7,2,9,12,16,18,3],[7,4,9,12,15,17,3],[7,5,9,12,15,17,2],...
%     [3,7,5,9,12,15,17,2,3],[3,7,5,9,12,15,17,25,3],[3,7,5,9,12,15,17,25,3]};
% opts.ranPoints{1,size(opts.offset,2)} = [];
% 
% for i = 1:size(opts.offset,2)
%     num_points = size(opts.offset{i},2) * 8;
%     opts.ranPoints{i} = randperm(num_points,round(num_points / 1.5));
% end
% temp = opts.ranPoints;save('./model/ranPoints.mat','temp','-v7.3');
% 

opts.haarFile  = './haar/indFile/';

opts.trainImgFolder = '../cvlabData/trainCvlab/img/';
opts.trainAnnFolder = '../cvlabData/trainCvlab/lab/';
opts.testImgFolder = '../cvlabData/testCvlab/img/';
opts.testAnnFolder = '../cvlabData/testCvlab/lab/';

if(~exist('./model','dir')), mkdir('./model'); end
if(~exist('./result','dir')), mkdir('./result'); end
if(~exist('./result/finalComRe','dir')), mkdir('./result/finalComRe'); end
if(~exist('./result/mit_membComRe','dir')), mkdir('./result/mit_membComRe'); end
if(~exist('./result/sss','dir')), mkdir('./result/sss'); end
if(~exist('./result/stagePro','dir')), mkdir('./result/stagePro'); end
if(~exist(opts.haarFile,'dir')), mkdir(opts.haarFile); end


end

