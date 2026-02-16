depth = -9999; // Para desenhar por cima de tudo (ou ajuste conforme suas layers)

// Cria o sistema
sistema_particulas = part_system_create();

// IMPORTANTE: Desativar atualização automática para controlar o PAUSE
part_system_automatic_update(sistema_particulas, false);

// --- DEFINIÇÃO DOS TIPOS ---

// 1. SANGUE / GOSMA (Hit nos inimigos)
part_sangue = part_type_create();
part_type_shape(part_sangue, pt_shape_disk); // Ou use um sprite customizado: part_type_sprite(...)
part_type_size(part_sangue, 0.1, 0.3, -0.01, 0);
part_type_color3(part_sangue, c_red, c_maroon, c_black); // Começa vermelho, escurece
part_type_alpha3(part_sangue, 1, 1, 0);
part_type_speed(part_sangue, 2, 5, -0.1, 0);
part_type_direction(part_sangue, 0, 360, 0, 0); // Direção será sobrescrita na chamada se quiser
part_type_gravity(part_sangue, 0.2, 270);
part_type_life(part_sangue, 20, 40);

// 2. EXPLOSÃO (Morte ou impacto forte)
part_explosao = part_type_create();
part_type_shape(part_explosao, pt_shape_explosion);
part_type_size(part_explosao, 0.5, 0.8, -0.02, 0);
part_type_color2(part_explosao, c_orange, c_white);
part_type_alpha3(part_explosao, 1, 0.5, 0);
part_type_speed(part_explosao, 0, 0, 0, 0);
part_type_life(part_explosao, 15, 25);

// 3. POEIRA (Pulo / Aterrissagem)
part_poeira = part_type_create();
part_type_shape(part_poeira, pt_shape_cloud);
part_type_size(part_poeira, 0.2, 0.5, -0.01, 0);
part_type_color1(part_poeira, c_ltgray);
part_type_alpha3(part_poeira, 0.6, 0.3, 0);
part_type_speed(part_poeira, 0.5, 1, 0, 0);
part_type_direction(part_poeira, 0, 180, 0, 0); // Sobe um pouco
part_type_life(part_poeira, 20, 40);

// 4. DASH (Rastro ou fumacinha)
part_dash = part_type_create();
part_type_shape(part_dash, pt_shape_square); // Ou pixel
part_type_size(part_dash, 0.1, 0.2, -0.02, 0);
part_type_color_rgb(part_dash, 100, 200, 255, 255, 255, 255); // Azulado/Branco
part_type_alpha3(part_dash, 0.8, 0.4, 0);
part_type_speed(part_dash, 0, 0, 0, 0); // Fica parado onde foi criado
part_type_life(part_dash, 10, 15);

// 5. FAÍSCA (Impacto em parede ou metal)
part_faisca = part_type_create();
part_type_shape(part_faisca, pt_shape_line);
part_type_size(part_faisca, 0.1, 0.2, 0, 0);
part_type_color1(part_faisca, c_yellow);
part_type_speed(part_faisca, 3, 6, -0.2, 0);
part_type_direction(part_faisca, 0, 360, 0, 0);
part_type_life(part_faisca, 10, 20);
part_type_orientation(part_faisca, 0, 360, 0, 0, true); // Gira com a direção

// 6. SHOCKWAVE (Pulo Duplo / Aterrissagem forte)
part_shockwave = part_type_create();
part_type_shape(part_shockwave, pt_shape_ring); // Anel vazio
part_type_size(part_shockwave, 0.1, 0.1, 0.05, 0); 
part_type_color1(part_shockwave, c_white);
part_type_alpha3(part_shockwave, 0.8, 0.5, 0);
part_type_speed(part_shockwave, 0, 0, 0, 0); // Não se move, só expande
part_type_life(part_shockwave, 10, 15);

// 7. BRILHO/COLETÁVEL
part_brilho = part_type_create();
part_type_shape(part_brilho, pt_shape_star); // Ou pt_shape_pixel
part_type_size(part_brilho, 0.1, 0.3, -0.01, 0);
part_type_color2(part_brilho, c_yellow, c_white); // Dourado
part_type_speed(part_brilho, 2, 4, -0.1, 0);
part_type_direction(part_brilho, 0, 360, 0, 0); // Explode pra todo lado
part_type_life(part_brilho, 20, 40);

// 8. ALMA / ESPÍRITO
part_alma = part_type_create();
part_type_shape(part_alma, pt_shape_flare); // Um brilho suave
part_type_size(part_alma, 0.2, 0.4, -0.01, 0);
part_type_color2(part_alma, c_aqua, c_blue); // Cor etérea
part_type_alpha3(part_alma, 0.8, 0.4, 0);
part_type_speed(part_alma, 1, 2, 0, 0);
part_type_direction(part_alma, 80, 100, 0, 0); // Sobe suavemente
part_type_life(part_alma, 30, 60);