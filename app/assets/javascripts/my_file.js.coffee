window.MyFile = {}

MyFile.store_cookie = "store"
MyFile.current_item_id = null
MyFile.touchdown_timeout = 1000
MyFile.touchdown_timer = null

$.cookie.json = true;

MyFile.reorder_items = ->
  new_order = {}
  $("#items .item").each ->
    self = $(this)
    new_order[self.data("id")] = self.position()

  $("#reorder-form").find("input[name=new_order]").val JSON.stringify(new_order)
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
  "/assets/images/menu/#{image}.png"

MyFile.store = (obj, action) ->
  $.cookie MyFile.store_cookie, {id: obj.attr("id"), action: action}, {path: "/"}

MyFile.cut = (obj) ->
  MyFile.store obj, "cut"

MyFile.copy = (obj) ->
  MyFile.store obj, "copy"

MyFile.do_cut = (parent, id) ->
  parent.fadeOut()
  form = parent.find(".cut_form")
  form.find(".item-parent-id").val id
  form.submit()
  $.removeCookie MyFile.store_cookie, path: "/"

MyFile.do_copy = (parent, id) ->
  form = parent.find(".copy_form")
  form.find(".item-parent-id").val id
  form.submit()

MyFile.paste = (id) ->
  store = $.cookie MyFile.store_cookie
  return unless store

  parent = $("##{store.id}")

  switch store.action
    when "cut"
      MyFile.do_cut parent, id
    when "copy"
      MyFile.do_copy parent, id

    else console.log "Unknown action #{store.action}"

MyFile.apply_right_click = (objs) ->
  objs.each ->
    obj = $(this)

    items = []

    items.push
      text: "Open"
      icon: MyFile.menu_icon("open")
      alias: "open"
      action: ->
        location.href = obj.data("url")

    items.push type: 'splitLine'

    items.push
      text: "Cut"
      icon: MyFile.menu_icon("cut")
      alias: "cut"
      action: ->
        MyFile.cut obj

    items.push
      text: "Copy"
      icon: MyFile.menu_icon("copy")
      alias: "copy"
      action: ->
        MyFile.copy obj

    if obj.data("type") == "folder"
      items.push
        text: "Paste"
        icon: MyFile.menu_icon("paste")
        alias: "paste"
        action: ->
          MyFile.paste obj.data("id")

    items.push type: 'splitLine'

    items.push
      text: "Rename"
      icon: MyFile.menu_icon("rename")
      alias: "rename"
      action: ->
        obj.find(".item-name").click()

    items.push
      text: "Delete"
      icon: MyFile.menu_icon("delete")
      alias: "delete"
      action: ->
        if confirm "Are you sure you want to delete this?"
          obj.fadeOut()
          obj.find(".delete").click()

    items.push type: 'splitLine'

    items.push
      text: "Properties"
      icon: MyFile.menu_icon("properties")
      alias: "properties"
      action: ->
        obj.find(".properties").modal()

    obj.find('.handle').contextmenu
      onContextMenu: true
      alias: "menu-#{obj.attr("id")}"
      width: 150
      items: items
      onShow: (menu) ->
        store = $.cookie(MyFile.store_cookie)
        if store && $("##{store.id}").length && store.id != obj.attr("id")
          menu.disable "paste", false
        else
          menu.disable "paste", true

    obj.find(".handle").on "mousedown", (e) ->
      MyFile.show_menu obj.find(".handle"), e
    .on "mouseup", (e) ->
      MyFile.menu_interrupt obj, e
    .on "mousemove", (e) ->
      MyFile.menu_cancelled obj

    obj.find(".handle").on "touchstart", (e) ->
      touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0];
      MyFile.show_menu obj.find(".handle"), touch
    .on "touchend", (e) ->
      touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0];
      MyFile.menu_interrupt obj, touch
    .on "touchmove", (e) ->
      MyFile.menu_cancelled obj

MyFile.dump = (s) ->
  JSON.stringify s, null, "\t"

MyFile.show_menu = (obj, e) ->
  return if e.button == 2
  MyFile.touchdown_timer = setTimeout ->
    MyFile.touchdown_timer = null
    obj.trigger "contextmenu", e
  , MyFile.touchdown_timeout

