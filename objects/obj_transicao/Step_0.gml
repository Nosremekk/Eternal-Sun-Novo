if (global.pause) exit;
controlar_transicao();

if (!is_undefined(minha_luz))
{
    tempo_animacao += 0.05;
    minha_luz.intensity = 0.75 + (sin(tempo_animacao) * 0.15);
}

