/// @description Insert description here
// You can write your code in this editor
if (unico_uso)
{
    // Verifica se a chave existe E se é verdadeira dentro de .tutorial
    if (variable_struct_exists(global.eventos.tutorial, save_id) && global.eventos.tutorial[$ save_id] == true)
    {
        completo = true;
        instance_destroy();
    }
}
