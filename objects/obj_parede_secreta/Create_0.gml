meu_oclusor = undefined;
//Já morri?
chave_id = get_permanentemente_quebrados_key();

if (struct_exists(global.permanentemente_quebrado,chave_id))
{
    instance_destroy();
    exit;
}

//Não fui obliterado ainda


event_inherited(); // Herda vida, blink, etc.

vida_max = 3;
vida_atual = vida_max;
inv = false;

// Removemos variáveis de movimento desnecessárias, pois não usaremos move_and_collide
grav = 0;
shake_x = 0;

function recebe_dano(_dano = 1)
{
    if (obj_player.dir_atk == "vertical_down") exit;
    if (obj_player.tipo_magia == "pound") vida_atual = 1;
            
    vida_atual -= _dano;
    shake_x = 8; 
    inv = true; // Ativa invencibilidade breve para piscar
    inv_timer = 0;

    // Feedback Visual
    var _centro_x = x + (sprite_width/2);
    var _centro_y = y + (sprite_height/2);
    cria_particula(_centro_x, _centro_y, TIPO_PARTICULA.POEIRA_PULO, 5);

    if (vida_atual <= 0)
    {
        // 1. Explosão
        cria_particula(_centro_x, _centro_y, TIPO_PARTICULA.EXPLOSAO, 1);
        

        if (!is_undefined(meu_oclusor))
        {
            // Remove o oclusor da memória da Bulb
            meu_oclusor.Destroy(); 
            meu_oclusor = undefined;
            
            // Avisa o controlador para atualizar as sombras estáticas IMEDIATAMENTE
            if (instance_exists(obj_controla_luz))
            {
                with(obj_controla_luz) 
                {
                    // Essa função reconstrói a geometria de sombras estáticas
                    if (renderer != undefined) renderer.RefreshStaticOccluders(); // [cite: 25, 65]
                }
            }
        }
        
        global.permanentemente_quebrado[$ chave_id] = true;
        instance_destroy();
    }
}
