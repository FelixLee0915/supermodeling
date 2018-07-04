%--------------------------------------------------------------------------
%               读取examp09_02.xls中数据，进行样品系统聚类
%--------------------------------------------------------------------------

%***************************读取数据，并进行标准化***************************
[X,textdata] = xlsread('examp09_02.xls');    % 从Excel文件中读取数据
X = zscore(X);    % 数据标准化（减去均值，除以标准差）


%*********************调用clusterdata函数进行一步聚类************************
obslabel = textdata(2:end,1);   % 提取城市名称，为后面聚类做准备
% 样品间距离采用欧氏距离，利用类平均法将原始样品聚为3类，Taverage为各观测的类编号
Taverage = clusterdata(X,'linkage','average','maxclust',3);
obslabel(Taverage == 1)    % 查看第1类所包含的城市

obslabel(Taverage == 2)    % 查看第2类所包含的城市


obslabel(Taverage == 3)    % 查看第3类所包含的城市


%******************************* 分步聚类 **********************************
y = pdist(X);    % 计算样品间欧氏距离，y为距离向量
Z = linkage(y,'average')    % 利用类平均法创建系统聚类树

obslabel = textdata(2:end,1);    % 提取城市名称，为后面聚类做准备
% 绘制聚类树形图，方向从右至左，显示所有叶节点，用城市名作为叶节点标签，叶节点标签在左侧
H = dendrogram(Z,0,'orientation','right','labels',obslabel); % 返回线条句柄H
set(H,'LineWidth',2,'Color','k');    % 设置线条宽度为2，颜色为黑色
xlabel('标准化距离（类平均法）')    % 为X轴加标签

inconsistent0 = inconsistent(Z,40)    % 计算不一致系数，计算深度为40
