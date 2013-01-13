$ ->

  $(document).on "click", ".transaction .editable", ->
    $this = $(this)
    width = $this.width()
    $this.removeClass "editable"
    $this.addClass "editing"
    $input = $("<input>")
    $input.attr "type", "text"
    $input.attr "name", $this.data("name")
    $input.val $this.text().trim()
    $input.css "width", width
    $this.html $input
    $input.focus()
    return false

  $(document).on "keyup", ".transaction .editing input", (e) ->
    cancel       = e.which == 27
    submit       = e.which == 13
    $this        = $(this)
    $field       = $this.closest("td")
    $transaction = $this.closest(".transaction")
    id           = $transaction.data("id")
    name         = $field.data("name")
    value        = $this.val()
    trans        = {}
    params       = { transaction: trans }
    trans[name]  = value if submit

    $.getScript("/transactions/#{id}/update?#{$.param params}") if cancel || submit

    return false

  $(document).on "click", "a[data-submit='modal-form']", ->
    $(this).closest(".modal").find("form").submit()
    return false

  $(document).on "hidden", ".modal", ->
    $(this).removeData "modal"
    return true

  $(document).on "keyup", "#transaction_debit", ->
    $("#transaction_credit").val("") if $(this).val() != ""

  $(document).on "keyup", "#transaction_credit", ->
    $("#transaction_debit").val("") if $(this).val() != ""
