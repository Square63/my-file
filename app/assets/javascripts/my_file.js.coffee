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

MyFile.store = (objs, action) ->
  ids = []
  item_ids = []

  $(objs).each ->
    ids.push $(this).attr("id")
    item_ids.push $(this).data("id")

  $.cookie MyFile.store_cookie, {ids: ids, action: action, item_ids: item_ids}, {path: "/"}

MyFile.do_cut = (parents, id) ->
  for parent in parents
    unless $(parent).data("id") == id
      $(parent).fadeOut()
      form = $(parent).find(".cut_form")
      form.find(".item-parent-id").val id
      form.submit()

  $.removeCookie MyFile.store_cookie, path: "/"

MyFile.do_copy = (parents, id) ->
  for parent in parents

    unless parent.data("id") == id
      form = parent.find(".copy_form")
      form.find(".item-parent-id").val id
      form.submit()

MyFile.paste = (id) ->
  store = $.cookie MyFile.store_cookie
  return unless store

  parents = []
  for view_id in store.ids
    parents.push $("##{view_id}")

  switch store.action
    when "cut"
      MyFile.do_cut parents, id
    when "copy"
      MyFile.do_copy parents, id

    else console.log "Unknown action #{store.action}"

MyFile.delete = ->
  $(".item-container.selected").each ->
    parent = $(this).parents(".item")
    parent.fadeOut()
    parent.find(".delete").click()

MyFile.apply_right_click = (objs) ->
  objs.each ->
    obj = $(this)

    items = []

    items.push
      text: "Open"
      icon: MyFile.menu_icon("open")
      alias: "open"
      action: ->
        MyFile.open obj.data("url")

    items.push type: 'splitLine'

    items.push
      text: "Cut"
      icon: MyFile.menu_icon("cut")
      alias: "cut"
      action: ->
        MyFile.store $(".item-container.selected").parents(".item"), "cut"

    items.push
      text: "Copy"
      icon: MyFile.menu_icon("copy")
      alias: "copy"
      action: ->
        MyFile.store $(".item-container.selected").parents(".item"), "copy"

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
        if confirm "Are you sure you want to delete the selected item(s)"
          MyFile.delete()

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
        if store && store.action in ['copy', 'cut'] && obj.attr("id") not in store.ids
          menu.disable "paste", false
        else
          menu.disable "paste", true

        if $(".item-container.selected").length == 1
          menu.disable "open", false
          menu.disable "paste", false
          menu.disable "rename", false
          menu.disable "properties", false
        else
          menu.disable "open", true
          menu.disable "paste", true
          menu.disable "rename", true
          menu.disable "properties", true

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
  return if e.button == 2 || e.ctrlKey
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
        MyFile.do_cut $(".item-container.selected").parent(), $(this).parents(".item").data("id")

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
      if store && store.action in ['copy', 'cut'] && +MyFile.current_item_id not in store.item_ids
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
  $(".selected").removeClass "selected"
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

MyFile.refresh_item = (item) ->
  $("##{item.attr('id')}").replaceWith(item)
  MyFile.apply_js_item(item)

MyFile.open = (url) ->
  location.href = url

MyFile.init_search = (obj) ->
  search = obj.autocomplete
    minLength: 1
    source: "/items/search"
    select: (event, ui) ->
      if ui.item.url
        MyFile.open ui.item.url
    response: (event, ui) ->
      if !ui.content.length
        ui.content.push html: 'No results found...'

  search.autocomplete('instance')._renderItem = (ul, item) ->
    $('<li>').append(item.html).appendTo ul

MyFile.select_multiple_items = ->
  container = $("#main-container")
  selection = $("<div>").addClass "selection-box"
  click_x = click_y = 0
  active = false

  $(document).mousedown (e) ->
    $(".item-container").each ->
      if !e.ctrlKey && !$(this).is(e.target) && (!$(e.target).parents(".item-container").hasClass "selected" || e.button == 0)
        $(this).removeClass "selected"
    $(e.target).parents(".item-container").addClass "selected"

    if container.has(e.target).length > 0
      active = e.button == 0 && $(".selected").length == 0
      click_y = e.pageY
      click_x = e.pageX

  container.mousemove (e) ->
    return unless active

    move_x = e.pageX
    move_y = e.pageY
    width = Math.abs(move_x - click_x)
    height = Math.abs(move_y - click_y)

    return if width < 10 and height < 10

    if move_x < click_x
      new_x = click_x - width
    else
      new_x = click_x

    if move_y < click_y
      new_y = click_y - height
    else
      new_y = click_y

    selection.css
      width: width
      height: height
      top: new_y
      left: new_x

    selection.appendTo container
    selected_rect = selection[0].getBoundingClientRect()

    $(".item-container").each ->
      item = $(this)[0].getBoundingClientRect()
      unless item.right < selected_rect.left || item.left > selected_rect.right || item.bottom < selected_rect.top || item.top > selected_rect.bottom
        $(this).addClass "selected"
      else
        $(this).removeClass "selected"

  $(document).mouseup (e) ->
    active = false
    selection.remove()

MyFile.select_all_items = ->
  $(document).keydown (e) ->
    e = e || window.event;
    key_code = e.keyCode || e.which;

    if key_code == 65 && e.ctrlKey
      $(".item-container").addClass "selected"

$(document).ready ->
  $(".item.real").each ->
    MyFile.apply_js_item $(this)
  MyFile.init_main_right_click()
  MyFile.init_search $("#search")
  MyFile.select_multiple_items()
  MyFile.select_all_items()
