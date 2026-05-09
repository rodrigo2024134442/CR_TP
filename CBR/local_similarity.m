function sim = local_similarity(v1, v2, col_min, col_max)
% local_similarity — similaridade entre dois valores do mesmo atributo
%
% Descrição:
%   Calcula uma medida de similaridade local entre dois valores do mesmo
%   atributo. Para variáveis numéricas usamos uma normalização pelo intervalo
%   observado (col_max - col_min) e transformamos a diferença numa similaridade
%   entre 0 e 1. Para variáveis não numéricas (categóricas) devolvemos 1 se
%   forem iguais e 0 caso contrário.
%
% Entradas:
%   v1, v2  - os dois valores a comparar (podem ser numéricos ou categóricos)
%   col_min - mínimo observado da coluna (usado para normalizar)
%   col_max - máximo observado da coluna (usado para normalizar)
%
% Saída:
%   sim     - similaridade entre 0 e 1 (1 = idênticos, 0 = máximo de diferença)

    % Se os valores não forem numéricos, comparamos por igualdade exata.
    % Converte em string para cobrir casos como categorical/char.
    if ~(isnumeric(v1) && isnumeric(v2))
        sim = double(string(v1) == string(v2));
        return;
    end

    % Calcular o intervalo observado da coluna. Se for zero (todos os
    % valores iguais) devolvemos similaridade máxima porque não há variação.
    intervalo = col_max - col_min;
    if intervalo == 0
        sim = 1;
        return;
    end

    % Diferença absoluta normalizada: menor diferença -> similaridade mais alta
    diferenca = abs(v1 - v2);
    sim = 1 - (diferenca / intervalo);

    % Garantir limites numéricos (por segurança numérica)
    sim = max(0, min(1, sim));

end