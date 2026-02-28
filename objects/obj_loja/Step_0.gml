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
            
            // Você pode adicionar um som de compra aqui se quiser
            // efeito_sonoro(snd_comprar, 50, 0); 
            InputVibrateConstant(0.2, 0.0, 100); // Game feel!
            
            // Entrega
            if (_item.tipo == "item") adiciona_item_chave(_item.ref_id, 1);
            else if (_item.tipo == "amuleto") global.amuletos[| _item.ref_id].pega_item();
            
            // Remove da prateleira
            array_delete(produtos, index_selecionado, 1);
            
            // Checa se acabou
            if (array_length(produtos) == 0) {
                array_push(produtos, { nome: "Esgotado", desc: "Já comprei tudo...", preco: 0, spr: noone, tipo: "none" });
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
    InputVerbConsumeAll()
    global.pause = false; 
    with(obj_player) troca_estado(estado_idle);
    instance_destroy();
}