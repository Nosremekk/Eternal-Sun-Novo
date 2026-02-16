function estado() constructor {
    static inicia   = function(){};
    static roda     = function(){};
    static finaliza = function(){};
}

function inicia_estado(_estado) {
    estado_atual = _estado;
    estado_atual.inicia();
}

function troca_estado(_estado) {
    estado_atual.finaliza();
    estado_atual = _estado;
    estado_atual.inicia();
}

function roda_estado() {
    estado_atual.roda();
}

