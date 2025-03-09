% Matrix operation path tracing - Analyze the computation path of each output coefficient
function trace_computation_path(POSTprocess)
    fprintf('Analyzing the computation path of polynomial multiplication:\n');
    
    % For each output coefficient, determine the evaluation points it depends on
    for i = 1:16
        % Identify the positions of non-zero elements in the POSTprocess matrix
        [rows, vals] = find(POSTprocess(i,:));
        fprintf('Output coefficient c[%d] depends on evaluation points:\n', i-1);
        
        for j = 1:length(rows)
            fprintf('  Evaluation point %d, weight = %d\n', rows(j)-1, vals(j));
        end
        fprintf('\n');
    end
end