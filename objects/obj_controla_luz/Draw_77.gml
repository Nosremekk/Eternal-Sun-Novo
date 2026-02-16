if (renderer != undefined)
{
    var _w = surface_get_width(application_surface);
    var _h = surface_get_height(application_surface);
    
    // Desenha a iluminação sobre o jogo
    renderer.DrawLitSurface(application_surface, 0, 0, _w, _h);
}