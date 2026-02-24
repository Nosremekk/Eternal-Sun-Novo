
function init_dano()
{
    lista_livre = [];
}

//Função de aplicar dano

function aplica_dano(_dano = 1,_player = true)
{
    //Pegando todo mundo em uma lista
    var _lista = ds_list_create()
    var _col = instance_place_list(x,y,obj_entidade,_lista,1);
    
    //Checando se minha lista não esta vazia
    if (ds_list_size(_lista) > 0)
    {
        //Iterando pela minha lista
        var _qtd = ds_list_size(_lista);
        for (var i=0;i<_qtd;i++)
        {
            var _outro = _lista[|i];
            //Se o outro estiver invencivel, saio
            if (_outro.inv) continue;
            //Foi o player que criou o dano?
            if (_player)
            {//Dano em todos menos o player
                if (_outro.object_index == obj_player) continue;
            
            }
            else    
            {
                if (_outro.object_index != obj_player) continue;        
            }
            //Ta na lista?
            var _contem = array_contains(lista_livre, _outro);
            if (!_contem)
            {
                //aplicado dano
                _outro.recebe_dano(_dano);
                array_push(lista_livre,_outro);
            }
            
       
            
        }
    }
     
    //Apagando as listas
    ds_list_destroy(_lista);
    
}

//Causando dano em contato
function causa_dano_contato()
{ 
    var _player = instance_place(x,y,obj_player);
    if (_player and toquei_player == false)
    {
         _player.hurt_id = id;
        aplica_dano(1,false); 
        toquei_player = true; 
        alarm[0] = 60;
    }
}


