function printTestResult(evalAll)

t3 = evalAll';
s1 = cell2mat(struct2cell(t3));
pc = mean(s1(1,:));acc = mean(s1(5,:));
dsc = mean(s1(3,:));fval = mean(s1(6,:));
recall = mean(s1(2,:));
jar = mean(s1(4,:));
voc = mean(s1(7,:));
fprintf('mean precision is %f \n',pc);
fprintf('mean recall is %f \n',recall);
fprintf('mean acc is %f \n',acc);
fprintf('mean dsc is %f \n',dsc);
fprintf('mean fval is %f \n',fval);
fprintf('mean jar is %f \n',jar);
fprintf('mean voc is %f \n',voc);



