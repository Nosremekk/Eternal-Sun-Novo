//Verificando se ja existi
chave_id = get_permanentemente_quebrados_key();

if (struct_exists(global.permanentemente_quebrado,chave_id))
{
    instance_destroy();
    exit;
}

image_blend = c_black; // Pinta de preto
image_alpha = 1;       // Totalmente visível
fade_out = false;      // Estado de controle