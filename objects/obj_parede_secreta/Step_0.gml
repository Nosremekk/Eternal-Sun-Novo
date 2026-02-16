// Lógica de Treme-Treme
if (shake_x > 0) shake_x = lerp(shake_x, 0, 0.1);

// Partícula ocasional (Dica visual)
if (random(100) < 1) {
    cria_particula(bbox_left + random(sprite_width), bbox_bottom, TIPO_PARTICULA.POEIRA_PULO, 1);
}

// Piscar quando toma dano (função herdada do create do pai)
blink();