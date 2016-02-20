<?php

get_header();

if(have_posts())
{
    while(have_posts()) : the_post(); ?>
        <article class="post">
            <h1><a href="<?php echo the_permalink(); ?>"><?php echo the_title();?></a></h1>
            <?php the_content(); ?>
        </article>
        
        <?php endwhile;
}

else
{
    echo '<p>No content found</p>';
}

get_footer();

?>

