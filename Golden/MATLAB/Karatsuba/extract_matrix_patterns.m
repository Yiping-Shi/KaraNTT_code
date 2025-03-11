% extract_matrix_patterns.m
% 脚本用于提取EVAL和POSTprocess矩阵的非零元素模式

function extract_matrix_patterns(EVAL, POSTprocess)
    % 打开文件准备写入结果
    fid = fopen('matrix_patterns.txt', 'w');
    
    % 部分1: 分析EVAL矩阵 (81x16)
    fprintf(fid, '==========================================\n');
    fprintf(fid, 'EVAL矩阵非零元素模式 (81x16，每行)\n');
    fprintf(fid, '==========================================\n\n');
    
    for row = 1:size(EVAL, 1)
        % 找出当前行的非零元素
        [~, cols] = find(EVAL(row, :));
        fprintf(fid, 'a_eval[%d] = ', row-1); % 使用0-based索引
        
        % 如果没有非零元素，则输出0
        if isempty(cols)
            fprintf(fid, '0;\n');
            continue;
        end
        
        % 构建表达式
        expressions = {};
        for j = 1:length(cols)
            expressions{j} = sprintf('a[%d]', cols(j)-1); % 使用0-based索引
        end
        fprintf(fid, '%s;\n', strjoin(expressions, ' + '));
    end
    
    % 部分2: 分析POSTprocess矩阵 (16x81)
    fprintf(fid, '\n\n==========================================\n');
    fprintf(fid, 'POSTprocess矩阵非零元素模式 (16x81，每行)\n');
    fprintf(fid, '==========================================\n\n');
    
    for row = 1:size(POSTprocess, 1)
        % 找出当前行的非零元素及其值
        [~, cols, vals] = find(POSTprocess(row, :));
        fprintf(fid, 'result[%d] = ', row-1); % 使用0-based索引
        
        % 如果没有非零元素，则输出0
        if isempty(cols)
            fprintf(fid, '0;\n');
            continue;
        end
        
        % 构建表达式
        expressions = {};
        for j = 1:length(cols)
            if vals(j) == 1
                if j == 1
                    expressions{j} = sprintf('c_eval[%d]', cols(j)-1); % 第一项不需要+号
                else
                    expressions{j} = sprintf('+ c_eval[%d]', cols(j)-1);
                end
            else % vals(j) == -1 或其他负数
                expressions{j} = sprintf('- c_eval[%d]', cols(j)-1);
            end
        end
        fprintf(fid, '%s;\n', strjoin(expressions, ' '));
    end
    
    % 关闭文件
    fclose(fid);
    
    fprintf('非零元素模式已保存到matrix_patterns.txt文件\n');
end