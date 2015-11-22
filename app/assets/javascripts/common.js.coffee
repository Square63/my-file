reorder_items = ->
  ids = $("#items .item").map ->
    $(this).data("id")
  .get().join(",")

  $("#reorder-form").find("input[name=ids]").val(ids)
  $("#reorder-form").submit();

rename_item = (obj) ->
  parent = $(obj).parents(".item")
  name = parent.find(".item-name")
  new_text = parent.find(".item-name-text").val()
  old_text = name.text()

  unless new_text
    new_text = old_text

  if new_text != old_text
    parent.find(".edit_item").submit()

  name.text(new_text).show()
  $(obj).hide()

$(document).ready ->
  $(".item").hover ->
    $(this).find(".item-controls").fadeIn();
  , ->
    $(this).find(".item-controls").fadeOut();

  $(".delete").on "click", ->
    $(this).parents(".item").fadeOut()

  $(".item-name").click ->
    $(this).hide().parents(".item").find(".item-name-text").show().focus().select()

  $(".item-name-text").blur ->
    rename_item this

  $(".item-name-text").keypress (e) ->
    e = e || window.event;
    key_code = e.keyCode || e.which;

    if (key_code == 13)
      rename_item this
      return false;

  sortable = Sortable.create $("#items")[0],
    group: "items",
    animation: 500,
    handle: ".image_icon",
    draggable: ".item",
    onUpdate: (e) ->
      reorder_items()
