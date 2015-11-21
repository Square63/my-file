rename_folder = (obj) ->
  parent = $(obj).parents(".folder")
  label = parent.find(".folder-name")
  new_text = parent.find(".folder-name-text").val()
  old_text = label.text()

  unless new_text
    new_text = old_text

  if new_text != old_text
    console.log(new_text == old_text)
    parent.find(".edit_folder").submit()

  label.text(new_text).show()
  $(obj).hide()

$(document).ready ->
  $(".folder").hover ->
    $(this).find(".media-controls").fadeIn();
  , ->
    $(this).find(".media-controls").fadeOut();

  $(".delete").on "click", ->
    $(this).parents(".folder").fadeOut()

  $(".folder-name").click ->
    $(this).hide().parents(".folder").find(".folder-name-text").show().focus().select()

  $(".folder-name-text").blur ->
    rename_folder this

  $(".folder-name-text").keypress (e) ->
    e = e || window.event;
    key_code = e.keyCode || e.which;

    if (key_code == 13)
      rename_folder this
      return false;
