if (alpha > 0)
{
    var _x = camera_get_view_x(view_camera[0]);
    var _y = camera_get_view_y(view_camera[0]);
    var _w = camera_get_view_width(view_camera[0]);
    var _h = camera_get_view_height(view_camera[0]);
    
    draw_set_alpha(alpha);
    draw_set_color(c_black);
    
    // Desenha retângulo cobrindo a view
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);
    
    draw_set_alpha(1);
    draw_set_color(c_white);
}