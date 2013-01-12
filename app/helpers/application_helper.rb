module ApplicationHelper

  def js_render_to_div(dom_selector, partial_name, locals = {})
    rendered = render(partial: partial_name, locals: locals)
    escaped  = escape_javascript(rendered)
    raw %[$("#{dom_selector}").html('#{escaped}')]
  end

end
