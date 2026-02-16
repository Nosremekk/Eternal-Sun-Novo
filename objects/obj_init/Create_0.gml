window_set_cursor(cr_none);
randomize();

// Reset de variaveis
reset_variaveis_jogo();

//load
var _control = instance_create_depth(x, y, depth, obj_sistema_jogo);
_control.persistent = true;

// Load nas configs
inicializa_eventos_mundo();
inicializa_sistema_itens_chave();
inicializa_nomes_areas();

carregar_config();      
carregar_config_ui();   

// Inputs
configurar_icones_input();
InputPlayerSetMinThreshold(INPUT_THRESHOLD.BOTH, 0.2, 0);

// Audio e luz
inicializa_musicas();
instance_create_depth(x, y, depth, obj_controla_musica);
global.instancia_luz = instance_create_layer(0, 0, "Luz", obj_controla_luz);
//Particulas
var _particula = instance_create_depth(x,y,depth,obj_controla_particulas);
_particula.persistent = true;

// Indo pra sala com logo
IniciarTransicao(rm_logo);