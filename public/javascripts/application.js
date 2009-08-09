var current_expression_field = null;

function handleExpression(element) {    
  if( current_expression_field && current_expression_field != element.value) {
    $(current_expression_field).hide();
    current_expression_field = null;
  }
  buildExpression();
  $(element.value+'_field').show();
  current_expression_field = element.value+'_field';
}

function buildExpression() {
  
  var current_category;
  if( $("type_tv_show").checked ) {
    current_category = "tv_show";
  } else if( $("type_movie").checked ) {
    current_category = "movie";
  } else if( $("type_custom").checked ) {
    current_category = "custom";
  }
  
  var set_one_shot = $('data_file_filter_singleton').checked;
  
  switch(current_category) {
    case "movie":
      var title;
      $('data_file_filter_expression').value = "";
      $('data_file_filter_name').value = "";
      
			$('data_file_filter_expression').value  += 'category:"movie"';

      if($F('movie_title')  != "") 
      { 
        $('data_file_filter_expression').value = '\ntitle:"'+$F('movie_title')+'"'; 
        $('data_file_filter_name').value += $F('movie_title');
        title = true;
      }             
      
      set_one_shot = title;        
      break;
    
    case "tv_show":      
      var title,season,episode;
      $('data_file_filter_expression').value = "";
      $('data_file_filter_name').value = "";
      
      $('data_file_filter_expression').value  += 'category:"tv_show"';

      if($F('tv_show_title')  != "") { 
        $('data_file_filter_expression').value  += '\ntitle:"'+$F('tv_show_title')+'"';
        $('data_file_filter_name').value += $F('tv_show_title');
        title = true; 
      }
      
      if($F('tv_show_season') != "") { 
        $('data_file_filter_expression').value += '\nseason:"^0?'+$F('tv_show_season')+'$"'; 
        $('data_file_filter_name').value += ' S'+$F('tv_show_season');
        season = true; 
      }
      
      if($F('tv_show_episode') != "") { 
        $('data_file_filter_expression').value += '\nepisode:"^0?'+$F('tv_show_episode')+'$"'; 
        $('data_file_filter_name').value += ' E'+$F('tv_show_episode');
        episode = true; 
      }             
      
      set_one_shot = title && season && episode;        
      break;
    
    case "custom":
      break;      
  }
  
  $('data_file_filter_singleton').checked = set_one_shot;
  
}