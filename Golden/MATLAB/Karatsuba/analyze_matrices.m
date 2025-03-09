% Matrix expansion analysis
function analyze_matrices(EVAL, INTERP, POSTprocess)
    fprintf('Analysis of evaluation matrix (EVAL):\n');
    fprintf('Size: %dx%d\n', size(EVAL));
    fprintf('Number of non-zero elements: %d (%.2f%%)\n', nnz(EVAL), 100*nnz(EVAL)/numel(EVAL));
    
    % Analysis of values in the evaluation matrix
    unique_vals = unique(EVAL(:));
    fprintf('Unique values: %s\n', mat2str(unique_vals));
    
    fprintf('\nAnalysis of interpolation matrix (INTERP):\n');
    fprintf('Size: %dx%d\n', size(INTERP));
    fprintf('Number of non-zero elements: %d (%.2f%%)\n', nnz(INTERP), 100*nnz(INTERP)/numel(INTERP));
    
    % Analysis of values in the interpolation matrix
    unique_vals = unique(INTERP(:));
    fprintf('Unique values: %s\n', mat2str(unique_vals));
    
    fprintf('\nAnalysis of post-processing matrix (POSTprocess):\n');
    fprintf('Size: %dx%d\n', size(POSTprocess));
    fprintf('Number of non-zero elements: %d (%.2f%%)\n', nnz(POSTprocess), 100*nnz(POSTprocess)/numel(POSTprocess));
    
    % Analysis of values in the post-processing matrix
    unique_vals = unique(POSTprocess(:));
    fprintf('Unique values: %s\n', mat2str(unique_vals));
    
    % Analysis of matrix sparsity and structure
    figure(1);
    subplot(1,3,1);
    spy(EVAL);
    title('Structure of evaluation matrix');
    
    subplot(1,3,2);
    spy(INTERP);
    title('Structure of interpolation matrix');
    
    subplot(1,3,3);
    spy(POSTprocess);
    title('Structure of post-processing matrix');
end