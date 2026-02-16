ativado = false;
acao_custom = undefined;
shake_timer = 0;



controlar_transicao = function()
{
    var _player = instance_place(x, y, obj_player);
    
    if (shake_timer > 0) shake_timer -= desconta_timer();

    if (_player and !ativado)
    {
        var _tentou_entrar = false;

        if (!requer_interacao)
        {
            _tentou_entrar = true;
        }
        else
        {
            if (_player.chao and InputPressed(INPUT_VERB.UP))
            {
                _tentou_entrar = true;
            }
        }

        if (_tentou_entrar)
        {
            if (item_necessario != "")
            {
                if (!tem_item_chave(item_necessario))
                {
                    if (shake_timer <= 0)
                    {
                        shake_timer = 1;
                    }
                    exit;
                }
            }
            
            //Corrigindo xscale
            if (nova_xscale != 0)
            {
                global.xscale_player_transicao  = nova_xscale;
                obj_player.entrou_porta = true;
            }
            
            //Transição

            if (IniciarTransicao(destino, x_destino, y_destino, acao_custom))
            {
                ativado = true;
                global.transicao = true;
                
                with (_player)
                {
                    troca_estado(estado_wait);
                    velh = 0;
                    velv = 0;
                }
            }
        }
    }
}

desenhar_transicao = function()
{
    draw_self();

    if (requer_interacao and !ativado)
    {
        var _player = instance_place(x, y, obj_player);

        if (_player)
        {
            if (!_player.chao) exit;

            var _is_locked = (item_necessario != "" and !tem_item_chave(item_necessario));
            var _sprite = _is_locked ? spr_ui_cadeado : spr_ui_interage;
            
            var _col = c_white;
            var _x_shake = 0;
            
            if (shake_timer > 0)
            {
                _col = c_red;
                _x_shake = random_range(-3, 3);
            }

            var _draw_x = x + sprite_width/2 + _x_shake;
            var _draw_y = bbox_top - 25;
            
            draw_sprite_ext(_sprite, 0, _draw_x, _draw_y, 1, 1, 0, _col, 1);
        }
    }
}


minha_luz = undefined;
tempo_animacao = 0;