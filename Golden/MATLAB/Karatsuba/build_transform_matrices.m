function [EVAL, INTERP, POSTprocess] = build_transform_matrices()
    % Construct the evaluation matrix
    EVAL_1 = [1 0; 1 1; 0 1];
    EVAL_2 = kron(EVAL_1, EVAL_1);
    EVAL_4 = kron(EVAL_2, EVAL_2);
    EVAL = EVAL_4;
    
    % Construct the interpolation matrix
    INTERP_1 = [1 0 0; -1 1 -1; 0 0 1];

    INTERP_2_temp = kron(INTERP_1, INTERP_1);
    INTERP_2 = zeros(7,9);
    INTERP_2(1:2,:) = INTERP_2_temp(1:2,:);
    INTERP_2(3,:) = INTERP_2_temp(3,:) + INTERP_2_temp(4,:);
    INTERP_2(4,:) = INTERP_2_temp(5,:);
    INTERP_2(5,:) = INTERP_2_temp(6,:) + INTERP_2_temp(7,:);
    INTERP_2(6:7,:) = INTERP_2_temp(8:9,:);

    INTERP_3_temp = kron(INTERP_2, INTERP_1);
    INTERP_3 = zeros(15, 27);
    INTERP_3(1:2,:)    = INTERP_3_temp(1:2,:);
    INTERP_3(3,:)      = INTERP_3_temp(3,:) + INTERP_3_temp(4,:);
    INTERP_3(4,:)      = INTERP_3_temp(5,:);
    INTERP_3(5,:)      = INTERP_3_temp(6,:) + INTERP_3_temp(7,:);
    INTERP_3(6,:)      = INTERP_3_temp(8,:);
    INTERP_3(7,:)      = INTERP_3_temp(9,:) + INTERP_3_temp(10,:);
    INTERP_3(8,:)      = INTERP_3_temp(11,:);
    INTERP_3(9,:)      = INTERP_3_temp(12,:) + INTERP_3_temp(13,:);
    INTERP_3(10,:)     = INTERP_3_temp(14,:);
    INTERP_3(11,:)     = INTERP_3_temp(15,:) + INTERP_3_temp(16,:);
    INTERP_3(12,:)     = INTERP_3_temp(17,:);
    INTERP_3(13,:)     = INTERP_3_temp(18,:) + INTERP_3_temp(19,:);
    INTERP_3(14:15,:)  = INTERP_3_temp(20:21,:);

    INTERP_4_temp = kron(INTERP_3, INTERP_1);
    INTERP_4 = zeros(31, 81);
    INTERP_4(1:2,:)    = INTERP_4_temp(1:2,:);
    INTERP_4(3,:)      = INTERP_4_temp(3,:) + INTERP_4_temp(4,:);
    INTERP_4(4,:)      = INTERP_4_temp(5,:);
    INTERP_4(5,:)      = INTERP_4_temp(6,:) + INTERP_4_temp(7,:);
    INTERP_4(6,:)      = INTERP_4_temp(8,:);
    INTERP_4(7,:)      = INTERP_4_temp(9,:) + INTERP_4_temp(10,:);
    INTERP_4(8,:)      = INTERP_4_temp(11,:);
    INTERP_4(9,:)      = INTERP_4_temp(12,:) + INTERP_4_temp(13,:);
    INTERP_4(10,:)     = INTERP_4_temp(14,:);
    INTERP_4(11,:)     = INTERP_4_temp(15,:) + INTERP_4_temp(16,:);
    INTERP_4(12,:)     = INTERP_4_temp(17,:);
    INTERP_4(13,:)     = INTERP_4_temp(18,:) + INTERP_4_temp(19,:);
    INTERP_4(14,:)     = INTERP_4_temp(20,:);
    INTERP_4(15,:)     = INTERP_4_temp(21,:) + INTERP_4_temp(22,:);
    INTERP_4(16,:)     = INTERP_4_temp(23,:);
    INTERP_4(17,:)     = INTERP_4_temp(24,:) + INTERP_4_temp(25,:);
    INTERP_4(18,:)     = INTERP_4_temp(26,:);
    INTERP_4(19,:)     = INTERP_4_temp(27,:) + INTERP_4_temp(28,:);
    INTERP_4(20,:)     = INTERP_4_temp(29,:);
    INTERP_4(21,:)     = INTERP_4_temp(30,:) + INTERP_4_temp(31,:);
    INTERP_4(22,:)     = INTERP_4_temp(32,:);
    INTERP_4(23,:)     = INTERP_4_temp(33,:) + INTERP_4_temp(34,:);
    INTERP_4(24,:)     = INTERP_4_temp(35,:);
    INTERP_4(25,:)     = INTERP_4_temp(36,:) + INTERP_4_temp(37,:);
    INTERP_4(26,:)     = INTERP_4_temp(38,:);
    INTERP_4(27,:)     = INTERP_4_temp(39,:) + INTERP_4_temp(40,:);
    INTERP_4(28,:)     = INTERP_4_temp(41,:);
    INTERP_4(29,:)     = INTERP_4_temp(42,:) + INTERP_4_temp(43,:);
    INTERP_4(30:31,:)  = INTERP_4_temp(44:45,:);
    INTERP = INTERP_4;

    % Construct the post-processing matrix (Polynomial ring norm)
    NORM = eye(16,31);
    NORM(1:15,17:31) = NORM(1:15,17:31) - eye(15,15);
    
    % Construct the post-processing matrix (Polynomial ring interpolation)
    POSTprocess = NORM * INTERP;
end