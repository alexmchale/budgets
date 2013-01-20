$ ->

  confirmTransactionChangeModal = $("#confirm-transaction-change-modal")

  postTransactionUpdateField = (id, name, value, updateMode) ->
    params                   = { transaction: {}, update_mode: updateMode }
    params.transaction[name] = value if updateMode?
    $.getScript("/transactions/#{id}/update?#{$.param params}")

  postTransactionUpdateModal = (updateMode) ->
    id    = confirmTransactionChangeModal.data("id")
    name  = confirmTransactionChangeModal.data("name")
    value = confirmTransactionChangeModal.data("value")
    confirmTransactionChangeModal.modal("hide")
    postTransactionUpdateField id, name, value, updateMode
    return false

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
    isLast       = $transaction.data("last") == "1"
    id           = $transaction.data("id")
    name         = $field.data("name")
    value        = $this.val()

    confirmTransactionChangeModal.data
      id:    id
      name:  name
      value: value

    if cancel
      postTransactionUpdateModel null
    else if submit
      confirmTransactionChangeModal.modal("show")

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

  $(document).on "click", "a.update-none", -> postTransactionUpdateModal null
  $(document).on "click", "a.update-all", -> postTransactionUpdateModal "update-all"
  $(document).on "click", "a.update-one", -> postTransactionUpdateModal "update-one"
  $(document).on "click", "a.update-later", -> postTransactionUpdateModal "update-later"
