window.MyFile = {}

MyFile.reload_sortable = ->
  if $("#items").length == 0
    return false

  if MyFile.sortable
    MyFile.sortable.destroy()
    MyFile.sortable = null

  MyFile.sortable = Sortable.create $("#items")[0],
    group: "items",
    animation: 500,
    draggable: ".item",
    onUpdate: (e) ->
      MyFile.reorder_items()

MyFile.reorder_items = ->
  ids = $("#items .item").map ->
    $(this).data("id")
  .get().join(",")

  $("#reorder-form").find("input[name=ids]").val(ids)
  $("#reorder-form").submit();

MyFile.rename_item = (obj) ->
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

MyFile.apply_js_item = (obj) ->
  obj.hover ->
    $(this).find(".item-controls").fadeIn();
    $(this).find(".size").fadeIn();
  , ->
    $(this).find(".item-controls").fadeOut();
    $(this).find(".size").fadeOut();

  obj.find(".delete").on "click", ->
    $(this).parents(".item").fadeOut()

  obj.find(".item-name").on "click", ->
    $(this).hide().parents(".item").find(".item-name-text").show().focus().select()

  obj.find(".item-name-text").on "blur", ->
    MyFile.rename_item this

  obj.find(".item-name-text").keypress (e) ->
    e = e || window.event;
    key_code = e.keyCode || e.which;

    if (key_code == 13)
      MyFile.rename_item this
      return false;

$(document).ready ->
  MyFile.apply_js_item $(".item")
  MyFile.reload_sortable()
