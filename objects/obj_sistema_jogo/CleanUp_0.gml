// Limpa estruturas de dados globais para evitar vazamento de memória
if (variable_global_exists("inventario") and ds_exists(global.inventario, ds_type_grid))
{
    ds_grid_destroy(global.inventario);
}

if (variable_global_exists("amuletos") and ds_exists(global.amuletos, ds_type_list))
{
    ds_list_destroy(global.amuletos);
}

if (variable_global_exists("amuletos_equipados") and ds_exists(global.amuletos_equipados, ds_type_list))
{
    ds_list_destroy(global.amuletos_equipados);
}

if (variable_global_exists("itens_chave") and ds_exists(global.itens_chave, ds_type_map))
{
    ds_map_destroy(global.itens_chave);
}