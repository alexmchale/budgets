$.fn.extend

  blink: (duration, period, fn) ->

    console.log [ duration, period ]

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
