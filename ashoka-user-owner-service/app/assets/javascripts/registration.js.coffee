class UserOwner.Registration
  constructor: (container) ->
    @legal_item_checkboxes = container.find(".mandatory .organization-legal-item-checkbox")
    @register_button = container.find(".organization-register-button")
    @legal_item_checkboxes.click(@toggle_register_button)

  toggle_register_button: =>
    if @all_legal_checkboxes_checked()
      @register_button.removeAttr('disabled')
    else
      @register_button.attr('disabled', 'disabled')

  all_legal_checkboxes_checked: =>
    status = true
    @legal_item_checkboxes
    _(@legal_item_checkboxes).every (item)=>
      if(item.type == 'checkbox')
        status = status && item.checked
