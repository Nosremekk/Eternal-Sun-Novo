// Suaviza a abertura
if (anim_escala < 1) anim_escala = lerp(anim_escala, 1, 0.15);

// 1. Navegação padronizada (já lida com limites, loop e som)
index_selecionado = up_down(index_selecionado, produtos);

// 2. Coleta os inputs de confirmação e cancelamento
var _inputs = controles_menu();

// Comprar!
if (_inputs.confirma) 
{
    var _item = produtos[index_selecionado];
    
    if (_item.tipo != "none") 
    {
        if (global.dinheiro >= _item.preco) 
        {
            // Pagamento e Save
            global.dinheiro -= _item.preco;
            global.permanentemente_quebrado[$ _item.chave] = true;
            
            // efeito_sonoro(snd_comprar, 50, 0); 
            InputVibrateConstant(0.2, 0.0, 100); // Game feel!
            
            // --- ENTREGA DOS PRODUTOS VIA SWITCH ---
            switch (_item.tipo)
            {
                case "item":
                    adiciona_item_chave(_item.ref_id, 1);
                    break;
                    
                case "amuleto":
                    global.amuletos[| _item.ref_id].pega_item();
                    break;
                    
                case "fragmento":
                    global.fragmentos_vida++;
                    atualiza_stats_player();
                    // NOME NA NOTIFICAÇÃO TRADUZIDO
                    notificar_item(get_text("item_frag_vida_nome"), spr_fragmento_vida);
                    break;
                
                case "fragmento_tempo":
                    global.fragmentos_tempo++;
                    atualiza_stats_player();
                    // NOME NA NOTIFICAÇÃO TRADUZIDO
                    notificar_item(get_text("item_frag_foco_nome"), spr_fragmento_tempo);
                    break;
            }
            
            // Remove da prateleira
            array_delete(produtos, index_selecionado, 1);
            
            // Checa se acabou
            if (array_length(produtos) == 0) {
                // TEXTO "ESGOTADO" TRADUZIDO
                array_push(produtos, { nome: get_text("loja_esgotado_nome"), desc: get_text("loja_esgotado_desc"), preco: 0, spr: noone, tipo: "none" });
                index_selecionado = 0;
            } else {
                // Previne que o índice saia da lista após deletar o último item
                if (index_selecionado >= array_length(produtos)) index_selecionado = array_length(produtos) - 1;
            }
        } 
        else 
        {
            // Sem dinheiro!
            // efeito_sonoro(snd_erro, 50, 0);
            InputVibrateConstant(0.3, 0.0, 50); 
        }
    }
}

// Fechar
if (_inputs.voltar_btn or _inputs.aplica_pause) 
{
    InputVerbConsumeAll();
    global.pause = false; 
    with(obj_player) troca_estado(estado_idle);
    instance_destroy();
}