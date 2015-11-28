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
    handle: ".icon",
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

MyFile.menu_icon = (image) ->
  "/assets/menu/#{image}.png"

MyFile.apply_right_click = (objs) ->
  objs.each ->
    obj = $(this)
    obj.find('.icon').contextmenu
      onContextMenu: true
      alias: "menu-#{obj.attr("id")}"
      width: 150
      items: [
        {
          text: "Open"
          icon: MyFile.menu_icon("open")
          alias: obj.attr("id")
          action: ->
            window.ali = this
            item = $("##{this.data.alias}")
            location.href = item.data("url")
        }
        { type: 'splitLine' }
      ]

MyFile.apply_js_item = (obj) ->
  MyFile.apply_right_click obj

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
  MyFile.apply_js_item $(".item.real")
  MyFile.reload_sortable()
