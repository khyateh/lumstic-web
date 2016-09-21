class SurveyApp.DateRangePicker
  constructor: (@container) ->
    @errors = []
    date_format = "yy-mm-dd"
    @pickers = @container.find(".date-picker")    
    @from = @container.find(".from-date").datepicker({ dateFormat: date_format })
    @to = @container.find(".to-date").datepicker({ dateFormat: date_format })
    @toggle = @container.find("#date-range-checkbox")
    @toggle.click(@toggle_date_pickers)
    
        
  toggle_date_pickers:  =>    
    if @toggle[0].getAttribute('checked')      
      @pickers.attr('disabled', 'disabled')
      @toggle[0].removeAttribute('checked')
    else    
      @pickers.removeAttr('disabled')
      @toggle[0].setAttribute('checked', 'checked')
      
      

  prepare_params: =>    
    if @toggle[0].getAttribute('checked')      
      from: @from.val()
      to: @to.val()
    else      
      {}

  both_dates_present: =>
    valid = !_(@from.val()).isEmpty() && !_(@to.val()).isEmpty()
    @errors.push "You need to add both dates." unless valid
    valid

  from_less_than_to: =>
    valid = @from.datepicker("getDate") <= @to.datepicker("getDate")
    @errors.push "From date must precede To date." unless valid
    valid

  is_valid: =>
    @errors = []
    if @toggle.attr('checked')
      if @both_dates_present() && @from_less_than_to()
        true
    else
      true

  reset: =>
    @from.val('')
    @to.val('')
    @toggle.removeAttr('checked')
    @pickers.attr("disabled", "disabled")

