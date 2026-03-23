if (timer_sumir > 0) 
{
    timer_sumir -= desconta_timer();
}
else 
{
    image_alpha -= 0.02;
    if (image_alpha <= 0) instance_destroy();
}