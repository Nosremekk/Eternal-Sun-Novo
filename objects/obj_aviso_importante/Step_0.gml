
if (!global.pause) global.pause = true;
    
var _inputs = controles_menu();

switch (estado_item)
{
    case 0:
        alpha = lerp(alpha, 1, 0.1);
        escala_item = lerp(escala_item, 1, 0.15); 
        
        if (alpha > 0.95) {
            alpha = 1;
            escala_item = 1;
            estado_item = 1;
        }
        break;

    case 1: 
        if (_inputs.confirma or _inputs.voltar_btn or _inputs.aplica_pause) {
            estado_item = 2;
            InputVerbConsumeAll();
            efeito_sonoro(sfx_menu_click, 50, 0);
        }
        break;

    case 2: // Fade Out
        alpha = lerp(alpha, 0, 0.15);
        escala_item = lerp(escala_item, 1.2, 0.1); // Dá uma leve crescidinha antes de sumir
        
        if (alpha < 0.05) {
            instance_destroy();
        }
        break;
}
