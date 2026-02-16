mode = "idle";
alpha = 0;
fade_speed = 0.02;
room_destino = noone; 
acao_callback = undefined; 

global.target_x = noone;
global.target_y = noone;

depth = -999999;

//Verificando se existe obj_inventario
if (instance_exists(obj_inventario))
{
    instance_destroy(obj_inventario)
    global.abre_inventario = false;
    global.pause = false;
}