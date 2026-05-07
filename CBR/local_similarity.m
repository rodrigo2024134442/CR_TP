function sim = local_similarity(v1, v2, col_min, col_max)
% Calcula a similaridade local entre dois valores do mesmo atributo
% Resultado sempre entre 0 (completamente diferentes) e 1 (iguais)
%
% Entradas:
%   v1, v2       — os dois valores a comparar
%   col_min      — valor mínimo da coluna (para normalizar)
%   col_max      — valor máximo da coluna (para normalizar)

    % Se os valores não forem numéricos, comparar por igualdade exata.
    % Isto torna a função mais robusta em testes manuais.
    if ~(isnumeric(v1) && isnumeric(v2))
        sim = double(string(v1) == string(v2));
        return;
    end

    % calcular o intervalo da coluna
    intervalo = col_max - col_min;

    % se o intervalo for zero, todos os valores da coluna são iguais
    % não há diferença possível, similaridade é 1
    if intervalo == 0
        sim = 1;
        return;
    end

    % calcular a diferença absoluta entre os dois valores
    diferenca = abs(v1 - v2);
    % normalizar a diferença pelo intervalo e converter em similaridade
    % 1 - isso inverte: 0 diferença = similaridade 1, máxima diferença = similaridade 0
    sim = 1 - (diferenca / intervalo);

end