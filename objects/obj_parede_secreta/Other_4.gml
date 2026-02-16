if (instance_exists(obj_controla_luz) and obj_controla_luz.renderer != undefined)
{

    meu_oclusor = new BulbStaticOccluder(obj_controla_luz.renderer); 
    

    meu_oclusor.AddEdge(bbox_left, bbox_top, bbox_right, bbox_top);
    meu_oclusor.AddEdge(bbox_right, bbox_top, bbox_right, bbox_bottom);
    meu_oclusor.AddEdge(bbox_right, bbox_bottom, bbox_left, bbox_bottom);
    meu_oclusor.AddEdge(bbox_left, bbox_bottom, bbox_left, bbox_top);
    

}