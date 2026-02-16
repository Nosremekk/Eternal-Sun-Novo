// Garante que o controlador existe
if (instance_exists(obj_controla_luz))
{
    // Conecta ao renderer NOVO e VIVO desta sala
    minha_luz = new BulbLight(obj_controla_luz.renderer, spr_luz, 0, x, y); 
    
    // Configuração da Luz
    minha_luz.blend = make_color_rgb(255, 240, 200);
    minha_luz.castShadows = true; 
    minha_luz.yscale = 1
    minha_luz.xscale = 1;
    minha_luz.intensity = 0.5; 
    minha_luz.penumbraSize = 80;
}

