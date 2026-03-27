event_inherited();

formulario_inimigo(2, 2, 2, 0, 0, 0, 300, 0, false, spr_inimigo_morcego_ruinas_morto);

// Estado de voo em linha reta
estado_voo = new estado();

estado_voo.inicia = function()
{
    sprite_index = spr_inimigo_morcego_ruinas; 
    image_index = 0;
    socavel = true; 
    
    // Começa voando para um lado aleatório
    velh = max_velh * choose(1, -1);
}

estado_voo.roda = function()
{
    // Patrulha horizontal simples
    volta_x(); 
    bate_parede(); 
}


inicia_knock(estado_voo,0,0,true); 
inicia_morte_inimigo();

inicia_estado(estado_voo);