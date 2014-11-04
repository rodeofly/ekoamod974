######################################################################     
# Variable globale membre=valeur d'un membre, solution=$? (l'inconnue) 

[membre, solution] = [0,0]  

######################################################################  
# Fonction permettant d'inserer un #exo_id dans #enonce
######################################################################  
choisir_exo = (id, output) ->
  $( ".carte" ).remove()
  exo = $( "#{id}" )
  membre = exo.data( "membre" )
  solution = exo.data( "solution" )
  # On parse le texte a la recherche des $ et des # qui symbolisent les items de chacun des membres de l'équation
  text = exo
    .text()
    .replace(/#([0-9]*\??)/g, "<div class='carte diese'>$1</div>" )
    .replace(/\$([0-9]*\??)/g, "<div class='carte dollar'>$1</div>" )
    .replace(/@([0-9]*\??)/g, "<div class='carte arobas'>$1</div>" )
  # On Fabrique un énoncé avec des elements (uniques) de chaque membre de l'équation draggables
  $( "#{output}" ).empty().append("<div class='enonce'>#{text}</div>").dialog
    position:
      my: 'right bottom'
      at: 'right bottom'
      of: '#panel'
  # Prise en charge de la rotation du panel pour la boite de dialogue
  if $( "#panel" ).hasClass( "rotate")
    $( "#{output}" ).dialog
      width: $(window).width() * 1
      height: $(window).height() * 0.3   
  else
    $( "#{output}" ).dialog
      width: $(window).width() * 0.25
      height: $(window).height() * 1
  # Les cartes de l'enoncé sont draggable et deviendront des carte_panels
  $( ".carte" ).draggable
    revert: "invalid"
    helper: "clone"
    appendTo: "#panel"
######################################################################  
# Sommer les cartes d'un certains type d'un certain panel
######################################################################  
checkpanel = () ->
  somme = ( panel, classe) ->
    s = 0
    selector = "#{panel} > #{classe}"
    $( selector ).each ->
      s += $( this ).data( "valeur" )
    return s
  # Quel est le type de la premiere carte du panel en haut
  dollar_en_haut = $( '#panel_top div:first-child' ).hasClass("dollar")
  if dollar_en_haut
    t = somme("#panel_top", ".dollar")
    b = somme("#panel_bottom", ".diese")
  # Du coup cela définit un peu tout le reste !  
  else
    t = somme("#panel_top", ".diese")
    b = somme("#panel_bottom", ".dollar")
  # Roulement de tambour, si tout n'est pas mélangé que les sommes sont exactes qu'il n'y a pas de carte piège alors c'est bon!  
  if t is b and b is membre and $( ".arobas.carte_panel" ).length is 0
    alert "bravo !"
  else
    alert "Essayes encore !" 
         

 
######################################################################     
# On Dom Ready !   
######################################################################  
$ ->
######################################################################    
# Menu #paramètres
######################################################################  
######################################################################  
  #Menu select
  ######################################################################  
  $( ".exercice" ).each ->
    id = $( this ).attr("id")
    html = "<option value='#{id}'>#{id}</option>"
    $( "#exercices" ).append(html)
  $( "#exercices" ).selectmenu
    select: ( event, data ) -> choisir_exo( "##{data.item.value}", "#enonce" )  
  $( "#select_opener" ).click () -> $( "#exercices" ).selectmenu( "open" )
  $( "#parametres" ).dialog
    autoOpen: false
  $( "#menu_parametres" ).click () -> 
    if $( " #parametres" ).dialog( "isOpen" ) 
      $( "#parametres" ).dialog( "close" )
    else
      $( "#parametres" ).dialog( "open" )
    # Checkbox #paramètres
    ######################################################################  
  $(' #checkbox_aide ').change () -> 
    if $(this).is(":checked")
      $( ".carte_panel" ).addClass( "aide" )
    else
      $( ".carte_panel" ).removeClass( "aide" )
  $(' #checkbox_piege ').change () -> 
    if $(this).is(":checked")
      $( ".arobas" ).addClass( "carte" ).draggable('enable')
    else
      $( ".arobas.carte_panel" ).remove()
      $( ".arobas" ).draggable('disable').removeClass( "carte" )
  $(' #checkbox_rotate ').change () -> 
    if $(this).is(":checked")
      $( "#panel, #panel_top, #panel_bottom" ).addClass( "rotate" )
    else
      $( "#panel, #panel_top, #panel_bottom" ).removeClass( "rotate" )
  
    # Corbeille droppable
    ######################################################################  
  $('#trash').droppable
    accept: ".carte_panel" 
    greedy: true
    activeClass: "trash-hover"
    hoverClass: "trash-active"
    drop: (event,ui) -> 
      event.stopPropagation()
      ui.draggable.remove()
    over: (event,ui) -> ui.draggable.addClass( "remove" ).removeClass( "carte")
    out: (event,ui) ->  ui.draggable.addClass( "carte" ).removeClass( "remove")
    
  ######################################################################  
  ######################################################################  
  # Panels droppable  
  ######################################################################  
  $('#panel_top, #panel_bottom').droppable
    accept: ".carte" 
    activeClass: "panel-hover"
    hoverClass: "panel-active"
    drop: (event,ui) ->   
      #Fonction pour ajuster le drop d'une carte dans le panel
      ######################################################################  
      positionneBien = ( unDraggable ) => 
        $( this ).append unDraggable
        if not unDraggable.hasClass( "carte_panel" )
          unDraggable.css
            left: event.clientX - unDraggable.width() - $( this ).position().left
            top : event.clientY  - unDraggable.height()
        else
          unDraggable.css
            left: event.clientX - unDraggable.width()/2 - $( this ).position().left
            top : event.clientY  - unDraggable.height() / 2 
      ######################################################################  
      if ui.draggable.hasClass("carte_panel")
        positionneBien $( ui.draggable )
      else
        leClone = ui.draggable.clone() 
        positionneBien leClone
        valeur = parseInt leClone.html() 
        valeur = if isNaN valeur then solution else valeur
        leClone.addClass("carte_panel").data( "valeur", valeur )
        if $( "#checkbox_aide" ).is(":checked")
          $( leClone ).addClass("aide")          
        # La carte_panel crée doit devenir draggable 
        $( leClone ).draggable
          revert: "invalid"
          cursor: "move" 
######################################################################  
# Vérifier sa modélisation 
###################################################################### 
######################################################################   
  $('#check').click () -> checkpanel()
  
  
    
