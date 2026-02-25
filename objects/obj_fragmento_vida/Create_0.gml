minha_chave = get_item_coletado_key();

// Verifica no Dicionário se essa chave já existe (foi salva)
if (variable_struct_exists(global.itens_coletados, minha_chave)) 
{
    instance_destroy(); // Já peguei neste save!
}

timer_float = 0; // Para a animação