MyFile.menu_interrupt = (obj, e) ->
  if MyFile.touchdown_timer
    url = obj.data("url")
    location.href = url if url

  MyFile.menu_cancelled obj

MyFile.menu_cancelled = (obj) ->
  clearTimeout MyFile.touchdown_timer
  MyFile.touchdown_timer = null

MyFile.apply_drag_drop = (obj) ->
  obj.draggable
    handle: obj.find(".handle")
    containment: "#items"
    stop: (event, ui) ->
      MyFile.reorder_items() unless obj.hasClass("hovering")

  if obj.data("type") == "folder"
    obj.find(".item-container").droppable
      tolerance: "intersect"
      over: (event, ui) ->
        $(this).addClass "drop-hover"
        $(event.toElement).parents(".item").addClass "hovering"
      out: (event, ui) ->
        $(this).removeClass "drop-hover"
        $(event.toElement).parents(".item").removeClass "hovering"
      drop: (event, ui) ->
        $(this).removeClass "drop-hover"
        MyFile.do_cut $(event.toElement).parents(".item"), $(this).parents(".item").data("id")

MyFile.apply_js_item = (obj) ->
  MyFile.apply_right_click obj
  MyFile.apply_drag_drop obj

  obj.find(".item-name").on "click", ->
    MyFile.trigger_rename_action $(this).parents(".item")

  obj.find(".item-name-text").on "blur", ->
    MyFile.rename_item this

  obj.find(".item-name-text").keydown (e) ->
    e = e || window.event;
    key_code = e.keyCode || e.which;

    if (key_code == 13)
      MyFile.rename_item this
      false

    if key_code == 27
      item = $(this).parents(".item")
      item_name = item.find(".item-name")
      MyFile.rename_item $(this).val(item_name.text())
      false

MyFile.init_main_right_click = ->
  obj = $("#wrap-all")

  items = []

  items.push
    text: "Refresh"
    icon: MyFile.menu_icon("refresh")
    alias: "refresh"
    action: ->
      false

  items.push type: 'splitLine'

  items.push
      text: "Paste"
      icon: MyFile.menu_icon("paste")
      alias: "paste"
      action: ->
        MyFile.paste MyFile.current_item_id

  items.push type: 'splitLine'

  items.push
    text: "Properties"
    icon: MyFile.menu_icon("properties")
    alias: "properties"
    action: ->
      console.log "Properties"

  obj.contextmenu
    onContextMenu: true
    alias: "menu-main"
    width: 150
    items: items
    onShow: (menu) ->
      store = $.cookie(MyFile.store_cookie)
      if store && $("##{store.id}").length && (store.action == "copy" || store.action == "cut" && store.id != MyFile.current_item_id)
        menu.disable "paste", false
      else
        menu.disable "paste", true

  obj.on "mousedown", (e) ->
    return if $(e.target).parents(".item-container").length
    MyFile.show_menu obj, e
  .on "mouseup", (e) ->
    return if $(e.target).parents(".item-container").length
    MyFile.menu_cancelled obj, e

  obj.on "touchstart", (e) ->
    return if $(e.target).parents(".item-container").length
    touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0];
    MyFile.show_menu obj, touch
  .on "touchend", (e) ->
    return if $(e.target).parents(".item-container").length
    touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0];
    MyFile.menu_cancelled obj, touch

MyFile.trigger_rename_action = (obj) ->
  text_area = obj.find(".item-name-text")
  text = text_area.val()
  if text.lastIndexOf(".") > -1 && obj.data("type") != "folder"
    end_index = text.lastIndexOf(".")
  else
    end_index = text.length
  obj.find(".item-name").hide()
  text_area.show()
  text_area.focus()
  text_area[0].setSelectionRange 0, end_index

MyFile.append_item = (item) ->
  item.hide()
  $("#items").append(item)
  item.fadeIn()
  MyFile.apply_js_item(item)

$(document).ready ->
  $(".item.real").each ->
    MyFile.apply_js_item $(this)
  MyFile.init_main_right_click()
