%function lrlasso(feature_file, topics)
%
% LRLASSO implenments linear regression with sparse learning. More
% specifically, it achieves two sparse learning algorithms, i.e.,
% coordinate descent for lasso (aka shooting algorithm) and iterative
% soft thresholding.
%
% Date: 12/22/2012


%----Debug------
topics = 12000; % count of total unique words
feature_file = '../features/review_features.tf-idf.txt';
%---------------

% (1) Initialization
% ==================
mt_choice = 'CD';
%mt_choice = 'IST';

ft_dim = topics;
tr_rate_file = '../datasets/train_review.rate';
tst_rate_file = '../datasets/test_review.rate';

% read features
ft = load(feature_file);
docnum = size(ft, 1);
tr_ft = ft(1:docnum/2, :);
tst_ft = ft(docnum/2+1:end, :);
clear fea;

% read real ratings
tr_rate = load(tr_rate_file);
tst_rate = load(tst_rate_file);
tr_ft(:,ft_dim+1) = 1;    % bias item
tst_ft(:,ft_dim+1) = 1;

% settings
W = repmat(0.0, ft_dim+1, 1);


% (2) Training
% ============
switch mt_choice,
case 'CD',
    % (CD-1)weight initialization, using sgd to avoid to get the inverse
    % of the large matrix.
    % --------------------
    sgd_max_iter = 300;
    sgd_lrate = 1e-4;
    sgd_threshold = 1e-2;
    sgd_reg = 0.1;    

    err_old = 0.0;
    err_new = 0.0;
    for i=1:sgd_max_iter,
        seq = randperm(docnum/2);
        for j = seq,
            W = W - sgd_lrate*(2*(tr_ft(j,:)*W...
                - tr_rate(j,2))*tr_ft(j,:)'+sgd_reg*W);
        end
        err_new = (tr_ft*W - tr_rate(:,2))'*(tr_ft*W - tr_rate(:,2));
        fprintf(1,'Iteration: %d, current error: %f...\n', i, err_new);
        if abs(err_new-err_old) < sgd_threshold,
            break;
        end
        err_old = err_new;
    end

    % (CD-2)start CD learning method
    % ------------------------------
    cd_lambda = sgd_reg;
    cd_threshold = 1e-2;
    cd_max_iter = 400;

    interval = 20;
    old_W = repmat(0.0, ft_dim+1, 1);
    tic;
    for i=1:cd_max_iter,
        for j=1:ft_dim+1,
            a = 2*sum(tr_ft(:,j).^2);
            c = 2*tr_ft(:,j)*(tr_rate(:,2)-tr_ft*W+W(j).*tr_ft(:,j))
            if abs(c/a) > cd_lambda/a,
                W(j) = sign(c/a)*(abs(c/a) - cd_lambda/a);
            else,
                W(j) = 0;
            end
        end
        fprintf('Difference: %f...\n', sum(abs(W-old_W)));
        if sum(abs(W-old_W)) < cd_threshold,
            break;
        end
        if mod(i, interval) == 0,
            elapsed = toc;
            fprintf('Up to now, total time cost = %s\n', rtime(elapsed));
        end
    end
    
    % (CD-3)show updated weights
    % --------------------------
    disp('New weight:');
    W'

case 'IST',
    Ist_lambda = 0.5;   % sparse controling parameter
    
    break;

otherwise,
    error('Invalid method choice.\n');
end


% (3)Evaluation
% =============
pre_rate = W' * tst_ft';
eval_result = predictiveR2(tst_rate(:,2)', pre_rate);
fprintf(1, 'The result of predictive R2 for linear regression');
fprintf(1, 'with LDA topic features is %f\n', eval_result);
