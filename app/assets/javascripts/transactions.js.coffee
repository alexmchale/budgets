$ ->

  confirmTransactionChangeModal = $("#confirm-transaction-change-modal")
  confirmTransactionDeleteModal = $("#confirm-transaction-delete-modal")

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

  postTransactionDeleteModal = (deleteMode) ->
    confirmTransactionDeleteModal.modal("hide")
    if deleteMode
      id = confirmTransactionDeleteModal.data("id")
      params = { delete_mode: deleteMode }
      $.getScript("/transactions/#{id}/destroy?#{$.param params}")
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
    $field       = $this.closest(".editing")
    $transaction = $this.closest(".transaction")
    isFirst      = $transaction.data("first") == 1
    isLast       = $transaction.data("last") == 1
    id           = $transaction.data("id")
    name         = $field.data("name")
    value        = $this.val()
    original     = $field.data("original").toString()

    confirmTransactionChangeModal.data
      id:    id
      name:  name
      value: value

    if value == original
      $field.removeClass "editing"
      $field.addClass "editable"
      $field.text original
    else if cancel
      postTransactionUpdateModal null
    else if submit && isFirst && isLast
      postTransactionUpdateModal "update-one"
    else if submit
      confirmTransactionChangeModal.modal("show")

    return false

  $(document).on "click", "a[data-submit='modal-form']", ->
    $(this).closest(".modal").find("form").submit()
    return false

  $(document).on "click", ".remove-transaction-button", ->
    $this        = $(this)
    $transaction = $this.closest(".transaction")
    id           = $transaction.data("id")
    confirmTransactionDeleteModal.data("id", id)
    confirmTransactionDeleteModal.modal("show")
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

  $(document).on "click", "a.delete-none", -> postTransactionDeleteModal null
  $(document).on "click", "a.delete-all", -> postTransactionDeleteModal "delete-all"
  $(document).on "click", "a.delete-one", -> postTransactionDeleteModal "delete-one"
  $(document).on "click", "a.delete-later", -> postTransactionDeleteModal "delete-later"

  $("#upcoming_transactions_time_window").on "change", ->
    $select  = $(this)
    $loading = $select.siblings("img.render-loading")
    value    = $select.val()
    params   = { time_window: value }
    $loading.show()
    $.getScript("/transactions/update_upcoming_time_window?#{$.param params}")
