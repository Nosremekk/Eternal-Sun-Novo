/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();

//Iniciando variaveis
formulario_inimigo(70,2,4,0,0,,150,100);
formulario_tiro(5,1.5,3,true,true);

meu_id_bestiario = "primeiro_boss";
show_message(global.bestiario_kills)
duracao = 2;

//Segunda fase?
segunda_fase = false;



//Timers
timer_troca = 0;
duracao_timer = 0;//Em segundos
duracao_timer_wait = 2;//tbm em segundos
rising = false;

timer_volta = 50;
//Voltando pra wait caso tenha ido pra knock
timer_wait = 0;
//Timer para ir do walk, para dash
timer_walk_to_dash = 15;

//Estados do boss(2 fases)
//Na primeira fase ele fica dando dash ou pulando
//Na segunda fase ele ganha a opção de voar e atirar

//Iniciando estados
estado_walk = new estado();
estado_espera_dash = new estado();
estado_dash = new estado();
estado_pos_dash = new estado();
estado_rise = new estado();
estado_fly = new estado();
estado_wait = new estado();
estado_knock = new estado();

//Andando
estado_walk.inicia = function()
{
    
    image_blend = c_blue;
    
    diagonal = choose(false,true);
    
    timer_walk_to_dash = irandom_range(0,150);
    
    rising = false;
    
    duracao = random_range(.5,2);
    //Fui pra segunda fase? 
    if (!segunda_fase) and (vida_atual < vida_max-35) 
    {
        segunda_fase = true;
        obj_controla_musica.remove_musica();
        obj_controla_musica.adiciona_musica(snd_fase2);
        instance_create_layer(x,y,"Instances",obj_inimigo_voa_atira);
        instance_create_layer(x,y,"Instances",obj_inimigo_dash);
        
    }
}

estado_walk.roda = function()
{
    bate_parede();
    
    //Pegando a direção e indo ao player
    persegue(false,120,65);
    
    //Se eu perdi vinte pontos de vida, posso atirar
    if (vida_atual <= vida_max-20) tiro(true);
    
    //Trocando de estado se estou com a segunda fase liberada
    if (segunda_fase)
    {
        timer_troca += desconta_timer();
        if (timer_troca > duracao_timer) troca_estado(estado_rise);
    }

        
    //Vi o player e tenho o timer do dash? dou dash
    timer_walk_to_dash--;
    if (seguindo(120,110)) and (timer_walk_to_dash < 0) troca_estado(estado_espera_dash);
    
    
}

estado_walk.finaliza = function()
{
    
}

//Pensando na vida e dps indo em direção ao player
estado_espera_dash.inicia = function()
{
    velh = 0;
    velv = 0;
    image_blend = c_maroon;
    dir = sign(obj_player.x-x);
    timer_walk_to_dash = 15;
}

estado_espera_dash.roda = function()
{
    timer_walk_to_dash--;
    if (timer_walk_to_dash < 0) troca_estado(estado_dash);
        
    if (segunda_fase) tiro(true);
    
}

estado_espera_dash.finaliza = function()
{
    timer_walk_to_dash = 60;    
}

//Avançando em direção ao player
estado_dash.inicia = function()
{
    velh = 5* dir;
    image_blend = c_black
    

}

estado_dash.roda = function()
{
    bate_parede();
    
    velh = lerp(velh,0,.05);
    if (abs(velh) < .2) troca_estado(estado_pos_dash);
        
     
}

estado_dash.finaliza = function()
{
    dir = 0;
}

//Esperando pra voltar a atacar
estado_pos_dash.inicia = function()
{
    image_blend = c_purple;
    velh = 0;
}

estado_pos_dash.roda = function()
{
    timer_volta--;
    
    if (timer_volta < 0) troca_estado(estado_walk);
        
    timer_wait = timer_volta;
    
    if (segunda_fase) tiro(false);
    
}

estado_pos_dash.finaliza = function()
{
    if (timer_volta < 0)
    {
        timer_volta = 30;
        timer_wait = 0;
    }
    
}

//------------------Segundo fase
estado_rise.inicia = function()
{
    rising = true;
    
    duracao = random_range(.5,2);
    
    if (grav == 0)  
    { 
        grav = .02;//Estava voando, tenho que descer agora 
    }
    else //Estava no chao, hora de subir
    {
        grav = 0;
        velv = -max_velv/5;
    }
    
    timer_troca = 0;
    duracao_timer = random_range(3,6);
    
    image_blend = c_orange;
}
estado_rise.roda = function()
{
    bate_parede();
    volta_x();
    tiro(false);
    
    //Estou subindo?
    if (abs(y) <= abs(y_nativo-altura_max)) and (grav == 0) troca_estado(estado_fly); //Ja subi muito, vou voar normal agora
    //Estou caindo
    if (grav > 0) and (chao) troca_estado(estado_walk); 
        
    
    
}
estado_rise.finaliza = function()
{

}

//Voando
estado_fly.inicia = function()
{
    grav = 0;
    velv = 0;
    
    duracao = random_range(.5,2);
    
    image_blend = c_red;
    
    rising = false;
}
estado_fly.roda = function()
{
    bate_parede();
    volta_x();
    persegue(false);
    velv = 0;
    tiro(false);
    //Trocando de estado
    timer_troca += desconta_timer()
    if (timer_troca > duracao_timer) troca_estado(estado_rise);
}
estado_fly.finaliza = function()
{
    timer_troca = 0;
}







inicia_morte_inimigo();

//Iniciando a state machine
//Iniciando o meu boss
inicia_boss("Tiago Dias, Devorador de deuses",estado_walk);
inicia_estado(estado_boss);
