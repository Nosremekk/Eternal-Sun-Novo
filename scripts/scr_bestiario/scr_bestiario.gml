global.bestiario_kills = {}; 


global.db_bestiario = 
{
    
    // O nome da chave ("inimigo_anda") será o ID que usaremos para salvar as mortes.
    "inimigo_anda": {
        nome_key: "best_nome_anda",       // Chave do JSON para o Nome
        desc_key: "best_desc_anda",       // Chave do JSON para a Lore
        spr: spr_inimigo,       // Coloque aqui a sprite IDLE correta dele!
        vida: 3,                          // Vida máxima do inimigo
        dano: 1,                          // Dano de ataque do inimigo
        mortes_req: 7                    // Quantos abates para liberar a descrição e status
    },
    
    "inimigo_voa": {
        nome_key: "best_nome_voa",
        desc_key: "best_desc_voa",
        spr: spr_inimigo,        // Coloque aqui a sprite IDLE correta dele!
        vida: 2,
        dano: 1,
        mortes_req: 15
    },
    
    // Você pode colocar os Bosses aqui também!
    "primeiro_boss": {
        nome_key: "best_nome_boss1",
        desc_key: "best_desc_boss1",
        spr: spr_boss,               // Coloque aqui a sprite IDLE correta dele!
        vida: 50,
        dano: 2,
        mortes_req: 1                     // Bosses só precisam ser mortos 1 vez para liberar tudo
}    

}