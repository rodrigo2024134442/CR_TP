function data = cbr_retain(data, novo_caso, classe, temp_final, best_sim)
% Retain do CBR
% Guarda o novo caso no dataset se for suficientemente diferente dos existentes
% Entradas: data, novo_caso, classe (diagnóstico), temp_final, best_sim
% Saída:    data atualizado (com ou sem o novo caso)

fprintf('\n--- RETAIN ---\n');
fprintf('  Similaridade máxima encontrada: %.4f\n', best_sim);

% limiar de 0.8 — consistente com o limiar usado no Retrieve
% se best_sim < 0.8, o caso é suficientemente diferente para guardar
if best_sim < 0.8

    % atualizar o novo caso com o diagnóstico e temperatura final
    novo_caso.class_cat   = classe;
    novo_caso.temperature = temp_final;

    % adicionar o novo caso ao dataset
    data = [data; novo_caso];

    fprintf('  Caso guardado no dataset (total: %d casos)\n', height(data));

else
    % caso muito parecido com um existente — não vale a pena guardar
    fprintf('  Caso não guardado — já existe caso suficientemente similar\n');
end

end
