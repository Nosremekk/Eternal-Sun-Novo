minha_chave = get_item_coletado_key();

if (variable_struct_exists(global.itens_coletados, minha_chave)) 
{
    instance_destroy();
}
timer_float = 0;