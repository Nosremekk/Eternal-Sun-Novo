luz = new BulbLight(obj_controla_luz.renderer, spr_luz, 0, x, y); // [cite: 203]

// Configuração da Luz
luz.penumbraSize = 32;       // Suavidade da sombra [cite: 209]
luz.intensity = 1.0;         // Brilho [cite: 209]
luz.blend = c_orange;        // Cor da luz (Tocha) [cite: 209]
luz.castShadows = true;      // Se projeta sombras (true é mais pesado) [cite: 209]