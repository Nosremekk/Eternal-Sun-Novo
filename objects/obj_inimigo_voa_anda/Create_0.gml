/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();
formulario_inimigo(6,1,4,0,0,.3,280,160);



//Timers
timer_troca = 0;
duracao_timer = 2;//Em segundos
duracao_timer_wait = 2;//tbm em segundos


//Este inimigo vai ficar andando e voando quando der na telha
//Iniciando estados
estado_walk = new estado();
estado_rise = new estado();
estado_fly = new estado();

//Andando
estado_walk.inicia = function()
{
    //posso tomar knockback
    forca_x_knock = max_velh*2;
    forca_y_knock = -max_velv;
    
    max_velh = 1;
    image_blend = c_blue;
    velh = choose(-max_velh,max_velh);
    
    socavel = false;
    voador = false;
}

estado_walk.roda = function()
{
    bate_parede();
    volta_x();
    
    
    //Trocando de estado
    timer_troca += desconta_timer()
    if (timer_troca > duracao_timer) troca_estado(estado_rise);
    
    
}

estado_walk.finaliza = function()
{
    timer_troca = 0;
}

//Subindo/Descendo
estado_rise.inicia = function()
{
    socavel = true;
    voador = false;
    
    if (grav == 0)  
    { 
        grav = .02;//Estava voando, tenho que descer agora 
    }
    else //Estava no chao, hora de subir
    {
        grav = 0;
        velv = -max_velv/5;
    }
    
    forca_x_knock = max_velh*2;
    forca_y_knock = -max_velv;
    
    image_blend = c_orange;
}
estado_rise.roda = function()
{
    bate_parede();
    volta_x(); // Mantém ele na área horizontal enquanto sobe
    
    // --- LÓGICA DE SUBIDA ---
    if (grav == 0) // Estou subindo (gravidade desligada)
    {
        // Se já passei da altura máxima (y menor é mais alto)
        if (y <= (y_nativo - altura_max)) 
        {
            troca_estado(estado_fly);
        }
    }
    
    // --- LÓGICA DE DESCIDA ---
    if (grav > 0) and (chao) 
    {
        troca_estado(estado_walk); 
    }
}
estado_rise.finaliza = function()
{
    grav = .3;
}

//Voando
estado_fly.inicia = function()
{
    grav = 0;
    velv = 0;
    max_velh = 1.5;
    velh = choose(-max_velh,max_velh);
    
    forca_x_knock = 0;
    forca_y_knock = 0;
    
    image_blend = c_red;
    
    socavel = false;
    voador = true;
}
estado_fly.roda = function()
{
    bate_parede();
    volta_x();
    
    //Trocando de estado
    timer_troca += desconta_timer()
    if (timer_troca > duracao_timer) troca_estado(estado_rise);
}
estado_fly.finaliza = function()
{
    timer_troca = 0;
}

inicia_morte_inimigo();

inicia_knock_wait(1,estado_walk,,,true);

//Iniciando state machine
inicia_estado(estado_walk);



