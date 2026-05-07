function temp_final = cbr_revise(temp_atual, temp_sugerida, modo_interativo, verbose)
% Revise do CBR
% Pergunta ao utilizador se aceita a temperatura sugerida pela rede neuronal
% Entradas: 
%   temp_atual         — temperatura do novo caso
%   temp_sugerida      — temperatura sugerida pela rede
%   modo_interativo    — (OPCIONAL) se false, aceita automaticamente (teste automático)
%                        se true ou omitido, pede confirmação ao utilizador
%   verbose            — (OPCIONAL) true/false para mostrar mensagens no ecrã
% Saída:    
%   temp_final         — temperatura aceite pelo utilizador

if nargin < 3 || isempty(modo_interativo)
    modo_interativo = true;
end

if nargin < 4 || isempty(verbose)
    verbose = true;
end

if verbose
    fprintf('\n--- REVISE ---\n');
    fprintf('  Temperatura atual:    %.2f C\n', temp_atual);
    fprintf('  Temperatura sugerida: %.2f C\n', temp_sugerida);
end

if modo_interativo
    % perguntar ao utilizador se aceita o valor sugerido
    % 's' no final do input() trata a resposta como string
    resposta = input('  Aceita a temperatura sugerida? (s/n): ', 's');
    
    if strcmp(resposta, 's')
        % utilizador aceitou  usa a temperatura sugerida pela rede
        temp_final = temp_sugerida;
        if verbose
            fprintf('  Temperatura atualizada para %.2f C\n', temp_final);
        end
    else
        % utilizador recusou mantém a temperatura original
        temp_final = temp_atual;
        if verbose
            fprintf('  Temperatura mantida em %.2f C\n', temp_final);
        end
    end
else
    % Modo não-interativo: aceita automaticamente a temperatura sugerida
    temp_final = temp_sugerida;
    if verbose
        fprintf('  Temperatura atualizada para %.2f C (automático)\n', temp_final);
    end
end

end
