%--------------------------------------------------------------------------
%               读取examp11_02.xls中数据，进行主成分分析
%--------------------------------------------------------------------------

%**************************读取数据，并进行标准化变换************************
[X,textdata] = xlsread('examp11_02.xls');   %从Excel文件中读取数据
XZ = zscore(X);    %数据标准化


%**********************************主成分分析*******************************
% 调用princomp函数根据标准化后原始样本观测数据作主成分分析，返回主成分表达式的系数矩阵COEFF，
% 主成分得分数据SCORE，样本相关系数矩阵的特征值向量latent和每个观测的霍特林T2统计量
[COEFF,SCORE,latent,tsquare] = princomp(XZ)

% 为了直观，定义元胞数组result1，用来存放特征值、贡献率和累积贡献率等数据
% 这样做能以元胞数组形式显示result1的结果
explained = 100*latent/sum(latent);  %计算贡献率
[m, n] = size(X);  %求X的行数和列数
result1 = cell(n+1, 4);  %定义一个n+1行，4列的元胞数组
result1(1,:) = {'特征值', '差值', '贡献率', '累积贡献率'};
result1(2:end,1) = num2cell(latent);  %存放特征值
result1(2:end-1,2) = num2cell(-diff(latent));  %存放特征值之间的差值
result1(2:end,3:4) = num2cell([explained, cumsum(explained)]) %存放(累积)贡献率

% 为了直观，定义元胞数组result2，用来存放前2个主成分表达式的系数数据
% 这样做能以元胞数组形式显示result2的结果
varname = textdata(3,2:end)';  % 提取变量名数据
result2 = cell(n+1, 3);  % 定义一个n+1行，3列的元胞数组
result2(1,:) = {'标准化变量', '主成分Prin1', '主成分Prin2'}; % result2的第一行
result2(2:end, 1) = varname;  % result2的第一列
result2(2:end, 2:end) = num2cell(COEFF(:,1:2))  % 存放前2个主成分表达式的系数数据

% 为了直观，定义元胞数组result3，用来存放每一个地区总的消费性支出，以及前2个主成分的得分数据
% 这样做能以元胞数组形式显示result3的结果
cityname = textdata(4:end,1);  % 提取地区名称数据
sumXZ = sum(XZ,2);  %每一个地区总的消费性支出
[s1, id] = sortrows(SCORE,1);  % 将主成分得分数据按第一主成分得分从小到大排序
result3 = cell(m+1, 4);  %定义一个m+1行，3列的元胞数组
result3(1,:) = {'地区', '总支出', '第一主成分得分y1', '第二主成分得分y2'}; 
result3(2:end, 1) = cityname(id);  % result3的第一列，即排序后地区名
% 存放排序后每一个地区总的消费性支出，以及前2个主成分的得分数据
result3(2:end, 2:end) = num2cell([sumXZ(id), s1(:,1:2)])

% 为了直观，定义元胞数组result4，用来存放前2个主成分的得分数据，以及(衣着+医疗)-(食品+其他)
% 这样做能以元胞数组形式显示result4的结果
%计算(衣着+医疗)-(食品+其他)，即衣着和医疗的总支出减去食品和其他商品的总支出
cloth = sum(XZ(:,[2,7]),2) - sum(XZ(:,[1,8]),2);
[s2, id] = sortrows(SCORE,2);  % 将主成分得分数据按第一主成分得分从小到大排序
result4 = cell(m+1, 4);  %定义一个m+1行，3列的元胞数组
result4(1,:) = {'地区','第一主成分得分y1','第二主成分得分y2' ,'(衣+医)-(食+其他)'};
result4(2:end, 1) = cityname(id);  % result4的第一列，即排序后地区名
% 存放排序后前2个主成分的得分数据，以及(衣着+医疗)-(食品+其他)的数据
result4(2:end, 2:end) = num2cell([s2(:,1:2), cloth(id)])


%***************************前两个主成分得分散点图***************************
plot(SCORE(:,1),SCORE(:,2),'r*');  %绘制两个主成分得分的散点图，散点为黑色圆圈
xlabel('第一主成分得分');  %为X轴加标签
ylabel('第二主成分得分');  %为Y轴加标签
gname(cityname);   %交互式标注每个地区的名称


%**********************根据霍特林T2统计量寻找极端数据************************
% 将tsquare从小到大进行排序，并与地区名称一起显示
 [s5,id]=sortrows(tsquare);
  result5=cell(m+1,2);
  result5(1,:)={'地区','霍特林T^2统计量'};
  result5(2:end,1)=cityname(id);
  result5(2:end,2:end)=num2cell(s5)
  %另一种方法
   [s5,id]=sortrows(tsquare);
   result5=cell(m,2);
  result5(1:end,1)=cityname(id);
  result5(1:end,2:end)=num2cell(s5)
  [{'地区', '霍特林T^2统计量'}; result5]
%**************************调用pcares函数重建观测数据************************
% 通过循环计算E1(m)和E2(m)
for i = 1 : 8
     residuals = pcares(X, i);  % 返回残差
     Rate = residuals./X;  %计算相对误差
     E1(i) = sqrt(mean(residuals(:).^2));  %计算残差的均方根
     E2(i) = sqrt(mean(Rate(:).^2));  %计算相对误差的均方根
end
E1    %查看残差的均方根
E2    %查看相对误差的均方根