function temp_final = cbr_revise(temp_atual, temp_sugerida)
% Revise do CBR
% Pergunta ao utilizador se aceita a temperatura sugerida pela rede neuronal
% Entradas: temp_atual (temperatura do novo caso), temp_sugerida (pela rede)
% Saída:    temp_final (temperatura aceite pelo utilizador)

fprintf('\n--- REVISE ---\n');
fprintf('  Temperatura atual:    %.2f C\n', temp_atual);
fprintf('  Temperatura sugerida: %.2f C\n', temp_sugerida);

% perguntar ao utilizador se aceita o valor sugerido
% 's' no final do input() trata a resposta como string
resposta = input('  Aceita a temperatura sugerida? (s/n): ', 's');

if strcmp(resposta, 's')
    % utilizador aceitou  usa a temperatura sugerida pela rede
    temp_final = temp_sugerida;
    fprintf('  Temperatura atualizada para %.2f C\n', temp_final);
else
    % utilizador recusou mantém a temperatura original
    temp_final = temp_atual;
    fprintf('  Temperatura mantida em %.2f C\n', temp_final);
end

end
