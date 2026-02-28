depth = -9999;

alpha = 0;
escala_item = 0; // Vai dar um efeito de "pop" (crescer de 0 a 1)
estado_item = 0; // 0: Entrando, 1: Esperando, 2: Saindo

global.pause = true;

// Efeito de impacto ao pegar o item
InputVibrateConstant(1.0, 0.0, 300); // Vibração forte
// efeito_sonoro(snd_item_importante, 100, 0); // Descomente e coloque o seu som épico aqui!