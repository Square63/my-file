window.MyFile = {}

MyFile.store_cookie = "store"
MyFile.current_item_id = null

$.cookie.json = true;

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

MyFile.store = (obj, action) ->
  $.cookie MyFile.store_cookie, {id: obj.attr("id"), action: action}, {path: "/"}

MyFile.cut = (obj) ->
  MyFile.store obj, "cut"

MyFile.copy = (obj) ->
  MyFile.store obj, "copy"

MyFile.apply_right_click = (objs) ->
  objs.each ->
    obj = $(this)

    items = []

    items.push
      text: "Open"
      icon: MyFile.menu_icon("open")
      alias: "open"
      item: obj
      action: ->
        location.href = this.data.item.data("url")

    items.push type: 'splitLine'

    items.push
      text: "Cut"
      icon: MyFile.menu_icon("cut")
      alias: "cut"
      item: obj
      action: ->
        MyFile.cut obj

    items.push
      text: "Copy"
      icon: MyFile.menu_icon("copy")
      alias: "copy"
      item: obj
      action: ->
        MyFile.copy obj

    if obj.data("type") == "folder"
      items.push
        text: "Paste"
        icon: MyFile.menu_icon("paste")
        alias: "paste"
        item: obj
        action: ->
          store = $.cookie(MyFile.store_cookie)
          unless store
            return

          parent = $("##{store.id}")

          switch store.action
            when "cut"
              parent.fadeOut()
              form = parent.find(".cut_form")
              form.find(".item-parent-id").val this.data.item.data("id")
              form.submit()
            when "copy"
              form = parent.find(".copy_form")
              form.find(".item-parent-id").val this.data.item.data("id")
              form.submit()

            else console.log "Unknown action #{store.action}"

    items.push type: 'splitLine'

    items.push
      text: "Rename"
      icon: MyFile.menu_icon("rename")
      alias: "rename"
      item: obj
      action: ->
        obj.find(".item-name").click()

    items.push
      text: "Delete"
      icon: MyFile.menu_icon("delete")
      alias: "delete"
      item: obj
      action: ->
        if confirm "Are you sure you want to delete this?"
          obj.fadeOut()
          obj.find(".delete").click()

    obj.find('.icon').contextmenu
      onContextMenu: true
      alias: "menu-#{obj.attr("id")}"
      width: 150
      items: items
      onShow: (menu) ->
        store = $.cookie(MyFile.store_cookie)
        if store && $("##{store.id}").length
          menu.disable "paste", false
        else
          menu.disable "paste", true

MyFile.apply_js_item = (obj) ->
  MyFile.apply_right_click obj

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
