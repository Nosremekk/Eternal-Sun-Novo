if (window_get_fullscreen()) {
    _w_atual = display_get_width();
    _h_atual = display_get_height();
} else {
    _w_atual = window_get_width();
    _h_atual = window_get_height();
}

// Aplica imediatamente ao criar o sistema
if (surface_exists(application_surface)) {
    surface_resize(application_surface, _w_atual, _h_atual);
}
display_set_gui_size(_w_atual, _h_atual); // Ou sua lógica de GUI Scale

alarm[1] = 5;