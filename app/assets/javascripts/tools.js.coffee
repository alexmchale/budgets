$.fn.extend

  blink: (duration, period, fn) ->

    e = $(this)

    if duration <= 0
      e.removeClass "blinking"
      fn.call(this) if fn?
    else
      if e.hasClass("blinking")
        e.removeClass "blinking"
      else
        e.addClass "blinking"
      duration -= period
      callback = -> e.blink(duration, period, fn)
      setTimeout callback, period

    return this

  whenVisible: (fn) ->

    $this = $(this)

    if $this.is(":visible")
      fn.call(this)
    else
      fn1 = -> $this.whenVisible fn
      setTimeout fn1, 100
