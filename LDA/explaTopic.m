%EXPLATOPIC explain topics by sorting words accroding to their occuring
%  probability given corresponding topic.

function explaTopic()
global Corp; global Model;
global Pw_z;

dict = textread();
if Model.T < 40,
for i=1:3,
    [temp, order_idx] = sort(Pw_z(:,i), 'descend');
    fprintf('Topic %d:\n', i);

    for j=1:Model.topword,
        fprintf('%s : %f\n',dict(order_idx(j)).word,Pw_z(order_idx(j),i));
    end
end
end
