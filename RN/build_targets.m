function T = build_targets(data)
% BUILD_TARGETS — constrói targets em one-hot para classificação
%
% A saída `T` segue o formato usado pelas redes MATLAB: linhas = classes,
% colunas = amostras. Cada coluna é um vetor one-hot com um único 1.
%
% Classes e codificação (ordem fixa):
%   Normal            → [1; 0; 0]
%   ElectricalFailure → [0; 1; 0]
%   MechanicalFailure → [0; 0; 1]
%
% Entrada:
%   data — tabela com a coluna `class_cat` preenchida
%
% Saída:
%   T    — matriz double [3 x N] pronta para treinar `patternnet`

% Nota didática: a ordem das linhas deve corresponder à utilizada em
% outros scripts (por exemplo `main_task3` e `test_best_nets`).

N = height(data);
T = zeros(3, N);

for i = 1:N
    classe = string(data.class_cat(i));
    if strcmp(classe, 'Normal')
        T(1, i) = 1;
    elseif strcmp(classe, 'ElectricalFailure')
        T(2, i) = 1;
    elseif strcmp(classe, 'MechanicalFailure')
        T(3, i) = 1;
    end
end

end
